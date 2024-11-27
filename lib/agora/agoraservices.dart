import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:doctor_doom/agora/apiwork.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class AgoraService {
  static late final RtcEngine _engine;
  static const String appId =
      "<-- Insert app Id -->"; // Replace with your Agora App ID
  static int? _remoteUid;
  static String roomName = ""; // To store the current room name

  // Method to check permissions for camera and microphone
  static Future<bool> checkPermissions() async {
    final cameraStatus = await Permission.camera.request();
    final micStatus = await Permission.microphone.request();
    return cameraStatus.isGranted && micStatus.isGranted;
  }

  // Method to initialize the Agora RTC engine
  static Future<void> initializeAgora() async {
    // Create an instance of RtcEngine using createAgoraRtcEngine
    _engine = await createAgoraRtcEngine();

    // Initialize RtcEngine and set the channel profile to communication
    await _engine.initialize(
      RtcEngineContext(
        appId: appId,
        channelProfile: ChannelProfileType.channelProfileCommunication,
      ),
    );

    // Enable the video module
    await _engine.enableVideo();

    // Start the local video preview
    await _engine.startPreview();

    // Register event handler for various events
    _engine.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          print("Local user ${connection.localUid} joined channel");
        },
        onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
          print("Remote user $remoteUid joined channel");
          _remoteUid = remoteUid;
        },
        onUserOffline: (RtcConnection connection, int remoteUid,
            UserOfflineReasonType reason) {
          print("Remote user $remoteUid left channel");
          _remoteUid = null;
        },
        // Corrected onLeaveChannel handler with two parameters
        onLeaveChannel: (RtcConnection connection, RtcStats stats) {
          print("Left channel with stats: $stats");
        },
      ),
    );
  }

  // Method to join the Agora channel with dynamic token and room name
  static Future<void> joinChannel(String roomName, String username) async {
    // First, create or fetch the member for the room
    await createMember(username, 0, roomName);

    // Generate the token from the API
    String? token = await fetchAgoraToken(roomName);

    if (token == null) {
      print("Error: Token generation failed");
      return;
    }

    // Join the channel with the token
    await _engine.joinChannel(
      token: token, // Passing token as named parameter
      channelId: roomName, // Pass roomName as the channelId
      uid: 0, // 0 means the engine will automatically assign a user ID
      options: ChannelMediaOptions(
        autoSubscribeAudio: true,
        autoSubscribeVideo: true,
        publishCameraTrack: true,
        publishMicrophoneTrack: true,
        clientRoleType: ClientRoleType.clientRoleBroadcaster,
      ),
    );
  }

  // Method to leave the Agora channel and remove the member from the room
  static Future<void> leaveChannel(String roomName, String username) async {
    // Call API to delete the member from the server
    await leaveMeeting(username, 0, roomName);

    // Leave the Agora channel
    await _engine.leaveChannel();
  }

  // Method to mute/unmute local audio stream
  static Future<void> muteLocalAudio(bool mute) async {
    await _engine.muteLocalAudioStream(mute);
  }

  // Method to mute/unmute local video stream
  static Future<void> muteLocalVideo(bool mute) async {
    await _engine.muteLocalVideoStream(mute);
  }

  // Method to display the remote video stream
  static Widget remoteVideo() {
    if (_remoteUid != null) {
      return AgoraVideoView(
        controller: VideoViewController.remote(
          rtcEngine: _engine,
          canvas: VideoCanvas(uid: _remoteUid),
          connection: RtcConnection(channelId: roomName),
        ),
      );
    } else {
      return const Text(
        'Please wait for remote user to join',
        textAlign: TextAlign.center,
      );
    }
  }

  // Dispose method to clean up when leaving the screen or app
  static Future<void> dispose() async {
    await _engine.leaveChannel(); // Leave the channel
    await _engine.release(); // Release resources
  }
}
