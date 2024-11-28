import 'package:doctor_doom/agora/agoraservices.dart';
import 'package:doctor_doom/agora/apiwork.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:agora_rtm/agora_rtm.dart';

final roomNameProvider = StateProvider<String>((ref) => '');
final userNameProvider = StateProvider<String>((ref) => '');
final muteProvider = StateProvider<bool>((ref) => false);
final cameraProvider = StateProvider<bool>((ref) => false);
final meetingJoinedProvider = StateProvider<bool>((ref) => false);
final tokenProvider = StateProvider<String>((ref) => '');
final meetingUidProvider = StateProvider<int?>((ref) => null);

class MeetingScreen extends ConsumerStatefulWidget {
  final String roomName;
  final String userName;
  final int uid;

  const MeetingScreen({
    required this.roomName,
    required this.userName,
    required this.uid,
    Key? key,
  }) : super(key: key);

  @override
  _MeetingScreenState createState() => _MeetingScreenState();
}

class _MeetingScreenState extends ConsumerState<MeetingScreen> {
  late AgoraRtmClient _rtmClient;
  AgoraRtmChannel? _rtmChannel; // Nullable Agora RTM channel
  final List<String> _messages = [];

  @override
  void initState() {
    super.initState();
    _initializeChat();
  }

  @override
  Widget build(BuildContext context) {
    final muteStatus = ref.watch(muteProvider);
    final cameraStatus = ref.watch(cameraProvider);
    final meetingJoined = ref.watch(meetingJoinedProvider);

    if (!meetingJoined) {
      _initializeMeeting(context);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Meeting: ${widget.roomName}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.chat),
            onPressed: () => _showChatDialog(context),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              color: const Color.fromARGB(255, 37, 37, 37),
              child: meetingJoined
                  ? Stack(
                      children: [
                        // Remote video spans the entire screen
                        Positioned.fill(
                          child: AgoraService.remoteVideo(),
                        ),
                        // Local video at the bottom-right corner
                        Positioned(
                          bottom: 10,
                          right: 10,
                          child: Container(
                            width: 120,
                            height: 160,
                            color: Colors.black.withOpacity(0.5),
                            child: AgoraService.localVideo(),
                          ),
                        ),
                      ],
                    )
                  : const Center(
                      child: CircularProgressIndicator(),
                    ),
            ),
          ),
          // Button bar
          Container(
            color: Colors.black87,
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(
                    muteStatus ? Icons.mic_off : Icons.mic,
                    color: muteStatus ? Colors.red : Colors.white,
                  ),
                  onPressed: () async {
                    ref.read(muteProvider.notifier).state = !muteStatus;
                    await AgoraService.muteLocalAudio(!muteStatus);
                  },
                ),
                IconButton(
                  icon: Icon(
                    cameraStatus ? Icons.videocam_off : Icons.videocam,
                    color: cameraStatus ? Colors.red : Colors.white,
                  ),
                  onPressed: () async {
                    ref.read(cameraProvider.notifier).state = !cameraStatus;
                    await AgoraService.muteLocalVideo(cameraStatus);
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.exit_to_app, color: Colors.red),
                  onPressed: () async {
                    await _leaveChat();
                    await AgoraService.leaveChannel(
                        widget.roomName, widget.userName);
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _initializeMeeting(BuildContext context) async {
    if (await AgoraService.checkPermissions()) {
      final tokenData = await fetchAgoraToken(widget.roomName);
      if (tokenData == null ||
          tokenData['token'] == null ||
          tokenData['uid'] == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to get Agora token or UID')),
        );
        return;
      }

      ref.read(tokenProvider.notifier).state = tokenData['token']!;
      ref.read(meetingUidProvider.notifier).state = tokenData['uid'] as int;

      await AgoraService.initializeAgora();
      await AgoraService.joinChannel(widget.roomName, widget.userName);

      ref.read(meetingJoinedProvider.notifier).state = true;
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Camera or microphone permissions denied')),
      );
    }
  }

  Future<void> _initializeChat() async {
    try {
      // Initialize RTM client
      _rtmClient = await AgoraRtmClient.createInstance("YOUR_AGORA_APP_ID");

      _rtmClient.onMessageReceived = (AgoraRtmMessage message, String peerId) {
        print("Private message from $peerId: ${message.text}");
      };

      _rtmClient.onConnectionStateChanged = (int state, int reason) {
        if (state == 5) {
          print("RTM connection lost, logging out.");
          _rtmClient.logout();
        }
      };

      // Log in to RTM
      await _rtmClient.login(null, widget.userName);

      // Join the RTM channel for group chat
      _rtmChannel = await _rtmClient.createChannel(widget.roomName);
      if (_rtmChannel == null) {
        throw Exception("Failed to create RTM channel");
      }

      _rtmChannel!.onMessageReceived =
          (AgoraRtmMessage message, AgoraRtmMember member) {
        setState(() {
          _messages.add("${member.userId}: ${message.text}");
        });
      };

      await _rtmChannel!.join();
      print("Joined RTM channel: ${widget.roomName}");
    } catch (e) {
      print("Error initializing RTM: $e");
    }
  }

  Future<void> _leaveChat() async {
    try {
      if (_rtmChannel != null) {
        await _rtmChannel!.leave();
        print("Left RTM channel: ${widget.roomName}");
      }
      await _rtmClient.logout();
      print("Logged out of RTM");
    } catch (e) {
      print("Error leaving RTM: $e");
    }
  }

  void _sendMessage(String text) async {
    if (_rtmChannel == null) return;

    try {
      await _rtmChannel!.sendMessage(AgoraRtmMessage.fromText(text));
      setState(() {
        _messages.add("You: $text");
      });
    } catch (e) {
      print("Error sending message: $e");
    }
  }

  void _showChatDialog(BuildContext context) {
    final TextEditingController messageController = TextEditingController();

    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return ListTile(title: Text(_messages[index]));
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: messageController,
                    decoration: const InputDecoration(
                      hintText: 'Enter message',
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () {
                    final text = messageController.text;
                    if (text.isNotEmpty) {
                      _sendMessage(text);
                      messageController.clear();
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
