import 'package:doctor_doom/agora/apiwork.dart';
import 'package:flutter/material.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';

class AgoraScreen extends StatefulWidget {
  final String appId;
  final String token;
  final String channelName;
  final int uid;
  final String userName;

  const AgoraScreen({
    required this.appId,
    required this.token,
    required this.channelName,
    required this.uid,
    required this.userName,
  });

  @override
  _AgoraScreenState createState() => _AgoraScreenState();
}

class _AgoraScreenState extends State<AgoraScreen> {
  late RtcEngine _agoraEngine;
  bool _isMicMuted = false;
  bool _isCameraMuted = false;
  Map<int, String?> remoteUsers = {};
  late int localUid;

  double _localVideoX = 10.0; // Position of the local video container
  double _localVideoY = 10.0;

  @override
  void initState() {
    super.initState();
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

    _agoraEngine.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int uid) {
          setState(() {
            localUid = uid;
          });
          print("Joined channel successfully: UID = $uid");
          createMember(widget.userName, widget.uid, widget.channelName);
        },
        onUserJoined:
            (RtcConnection connection, int remoteUid, int elapsed) async {
          print("Remote user joined: UID = $remoteUid");
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
          print("Remote user offline: UID = $remoteUid");
          setState(() {
            remoteUsers.remove(remoteUid);
          });
        },
      ),
    );

    await _agoraEngine.joinChannel(
      token: widget.token,
      channelId: widget.channelName,
      uid: widget.uid,
      options: ChannelMediaOptions(
        channelProfile: ChannelProfileType.channelProfileCommunication,
        clientRoleType: ClientRoleType.clientRoleBroadcaster,
      ),
    );
  }

  Future<void> toggleMic() async {
    setState(() {
      _isMicMuted = !_isMicMuted;
    });
    await _agoraEngine.muteLocalAudioStream(_isMicMuted);
  }

  Future<void> toggleCamera() async {
    setState(() {
      _isCameraMuted = !_isCameraMuted;
    });
    await _agoraEngine.muteLocalVideoStream(_isCameraMuted);
  }

  @override
  void dispose() {
    _agoraEngine.leaveChannel();
    _agoraEngine.release();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.channelName)),
      body: Stack(
        children: [
          // Remote Users Video Views in a Grid
          GridView.builder(
            padding: EdgeInsets.only(top: 170), // Space for the local video
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, // Set the number of columns in the grid
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: remoteUsers.keys.length,
            itemBuilder: (context, index) {
              int remoteUid = remoteUsers.keys.elementAt(index);
              return Container(
                color: Colors.black,
                child: Column(
                  children: [
                    Text(
                      remoteUsers[remoteUid] ?? "Unknown User",
                      style: TextStyle(color: Colors.white),
                    ),
                    Container(
                      height: 150,
                      child: remoteUsers[remoteUid] != null
                          ? AgoraVideoView(
                              controller: VideoViewController.remote(
                                rtcEngine: _agoraEngine,
                                canvas: VideoCanvas(uid: remoteUid),
                                connection: RtcConnection(
                                    channelId: widget.channelName),
                              ),
                            )
                          : Container(
                              color: Colors.grey,
                              child: Center(child: Text("No Video")),
                            ),
                    ),
                  ],
                ),
              );
            },
          ),

          // Local Video View (Draggable)
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
              child: Container(
                width: 150,
                height: 150,
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
      bottomNavigationBar: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton(
            icon: Icon(_isMicMuted ? Icons.mic_off : Icons.mic),
            onPressed: toggleMic,
          ),
          IconButton(
            icon: Icon(_isCameraMuted ? Icons.videocam_off : Icons.videocam),
            onPressed: toggleCamera,
          ),
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: () async {
              // Leave the Agora channel when exiting
              await _agoraEngine.leaveChannel();

              // Optionally release resources
              await _agoraEngine.release();

              // Pop the screen and return to the previous screen
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
