import 'package:doctor_doom/agora/agoraservices.dart';
import 'package:doctor_doom/agora/apiwork.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
    required bool isVideoOn,
    required bool isMicOn,
  }) : super(key: key);

  @override
  _MeetingScreenState createState() => _MeetingScreenState();
}

class _MeetingScreenState extends ConsumerState<MeetingScreen> {
  @override
  Widget build(BuildContext context) {
    final muteStatus = ref.watch(muteProvider);
    final cameraStatus = ref.watch(cameraProvider);
    final meetingJoined = ref.watch(meetingJoinedProvider);
    final meetingid = ref.watch(tokenProvider);

    if (!meetingJoined) {
      _initializeMeeting(context);
    }

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'roomName: ${widget.roomName}',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'ID: ${meetingid}',
                    style: TextStyle(fontSize: 12, color: Colors.white70),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.copy, size: 16, color: Colors.white),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: meetingid));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Token copied to clipboard')),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
        backgroundColor: Colors.blue,
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
                            child: Positioned.fill(
                                child: AgoraService.localVideo(widget.uid)),
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
      await AgoraService.startMeeting(
          widget.roomName, widget.uid, widget.userName);

      ref.read(meetingJoinedProvider.notifier).state = true;
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Camera or microphone permissions denied')),
      );
    }
  }
}
