import 'dart:convert';
import 'package:doctor_doom/appui/agorascreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

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
      backgroundColor: const Color.fromARGB(255, 233, 201, 152),
      appBar: AppBar(
        backgroundColor: const Color(0xFF333333), // Dark Grey
        title: Text(
          "Join Meeting",
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
      body: Stack(
        children: [
          // Gradient Background with Wave Clipper
          ClipPath(
            clipper: WaveClipper(),
            child: Container(
              height: MediaQuery.of(context).size.height * 0.45,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF232323), // Dark Grey
                    Color(0xFF121212), // Black
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),

          // Centered Join Meeting Container
          Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF2C2C2C), // Dark Grey container
                    borderRadius: BorderRadius.circular(16.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 20),

                      // Room Name Input with Prefix Icon
                      buildTextField(
                        label: "Room Name",
                        icon: Icons.meeting_room,
                        onChanged: (value) =>
                            ref.read(roomNameProvider.notifier).state = value,
                      ),
                      const SizedBox(height: 20),

                      // User Name Input with Prefix Icon
                      buildTextField(
                        label: "Your Name",
                        icon: Icons.person,
                        onChanged: (value) =>
                            ref.read(userNameProvider.notifier).state = value,
                      ),
                      const SizedBox(height: 20),

                      // Mic Toggle
                      buildToggleRow(
                        label: 'Don\'t connect to audio',
                        value: isMicOn,
                        onChanged: (value) =>
                            ref.read(isMicOnProvider.notifier).state = value,
                      ),
                      const SizedBox(height: 20),

                      // Video Toggle
                      buildToggleRow(
                        label: 'Turn off my video',
                        value: isVideoOn,
                        onChanged: (value) =>
                            ref.read(isVideoOnProvider.notifier).state = value,
                      ),
                      const SizedBox(height: 30),

                      // Join Meeting Button
                      ElevatedButton(
                        onPressed: () async {
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
                                    isCameraMuted: isVideoOn,
                                    isMicMuted: isMicOn,
                                  ),
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content:
                                        Text('Failed to fetch Agora token')),
                              );
                            }
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Please fill all fields')),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color.fromARGB(255, 232, 167, 48), // Orange
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                        ),
                        child: Text(
                          "Join",
                          style: GoogleFonts.roboto(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildTextField({
    required String label,
    required IconData icon,
    required Function(String) onChanged,
  }) {
    return TextField(
      onChanged: onChanged,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white),
        border: const OutlineInputBorder(),
        filled: true,
        fillColor: Colors.white.withOpacity(0.1),
        prefixIcon: Icon(
          icon,
          color: const Color.fromARGB(255, 232, 167, 48), // Orange Icon
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(
            color: Color.fromARGB(255, 232, 167, 48),
            width: 2.0,
          ),
        ),
      ),
    );
  }

  Widget buildToggleRow({
    required String label,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white, fontSize: 18),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: const Color.fromARGB(255, 232, 167, 48), // Orange switch
        ),
      ],
    );
  }
}

// Custom Clipper for Gradient Wave
class WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height - 50);
    path.quadraticBezierTo(
        size.width / 2, size.height, size.width, size.height - 50);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return false;
  }
}
