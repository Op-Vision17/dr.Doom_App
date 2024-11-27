// import 'package:flutter/material.dart';
// import 'package:agora_uikit/agora_uikit.dart';

// class VideoScreen extends StatefulWidget {
//   final String appId;
//   final String channelName;
//   final String token; // Optional if you use a token-based system
//   const VideoScreen({
//     Key? key,
//     required this.appId,
//     required this.channelName,
//     required this.token,
//   }) : super(key: key);

//   @override
//   _VideoScreenState createState() => _VideoScreenState();
// }

// class _VideoScreenState extends State<VideoScreen> {
//   late AgoraClient client;

//   @override
//   void initState() {
//     super.initState();
//     client = AgoraClient(
//       agoraConnectionData: AgoraConnectionData(
//         appId: widget.appId,
//         channelName: widget.channelName,
//         tempToken: widget.token,
//       ),
//     );

//     initAgora();
//   }

//   Future<void> initAgora() async {
//     await client.initialize();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Video Call"),
//       ),
//       body: SafeArea(
//         child: Stack(
//           children: [
//             AgoraVideoViewer(
//               client: client,
//               layoutType: Layout.grid,
//             ),
//             AgoraVideoButtons(
//               client: client,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
