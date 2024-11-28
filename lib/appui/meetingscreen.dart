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

  const MeetingScreen({
    required this.roomName,
    required this.userName,
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

    if (!meetingJoined) {
      _initializeMeeting(context);
    }

    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Room: ${widget.roomName}',
          style: TextStyle(
            fontSize: screenWidth * 0.05,
            fontWeight: FontWeight.bold,
            color: Colors.black, // Black text color
          ),
        ),
        backgroundColor: Colors.teal, // Teal background
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              color: const Color.fromARGB(255, 37, 37, 37),
              child: meetingJoined
                  ? Stack(
                      children: [
                        Positioned.fill(
                          child: AgoraService
                              .remoteVideos(), // Dynamic remote videos
                        ),
                        Positioned(
                          bottom: 10,
                          right: 10,
                          child: Container(
                            width: screenWidth * 0.3,
                            height: screenHeight * 0.2,
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: AgoraService.localVideo(), // Local video
                          ),
                        ),
                      ],
                    )
                  : const Center(
                      child: CircularProgressIndicator(),
                    ),
            ),
          ),
          Container(
            color: Colors.black87,
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _controlButton(
                  context: context,
                  icon: muteStatus ? Icons.mic_off : Icons.mic,
                  color: muteStatus ? Colors.red : Colors.white,
                  onPressed: () async {
                    final newMuteStatus = !muteStatus;
                    ref.read(muteProvider.notifier).state = newMuteStatus;
                    await AgoraService.muteLocalAudio(newMuteStatus);
                  },
                ),
                _controlButton(
                  context: context,
                  icon: cameraStatus ? Icons.videocam_off : Icons.videocam,
                  color: cameraStatus ? Colors.red : Colors.white,
                  onPressed: () async {
                    final newCameraStatus = !cameraStatus;
                    ref.read(cameraProvider.notifier).state = newCameraStatus;
                    await AgoraService.muteLocalVideo(newCameraStatus);
                  },
                ),
                _controlButton(
                  context: context,
                  icon: Icons.chat_bubble_outline, // Chat button icon
                  color: Colors.white,
                  onPressed: () {
                    // No functionality added yet
                  },
                ),
                _controlButton(
                  context: context,
                  icon: Icons.exit_to_app,
                  color: Colors.red,
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

  Widget _controlButton({
    required BuildContext context,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.black.withOpacity(0.6),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            offset: Offset(0, 4),
            blurRadius: 8,
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(
          icon,
          size: screenWidth * 0.1,
          color: color,
        ),
        onPressed: onPressed,
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
      await AgoraService.joinOrStartMeeting(widget.roomName, widget.userName);

      ref.read(meetingJoinedProvider.notifier).state = true;
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Camera or microphone permissions denied')),
      );
    }
  }
}
