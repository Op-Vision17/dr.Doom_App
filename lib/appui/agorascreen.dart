import 'package:doctor_doom/agora/apiwork.dart';
import 'package:doctor_doom/chat/chatprovider.dart';
import 'package:doctor_doom/chat/chatscreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Import Riverpod
import 'package:agora_rtc_engine/agora_rtc_engine.dart';

class AgoraScreen extends ConsumerStatefulWidget {
  final String appId;
  final String token;
  final String channelName;
  final int uid;
  final String userName;
  final bool isMicMuted;
  final bool isCameraMuted;

  const AgoraScreen({
    required this.appId,
    required this.token,
    required this.channelName,
    required this.uid,
    required this.userName,
    required this.isMicMuted,
    required this.isCameraMuted,
  });

  @override
  _AgoraScreenState createState() => _AgoraScreenState();
}

class _AgoraScreenState extends ConsumerState<AgoraScreen> {
  late RtcEngine _agoraEngine;
  Map<int, String?> remoteUsers = {};
  late int localUid;

  bool isMicMuted = false;
  bool isCameraMuted = false;

  double _localVideoX = 10.0;
  double _localVideoY = 10.0;

  @override
  void initState() {
    super.initState();
    isMicMuted = widget.isMicMuted;
    isCameraMuted = widget.isCameraMuted;
    initAgora();
  }

  Future<void> initAgora() async {
    _agoraEngine = createAgoraRtcEngine();
    await _agoraEngine.initialize(
      RtcEngineContext(appId: widget.appId),
    );

    await _agoraEngine
        .setChannelProfile(ChannelProfileType.channelProfileCommunication);
    await _agoraEngine.enableVideo();

    await _agoraEngine.joinChannel(
      token: widget.token,
      channelId: widget.channelName,
      uid: widget.uid,
      options: ChannelMediaOptions(
        channelProfile: ChannelProfileType.channelProfileCommunication,
        clientRoleType: ClientRoleType.clientRoleBroadcaster,
      ),
    );

    _agoraEngine.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int uid) {
          setState(() {
            localUid = uid;
          });
          createMember(widget.userName, widget.uid, widget.channelName);
        },
        onUserJoined:
            (RtcConnection connection, int remoteUid, int elapsed) async {
          String? memberName =
              await fetchMemberDetails(remoteUid, widget.channelName);
          setState(() {
            remoteUsers[remoteUid] = memberName;
          });
          await _agoraEngine.enableVideo();
          await _agoraEngine.setupRemoteVideo(VideoCanvas(uid: remoteUid));
        },
        onUserOffline: (RtcConnection connection, int remoteUid,
            UserOfflineReasonType reason) {
          setState(() {
            remoteUsers.remove(remoteUid);
          });
        },
      ),
    );

    await _agoraEngine.muteLocalAudioStream(isMicMuted);
    await _agoraEngine.muteLocalVideoStream(isCameraMuted);
  }

  @override
  void dispose() {
    _agoraEngine.leaveChannel();
    _agoraEngine.release();
    super.dispose();
  }

  // New function to clear chat messages before leaving the meeting
  void _clearChatMessages() {
    ref
        .read(messagesProvider.notifier)
        .removeAllMessages(); // Clear messages from provider
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.channelName,
          style: const TextStyle(color: Color(0xFFFFA500)),
        ),
        backgroundColor: const Color(0xFF1E1E1E),
        iconTheme: const IconThemeData(color: Color(0xFFFFA500)),
      ),
      backgroundColor: const Color(0xFF2C2C2C), // Dark Grey Background
      body: Stack(
        children: [
          // Remote users video grid
          GridView.builder(
            padding: const EdgeInsets.only(top: 20),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 3 / 4,
            ),
            itemCount: remoteUsers.keys.length,
            itemBuilder: (context, index) {
              int remoteUid = remoteUsers.keys.elementAt(index);
              return Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E), // Black for remote video
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Expanded(
                      flex: 3,
                      child: AspectRatio(
                        aspectRatio: 3 / 4,
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFF333333), // Darker Grey
                            borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(8)),
                          ),
                          child: remoteUsers[remoteUid] != null
                              ? AgoraVideoView(
                                  controller: VideoViewController.remote(
                                    rtcEngine: _agoraEngine,
                                    canvas: VideoCanvas(uid: remoteUid),
                                    connection: RtcConnection(
                                        channelId: widget.channelName),
                                  ),
                                )
                              : const Center(
                                  child: Text(
                                    "No Video",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E1E1E), // Match footer grey
                          borderRadius: const BorderRadius.vertical(
                              bottom: Radius.circular(8)),
                        ),
                        child: Text(
                          remoteUsers[remoteUid] ?? "Unknown User",
                          style: const TextStyle(
                              color: Colors.white, fontSize: 16),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          Positioned(
            top: _localVideoY,
            left: _localVideoX,
            child: GestureDetector(
              onPanUpdate: (details) {
                setState(() {
                  _localVideoX = details.localPosition.dx;
                  _localVideoY = details.localPosition.dy;
                });
              },
              child: isCameraMuted
                  ? Container(
                      width: screenWidth * 0.4,
                      height: screenHeight * 0.3,
                      color: const Color(0xFF1E1E1E), // Black for muted camera
                      child: Center(
                        child: Text(
                          widget.userName,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    )
                  : Container(
                      width: screenWidth * 0.4,
                      height: screenHeight * 0.3,
                      color: Colors.black,
                      child: AgoraVideoView(
                        controller: VideoViewController(
                          rtcEngine: _agoraEngine,
                          canvas: VideoCanvas(uid: 0),
                        ),
                      ),
                    ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildButton(icon: isMicMuted ? Icons.mic_off : Icons.mic),
            _buildButton(
                icon: isCameraMuted ? Icons.videocam_off : Icons.videocam),
            _buildButton(icon: Icons.chat),
            _buildButton(icon: Icons.exit_to_app, color: Colors.red),
          ],
        ),
      ),
    );
  }

  Widget _buildButton(
      {required IconData icon, Color color = const Color(0xFFFFA500)}) {
    return CircleAvatar(
      radius: 35,
      backgroundColor: const Color(0xFF333333),
      child: Icon(icon, color: color),
    );
  }
}
