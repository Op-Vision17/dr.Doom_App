// import 'dart:async';
// import 'package:agora_rtc_engine/agora_rtc_engine.dart';
// import 'package:flutter/material.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:http/http.dart' as http;

// const String appId = "<-- Insert App ID -->";
// const String channel = "<-- Insert Channel Name -->";

// // Example for getting a token from your backend
// Future<String> fetchToken() async {
//   final response = await http
//       .get(Uri.parse('https://yourbackend.com/getToken?channel=$channel'));
//   if (response.statusCode == 200) {
//     return response.body; // Assuming the token is returned as a plain string
//   } else {
//     throw Exception('Failed to fetch token');
//   }
// }

// class VideoCallScreen extends StatefulWidget {
//   @override
//   _VideoCallScreenState createState() => _VideoCallScreenState();
// }

// class _VideoCallScreenState extends State<VideoCallScreen> {
//   late RtcEngine _engine;
//   bool _localUserJoined = false;
//   List<int> _remoteUids = []; // List to track remote users' UIDs

//   @override
//   void initState() {
//     super.initState();
//     _initAgora();
//   }

//   Future<void> _initAgora() async {
//     // Request permissions
//     await [Permission.microphone, Permission.camera].request();

//     // Fetch token from the backend
//     String token = await fetchToken();

//     // Create Agora engine instance
//     _engine = await createAgoraRtcEngine();
//     await _engine.initialize(RtcEngineContext(appId: appId));

//     // Add event handlers
//     _engine.registerEventHandler(RtcEngineEventHandler(
//       onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
//         setState(() {
//           _localUserJoined = true;
//         });
//       },
//       onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
//         setState(() {
//           _remoteUids.add(remoteUid); // Add remote user to the list
//         });
//       },
//       onUserOffline: (RtcConnection connection, int remoteUid,
//           UserOfflineReasonType reason) {
//         setState(() {
//           _remoteUids
//               .remove(remoteUid); // Remove user from the list when they leave
//         });
//       },
//     ));

//     // Enable video
//     await _engine.enableVideo();
//     await _engine.startPreview();

//     // Join the channel
//     await _engine.joinChannel(
//       token: token,
//       channelId: channel,
//       options: ChannelMediaOptions(
//         autoSubscribeVideo: true,
//         autoSubscribeAudio: true,
//         publishCameraTrack: true,
//         publishMicrophoneTrack: true,
//         clientRoleType: ClientRoleType
//             .clientRoleBroadcaster, // Allow all users to broadcast
//       ),
//       uid: 0, // Automatically assign UID
//     );
//   }

//   @override
//   void dispose() {
//     super.dispose();
//     _dispose();
//   }

//   Future<void> _dispose() async {
//     await _engine.leaveChannel();
//     await _engine.release();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Agora Video Call')),
//       body: Stack(
//         children: [
//           // List to display remote videos
//           Positioned.fill(
//             child: _remoteUids.isEmpty
//                 ? Center(child: Text('Waiting for remote users...'))
//                 : GridView.builder(
//                     gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//                       crossAxisCount:
//                           2, // Adjust the number of columns for remote videos
//                     ),
//                     itemCount: _remoteUids.length,
//                     itemBuilder: (context, index) {
//                       return AgoraVideoView(
//                         controller: VideoViewController.remote(
//                           rtcEngine: _engine,
//                           canvas: VideoCanvas(uid: _remoteUids[index]),
//                           connection: RtcConnection(channelId: channel),
//                         ),
//                       );
//                     },
//                   ),
//           ),
//           Align(
//             alignment: Alignment.topLeft,
//             child: SizedBox(
//               width: 100,
//               height: 150,
//               child: Center(
//                 child: _localUserJoined
//                     ? AgoraVideoView(
//                         controller: VideoViewController(
//                           rtcEngine: _engine,
//                           canvas: VideoCanvas(uid: 0),
//                         ),
//                       )
//                     : CircularProgressIndicator(),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
