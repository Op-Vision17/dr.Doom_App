import 'package:doctor_doom/agora/agoraservices.dart';
import 'package:doctor_doom/agora/apiwork.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Providers to manage room name, user name, mute status, camera status, meeting status, token, and meeting uid
final roomNameProvider = StateProvider<String>((ref) => '');
final userNameProvider = StateProvider<String>((ref) => '');
final muteProvider = StateProvider<bool>((ref) => false); // Mute/unmute audio
final cameraProvider = StateProvider<bool>((ref) => false); // Camera on/off
final meetingJoinedProvider =
    StateProvider<bool>((ref) => false); // Meeting joined status
final tokenProvider = StateProvider<String>((ref) => ''); // Store token
final meetingUidProvider =
    StateProvider<int?>((ref) => null); // Store meeting UID

class MeetingScreen extends ConsumerStatefulWidget {
  final String roomName;
  final String userName;

  const MeetingScreen({
    required this.roomName,
    required this.userName,
    Key? key,
  }) : super(key: key);

  @override
  _MeetingScreenState createState() => _MeetingScreenState();
}

class _MeetingScreenState extends ConsumerState<MeetingScreen> {
  bool _isMuted = false;
  bool _isCameraOff = false;

  @override
  void initState() {
    super.initState();
    // Initialize roomName and userName in providers
    ref.read(roomNameProvider.notifier).state = widget.roomName;
    ref.read(userNameProvider.notifier).state = widget.userName;

    // Initialize the meeting on screen load
    _initializeMeeting();
  }

  Future<void> _initializeMeeting() async {
    // Check for camera and microphone permissions
    if (await AgoraService.checkPermissions()) {
      final token = await fetchAgoraToken(widget.roomName);
      if (token == null || token.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to get Agora token')),
        );
        return;
      }

      // Set the token in the Riverpod provider
      ref.read(tokenProvider.notifier).state = token;

      // Initialize Agora service and join the channel
      await AgoraService.initializeAgora();
      await AgoraService.joinChannel(widget.roomName, widget.userName);

      // Set meeting joined status in Riverpod
      ref.read(meetingJoinedProvider.notifier).state = true;
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Camera or microphone permissions denied')),
      );
    }
  }

  @override
  void dispose() {
    super.dispose();
    // Leave the Agora channel when the screen is disposed
    AgoraService.leaveChannel(widget.roomName, widget.userName);
  }

  @override
  Widget build(BuildContext context) {
    final token = ref.watch(tokenProvider);
    final muteStatus = ref.watch(muteProvider);
    final cameraStatus = ref.watch(cameraProvider);
    final meetingJoined = ref.watch(meetingJoinedProvider);
    final meetingUid = ref.watch(meetingUidProvider); // Access the meeting UID

    return Scaffold(
      appBar: AppBar(title: Text('Meeting: ${widget.roomName}')),
      body: Column(
        children: [
          Expanded(
            child: Container(
              color: Colors.black, // Placeholder for video stream
              child: meetingJoined
                  ? AgoraService.remoteVideo() // Display remote video view
                  : Center(
                      child:
                          CircularProgressIndicator()), // Show loading while joining
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Mute/Unmute Audio
              IconButton(
                icon: Icon(
                  muteStatus ? Icons.mic_off : Icons.mic,
                  color: muteStatus ? Colors.red : Colors.white,
                ),
                onPressed: () async {
                  ref.read(muteProvider.notifier).state = !muteStatus;
                  await AgoraService.muteLocalAudio(
                      !muteStatus); // Update mute status
                },
              ),
              // Turn Camera On/Off
              IconButton(
                icon: Icon(
                  cameraStatus ? Icons.videocam_off : Icons.videocam,
                  color: cameraStatus ? Colors.red : Colors.white,
                ),
                onPressed: () async {
                  ref.read(cameraProvider.notifier).state = !cameraStatus;
                  if (cameraStatus) {
                    await AgoraService.muteLocalVideo(true); // Disable video
                  } else {
                    await AgoraService.muteLocalVideo(false); // Enable video
                  }
                },
              ),
              // Leave Meeting
              IconButton(
                icon: Icon(Icons.exit_to_app, color: Colors.red),
                onPressed: () async {
                  await AgoraService.leaveChannel(
                      widget.roomName, widget.userName);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
