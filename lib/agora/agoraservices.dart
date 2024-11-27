import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'apiwork.dart'; // Ensure the file with fetchAgoraToken is imported here

// Define the MeetingState model to hold token, uid, and meetingJoined status
class MeetingState {
  final String token;
  final int? uid;
  final bool meetingJoined;

  MeetingState({
    required this.token,
    this.uid,
    required this.meetingJoined,
  });

  // CopyWith method to create a new instance with updated values
  MeetingState copyWith({
    String? token,
    int? uid,
    bool? meetingJoined,
  }) {
    return MeetingState(
      token: token ?? this.token,
      uid: uid ?? this.uid,
      meetingJoined: meetingJoined ?? this.meetingJoined,
    );
  }
}

// Provider for managing the meeting state
final meetingStateProvider = StateProvider<MeetingState>((ref) {
  return MeetingState(
    token: '',
    uid: null,
    meetingJoined: false,
  );
});

// Provider for storing the room name
final roomNameProvider = StateProvider<String>((ref) => '');

// Provider for storing the user name
final userNameProvider = StateProvider<String>((ref) => '');

// Provider for storing mute status
final muteProvider = StateProvider<bool>((ref) => false);

// Provider for storing camera off status
final cameraProvider = StateProvider<bool>((ref) => false);

// Provider for the meeting service (handles fetching the token and joining the channel)
final meetingServiceProvider = FutureProvider.autoDispose<void>((ref) async {
  final roomName = ref.watch(roomNameProvider);
  final userName = ref.watch(userNameProvider);

  // Fetch the token for Agora
  final tokendata = await fetchAgoraToken(roomName);

  // If token is invalid, throw an exception
  if (tokendata == null || tokendata.isEmpty) {
    throw Exception('Token fetch failed');
  }

  // Update the meeting state provider with the token and UID
  ref.read(meetingStateProvider.notifier).state = MeetingState(
    token: tokendata['token'],
    uid: tokendata['uid'],
    meetingJoined: true,
  );

  // Initialize Agora service
  await AgoraService.initializeAgora();
  await AgoraService.joinChannel(
    roomName,
    userName,
  );
});

// Provider for storing the user UID
final meetingUidProvider = StateProvider<int?>((ref) => null);

// Provider for storing the meeting joined status
final meetingJoinedProvider = StateProvider<bool>((ref) => false);

class AgoraService {
  static late final RtcEngine _engine;
  static const String appId =
      "2f3131394cc6417b91aa93cfde567a37"; // Replace with your Agora App ID
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
    _engine = await createAgoraRtcEngine();

    await _engine.initialize(
      RtcEngineContext(
        appId: appId,
        channelProfile: ChannelProfileType.channelProfileCommunication,
      ),
    );

    await _engine.enableVideo();
    await _engine.startPreview();

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
        onLeaveChannel: (RtcConnection connection, RtcStats stats) {
          print("Left channel with stats: $stats");
        },
      ),
    );
  }

  // Method to join the Agora channel with dynamic token and room name
  static Future<void> joinChannel(String roomName, String username) async {
    try {
      await createMember(username, 0, roomName);
      Map<String, dynamic>? tokendata = await fetchAgoraToken(roomName);

      if (tokendata == null) {
        throw Exception("Token generation failed");
      }

      await _engine.joinChannel(
        token: tokendata['token'],
        channelId: roomName,
        uid: tokendata['uid'],
        options: ChannelMediaOptions(
          autoSubscribeAudio: true,
          autoSubscribeVideo: true,
          publishCameraTrack: true,
          publishMicrophoneTrack: true,
          clientRoleType: ClientRoleType.clientRoleBroadcaster,
        ),
      );
    } catch (e) {
      print("Error joining channel: $e");
    }
  }

  // Method to leave the Agora channel and remove the member from the room
  static Future<void> leaveChannel(String roomName, String username) async {
    try {
      await leaveMeeting(username, 0, roomName);
      await _engine.leaveChannel();
    } catch (e) {
      print("Error leaving channel: $e");
    }
  }

  // Method to mute/unmute local audio stream
  static Future<void> muteLocalAudio(bool mute) async {
    try {
      await _engine.muteLocalAudioStream(mute);
    } catch (e) {
      print("Error muting audio: $e");
    }
  }

  // Method to mute/unmute local video stream
  static Future<void> muteLocalVideo(bool mute) async {
    try {
      await _engine.muteLocalVideoStream(mute);
    } catch (e) {
      print("Error muting video: $e");
    }
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
    try {
      await _engine.leaveChannel();
      await _engine.release();
    } catch (e) {
      print("Error during dispose: $e");
    }
  }
}
