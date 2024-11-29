import 'dart:convert';
import 'package:doctor_doom/appui/agorascreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:http/http.dart' as http; // Required for fetchAgoraToken()

// State Providers
final roomNameProvider = StateProvider<String>((ref) => '');
final userNameProvider = StateProvider<String>((ref) => '');
final isMicOnProvider = StateProvider<bool>((ref) => true);
final isVideoOnProvider = StateProvider<bool>((ref) => true);

// Predefined function to fetch token
Future<Map<String, dynamic>?> fetchAgoraToken(String roomName) async {
  const String apiUrl = 'https://agora-8ojc.onrender.com/get_token/';

  try {
    final response = await http.get(
      Uri.parse('$apiUrl?channel=$roomName'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final token = data['token'];
      final int uid = data['uid'];
      return {'token': token, 'uid': uid};
    } else {
      print('Error: ${response.body}');
      return null;
    }
  } catch (e) {
    print('Failed to fetch Agora token: $e');
    return null;
  }
}

class Joinmeeting2 extends ConsumerWidget {
  const Joinmeeting2({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final roomName = ref.watch(roomNameProvider);
    final userName = ref.watch(userNameProvider);
    final isMicOn = ref.watch(isMicOnProvider);
    final isVideoOn = ref.watch(isVideoOnProvider);

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background Image
          Image.asset(
            'assets/loginbackground.jpg', // Replace with your background image
            fit: BoxFit.cover,
          ),
          // Semi-transparent overlay
          Container(
            color: Colors.black.withOpacity(0.6),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Title
                Text(
                  "Join Meeting",
                  style: GoogleFonts.kablammo(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: const Color.fromRGBO(202, 239, 184, 1),
                    shadows: [
                      Shadow(
                        color: const Color.fromARGB(255, 188, 232, 190)
                            .withOpacity(0.5),
                        offset: const Offset(2, 2),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  textAlign: TextAlign.start,
                ),
                const SizedBox(height: 30),
                // Room Name Input
                TextField(
                  onChanged: (value) {
                    ref.read(roomNameProvider.notifier).state = value;
                  },
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.2),
                    hintText: 'Enter Room Name',
                    hintStyle: const TextStyle(color: Colors.white70),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.done,
                ),
                const SizedBox(height: 20),
                // User Name Input
                TextField(
                  onChanged: (value) {
                    ref.read(userNameProvider.notifier).state = value;
                  },
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.2),
                    hintText: 'Enter Your Name',
                    hintStyle: const TextStyle(color: Colors.white70),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.done,
                ),
                const SizedBox(height: 20),
                // Mic Toggle
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Don\'t connect to audio',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                    Switch(
                      value: isMicOn,
                      onChanged: (value) {
                        ref.read(isMicOnProvider.notifier).state = value;
                      },
                      activeColor: Colors.green,
                    ),
                  ],
                ),
                // Video Toggle
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Turn off my video',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                    Switch(
                      value: isVideoOn,
                      onChanged: (value) {
                        ref.read(isVideoOnProvider.notifier).state = value;
                      },
                      activeColor: Colors.green,
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                // Join Meeting Button
                GestureDetector(
                  onTap: () async {
                    if (userName.isNotEmpty && roomName.isNotEmpty) {
                      final tokenData = await fetchAgoraToken(roomName);
                      if (tokenData != null) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AgoraScreen(
                              appId: '2f3131394cc6417b91aa93cfde567a37',
                              channelName: roomName,
                              token: tokenData['token'],
                              uid: tokenData['uid'],
                              userName: userName,
                            ),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Failed to fetch Agora token')),
                        );
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please fill all fields')),
                      );
                    }
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        vertical: 15, horizontal: 20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Colors.green, Colors.lightGreen],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text(
                        'Join',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
