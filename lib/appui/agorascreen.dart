import 'package:doctor_doom/agora/apiwork.dart';
import 'package:flutter/material.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';

class AgoraScreen extends StatefulWidget {
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

class _AgoraScreenState extends State<AgoraScreen> {
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

    await _agoraEngine.joinChannel(
      token: widget.token,
      channelId: widget.channelName,
      uid: widget.uid,
      options: ChannelMediaOptions(
        channelProfile: ChannelProfileType.channelProfileCommunication,
        clientRoleType: ClientRoleType.clientRoleBroadcaster,
      ),
    );

    // Set the mic and camera mute status according to the initial values
    await _agoraEngine.muteLocalAudioStream(isMicMuted);
    await _agoraEngine.muteLocalVideoStream(isCameraMuted);
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
          GridView.builder(
            padding: EdgeInsets.only(top: 170),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
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
                      height: 180,
                      width: double.infinity,
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
                              child: Center(child: Text("No Video"))),
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
                      width: 150,
                      height: 150,
                      color: Colors.black,
                      child: Center(
                        child: Text(
                          widget.userName,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    )
                  : Container(
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
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: Icon(isMicMuted ? Icons.mic_off : Icons.mic),
              onPressed: () async {
                setState(() {
                  isMicMuted = !isMicMuted;
                });
                await _agoraEngine.muteLocalAudioStream(isMicMuted);
              },
              color: Colors.blue,
            ),
            IconButton(
              icon: Icon(isCameraMuted ? Icons.videocam_off : Icons.videocam),
              onPressed: () async {
                setState(() {
                  isCameraMuted = !isCameraMuted;
                });
                await _agoraEngine.muteLocalVideoStream(isCameraMuted);
              },
              color: Colors.blue,
            ),
            IconButton(
              icon: Icon(Icons.exit_to_app),
              onPressed: () async {
                await _agoraEngine.leaveChannel();
                await _agoraEngine.release();
                Navigator.pop(context);
              },
              color: Colors.red,
            ),
          ],
        ),
      ),
    );
  }
}
