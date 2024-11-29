import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:doctor_doom/agora/apiwork.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class AgoraService {
  static RtcEngine? _engine;
  static const String appId = "2f3131394cc6417b91aa93cfde567a37";
  static List<int> remoteUids = [];
  static String roomName = "";
  static int? _localUid; // Store the UID fetched dynamically
  static bool isVideoMuted = false; // Track local video mute status
  static bool isAudioMuted = false; // Track local audio mute status

  // Check for camera and microphone permissions
  static Future<bool> checkPermissions() async {
    final cameraStatus = await Permission.camera.request();
    final micStatus = await Permission.microphone.request();
    return cameraStatus.isGranted && micStatus.isGranted;
  }

  // Initialize Agora engine and setup
  static Future<void> initializeAgora() async {
    try {
      _engine = await createAgoraRtcEngine();
      await _engine!.initialize(
        RtcEngineContext(
          appId: appId,
          channelProfile: ChannelProfileType.channelProfileCommunication,
        ),
      );

      await _engine!.enableVideo();
      await _engine!.startPreview();

      // Register event handlers
      _engine!.registerEventHandler(
        RtcEngineEventHandler(
          onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
            print("Local user ${connection.localUid} joined channel");
            _localUid = connection.localUid;
          },
          onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
            print("Remote user $remoteUid joined channel");
            if (!remoteUids.contains(remoteUid)) {
              remoteUids.add(remoteUid);
            }
          },
          onUserOffline: (RtcConnection connection, int remoteUid,
              UserOfflineReasonType reason) {
            print("Remote user $remoteUid left channel");
            remoteUids.remove(remoteUid);
          },
          onLeaveChannel: (RtcConnection connection, RtcStats stats) {
            print("Left channel with stats: $stats");
          },
        ),
      );
    } catch (e) {
      print("Error initializing Agora: $e");
      rethrow;
    }
  }

  // Unified join/start meeting function
  static Future<void> joinOrStartMeeting(
      String roomName, String username) async {
    if (_engine == null) {
      throw Exception("Engine not initialized");
    }

    try {
      // Fetch token and UID dynamically
      Map<String, dynamic>? tokendata = await fetchAgoraToken(roomName);
      if (tokendata == null ||
          tokendata['token'] == null ||
          tokendata['uid'] == null) {
        throw Exception("Token or UID generation failed");
      }

      // Store the UID fetched dynamically
      _localUid = tokendata['uid'];

      // Create member (if required by backend)
      await createMember(username, _localUid!, roomName);

      // Join the channel with fetched token and UID
      await _engine!.joinChannel(
        token: tokendata['token'],
        channelId: roomName,
        uid: _localUid!,
        options: ChannelMediaOptions(
          autoSubscribeAudio: true,
          autoSubscribeVideo: true,
          publishCameraTrack: true,
          publishMicrophoneTrack: true,
          clientRoleType: ClientRoleType.clientRoleBroadcaster,
        ),
      );

      print("Successfully joined or started the meeting in room: $roomName");
    } catch (e) {
      print("Error in joinOrStartMeeting: $e");
    }
  }

  // Leave the channel
  static Future<void> leaveChannel(String roomName, String username) async {
    if (_engine == null) {
      print("Error: _engine is not initialized.");
      throw Exception("Engine not initialized");
    }

    try {
      // Ensure `_localUid` is used to leave the meeting
      if (_localUid != null) {
        await leaveMeeting(username, 0, roomName);
      } else {
        print("Error: _localUid is null.");
        throw Exception("Cannot leave meeting: Local UID not set");
      }

      await _engine!.leaveChannel();
    } catch (e) {
      print("Error leaving channel: $e");
    }
  }

  // Mute/Unmute local audio
  static Future<void> muteLocalAudio(bool mute) async {
    if (_engine == null) {
      print("Error: _engine is not initialized.");
      return;
    }
    try {
      await _engine!.muteLocalAudioStream(mute);
      isAudioMuted = mute;
    } catch (e) {
      print("Error muting audio: $e");
    }
  }

  // Mute/Unmute local video
  static Future<void> muteLocalVideo(bool mute) async {
    if (_engine != null) {
      await _engine!.muteLocalVideoStream(mute);
      isVideoMuted = mute;
      if (!mute) {
        await _engine!.startPreview();
      }
    }
  }

  // Local video using fetched UID
  static Widget localVideo(String username) {
    if (_engine != null && _localUid != null) {
      if (isVideoMuted) {
        return Container(
          alignment: Alignment.center,
          color: const Color.fromARGB(255, 31, 31, 31),
          child: Text(
            username,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: const Color.fromARGB(255, 255, 255, 255),
            ),
          ),
        );
      }
      return AgoraVideoView(
        controller: VideoViewController(
          rtcEngine: _engine!,
          canvas: VideoCanvas(uid: 0),
        ),
      );
    } else {
      return const Center(
          child: CircularProgressIndicator(
        color: Colors.white,
      ));
    }
  }

  // Remote video
  static Widget remoteVideos() {
    if (remoteUids.isEmpty) {
      return Center(
        child: Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.blueAccent,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.white, width: 2),
          ),
          child: Text(
            "No remote users in the meeting",
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    }

    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, // Number of videos per row
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: remoteUids.length,
      itemBuilder: (context, index) {
        final uid = remoteUids[index];
        return AgoraVideoView(
          controller: VideoViewController.remote(
            rtcEngine: _engine!,
            canvas: VideoCanvas(uid: uid),
            connection: RtcConnection(channelId: roomName),
          ),
        );
      },
    );
  }

  // Dispose resources
  static Future<void> dispose() async {
    if (_engine == null) {
      print("Error: _engine is not initialized.");
      return;
    }

    try {
      await _engine!.leaveChannel();
      await _engine!.release();
      _engine = null;
    } catch (e) {
      print("Error during dispose: $e");
    }
  }
}
