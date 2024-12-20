// import 'package:doctor_doom/recording/agorarecording.dart';
import 'package:doctor_doom/appui/membersscreen.dart';
import 'package:doctor_doom/chat/aichat.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:doctor_doom/agora/apiwork.dart';
import 'package:doctor_doom/chat/chatprovider.dart';
import 'package:doctor_doom/chat/chatscreen.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

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
  bool _isFullScreen = false;
  bool isMicMuted = false;
  bool isCameraMuted = false;
  bool isRecording = false;
  bool showEmojiPicker = false;
  String? selectedEmoji;
  String? emojiWithUserName;
  List<String> emojiMessages = [];

  double _localVideoX = 10.0;
  double _localVideoY = 10.0;

  // String? resourceId;
  // String? sid;

  // late AgoraRecording _recording;

  @override
  void initState() {
    super.initState();
    isMicMuted = widget.isMicMuted;
    isCameraMuted = widget.isCameraMuted;
    WakelockPlus.enable();
    _checkPermissions().then((granted) {
      if (granted) {
        initAgora();
      } else {
        _showPermissionError();
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _localVideoX = MediaQuery.of(context).size.width - 180;
        _localVideoY = MediaQuery.of(context).size.height - 430;
      });
    });
  }

  Future<bool> _checkPermissions() async {
    final statuses = await [
      Permission.camera,
      Permission.microphone,
    ].request();

    return statuses[Permission.camera]!.isGranted &&
        statuses[Permission.microphone]!.isGranted;
  }

  void _showPermissionError() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Permissions Required"),
        content: Text(
            "Please grant camera and microphone permissions to use this feature."),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text("OK"),
          ),
        ],
      ),
    );
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
          // _acquireRecordingResource();
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
        // onLeaveChannel: (RtcConnection connection, RtcStats stats) {
        //   if (isRecording) {
        //     _stopRecording();
        //   }
        // },
      ),
    );

    await _agoraEngine.muteLocalAudioStream(isMicMuted);
    await _agoraEngine.muteLocalVideoStream(isCameraMuted);
  }

  @override
  void dispose() {
    _agoraEngine.leaveChannel();
    _agoraEngine.release();
    WakelockPlus.disable();
    // if (isRecording) {
    //   _stopRecording();
    // }
    super.dispose();
  }

  void _clearChatMessages(String channelname) {
    ref.read(messagesProvider(channelname).notifier).removeAllMessages();
  }

  void _clearaimessages() {
    ref.read(chatProvider.notifier).deleteAllMessages();
  }

  Future<bool> _showExitConfirmationDialog(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Exit'),
            content: Text('Do you want to leave the meet?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text('Leave'),
              ),
            ],
          ),
        ) ??
        false;
  }

  Future<void> _switchCamera() async {
    await _agoraEngine.switchCamera();
  }

  void _toggleEmojiPicker() {
    setState(() {
      showEmojiPicker = !showEmojiPicker;
    });
    print("Emoji picker dabaya: $showEmojiPicker");
  }

  void _onEmojiSelected(Emoji emoji) {
    setState(() {
      selectedEmoji = emoji.emoji;

      emojiMessages.add("${widget.userName} $selectedEmoji");
    });

    Future.delayed(Duration(seconds: 5), () {
      setState(() {
        emojiMessages.removeAt(0);
      });
    });
  }

  // Future<void> _acquireRecordingResource() async {
  //   try {
  //     resourceId = await _recording.acquireResource(widget.channelName);
  //     print('resource hogya $resourceId');
  //     if (resourceId != null) {
  //       setState(() {
  //         isRecording = true;
  //       });
  //       _startRecording();
  //     }
  //   } catch (e) {
  //     print("Error acquiring recording resource: $e");
  //   }
  // }

  // Future<void> _startRecording() async {
  //   if (resourceId != null) {
  //     try {
  //       sid = await _recording.startRecording(resourceId!, widget.channelName);
  //       print('sid hogya $sid');
  //     } catch (e) {
  //       print("Error starting recording: $e");
  //     }
  //   }
  // }

  // Future<void> _stopRecording() async {
  //   if (resourceId != null && sid != null) {
  //     try {
  //       await _recording.stopRecording(resourceId!, sid!, widget.channelName);
  //       print("Recording stopped");
  //     } catch (e) {
  //       print("Error stopping recording: $e");
  //     }
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return WillPopScope(
      onWillPop: () async {
        bool shouldLeave = await _showExitConfirmationDialog(context);
        return shouldLeave;
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color.fromARGB(255, 226, 166, 55),
          title: Text(
            "Meeting:${widget.channelName}",
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Aichat(
                        username: widget.userName,
                        channelname: widget.channelName,
                      ),
                    ),
                  );
                },
                style: TextButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 255, 223, 186),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: Text(
                  "DOOM's AI",
                  style: GoogleFonts.rampartOne(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
            ),
          ],
        ),
        body: Stack(
          children: [
            GridView.builder(
              padding: EdgeInsets.only(top: 20),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 3 / 4,
              ),
              itemCount: remoteUsers.keys.length,
              itemBuilder: (context, index) {
                int remoteUid = remoteUsers.keys.elementAt(index);
                print('Displaying video for remoteUid: $remoteUid');
                return Container(
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 237, 216, 139),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Padding(
                          padding: EdgeInsets.only(
                            top: 10,
                            right: 10,
                            left: 10,
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(255, 225, 217, 147),
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(10),
                              ),
                            ),
                            child: remoteUsers[remoteUid] != null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.vertical(
                                        top: Radius.circular(10)),
                                    child: AspectRatio(
                                      aspectRatio: 3 / 4,
                                      child: AgoraVideoView(
                                        controller: VideoViewController.remote(
                                          rtcEngine: _agoraEngine,
                                          canvas: VideoCanvas(uid: remoteUid),
                                          connection: RtcConnection(
                                              channelId: widget.channelName),
                                        ),
                                      ),
                                    ),
                                  )
                                : Center(
                                    child: Text(
                                      "No Video",
                                      style: TextStyle(color: Colors.black),
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
                            color: Color.fromARGB(255, 233, 210, 135),
                            borderRadius: BorderRadius.vertical(
                                bottom: Radius.circular(10)),
                          ),
                          child: Text(
                            remoteUsers[remoteUid] ?? "Unknown User",
                            style: TextStyle(color: Colors.white, fontSize: 16),
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
              top: _isFullScreen ? 0 : _localVideoY,
              left: _isFullScreen ? 0 : _localVideoX,
              child: GestureDetector(
                onPanUpdate: (details) {
                  if (!_isFullScreen) {
                    setState(() {
                      _localVideoX = (_localVideoX + details.delta.dx)
                          .clamp(0.0, MediaQuery.of(context).size.width - 150);
                      _localVideoY = (_localVideoY + details.delta.dy)
                          .clamp(0.0, MediaQuery.of(context).size.height - 250);
                    });
                  }
                },
                onDoubleTap: () {
                  setState(() {
                    _isFullScreen = !_isFullScreen;
                    if (_isFullScreen) {
                      _localVideoX = 0;
                      _localVideoY = 0;
                    }
                  });
                },
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 300),
                  width: _isFullScreen
                      ? MediaQuery.of(context).size.width
                      : screenWidth * 0.4,
                  height: _isFullScreen
                      ? MediaQuery.of(context).size.height
                      : screenHeight * 0.3,
                  color: const Color.fromARGB(255, 238, 238, 221),
                  child: isCameraMuted
                      ? Center(
                          child: Text(
                            widget.userName,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                      : AgoraVideoView(
                          controller: VideoViewController(
                            rtcEngine: _agoraEngine,
                            canvas: VideoCanvas(uid: 0),
                          ),
                        ),
                ),
              ),
            ),
            for (int i = 0; i < emojiMessages.length; i++)
              Positioned(
                top: 20 + (i * 40),
                right: 20,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Color.fromARGB(255, 237, 216, 139),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    emojiMessages[i],
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            if (showEmojiPicker)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  child: EmojiPicker(
                    onEmojiSelected: (category, emoji) {
                      _onEmojiSelected(emoji);
                    },
                  ),
                ),
              ),
            Positioned(
              bottom: 15.0,
              right: screenWidth * 0.4 - 138,
              child: GestureDetector(
                onTap: () {
                  _agoraEngine.switchCamera();
                },
                child: _buildButton(
                  icon: Icons.cameraswitch_outlined,
                  isActive: false,
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
              GestureDetector(
                onTap: () async {
                  setState(() {
                    isMicMuted = !isMicMuted;
                  });
                  await _agoraEngine.muteLocalAudioStream(isMicMuted);
                },
                child: _buildButton(
                  icon: isMicMuted ? Icons.mic_off : Icons.mic,
                  isActive: !isMicMuted,
                ),
              ),
              GestureDetector(
                onTap: () async {
                  setState(() {
                    isCameraMuted = !isCameraMuted;
                  });
                  await _agoraEngine.muteLocalVideoStream(isCameraMuted);
                },
                child: _buildButton(
                  icon: isCameraMuted ? Icons.videocam_off : Icons.videocam,
                  isActive: !isCameraMuted,
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => MemberScreen(
                              username: widget.userName,
                              channelName: widget.channelName,
                              remoteUsers: remoteUsers,
                            )),
                  );
                },
                child: _buildButton(
                  icon: Icons.person_2_rounded,
                  isActive: true,
                ),
              ),
              GestureDetector(
                onTap: () {
                  print("Emoji button dabaya");
                  _toggleEmojiPicker();
                },
                child: _buildButton(
                  icon: Icons.emoji_emotions,
                  isActive: true,
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ChatScreen(
                              username: widget.userName,
                              channelname: widget.channelName,
                            )),
                  );
                },
                child: _buildButton(
                  icon: Icons.chat,
                  isActive: true,
                ),
              ),
              GestureDetector(
                onTap: () async {
                  bool shouldLeave = await _showExitConfirmationDialog(context);
                  if (shouldLeave) {
                    _clearChatMessages(widget.channelName);
                    _clearaimessages();
                    Navigator.pop(context);
                  }
                },
                child: _buildButton(
                  icon: Icons.exit_to_app,
                  isActive: true,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildButton({required IconData icon, required bool isActive}) {
    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isActive ? Color.fromARGB(255, 241, 204, 130) : Colors.grey[300],
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        size: 30,
        color: isActive ? Colors.black : Colors.grey[600],
      ),
    );
  }
}
