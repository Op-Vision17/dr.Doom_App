
import 'package:doctor_doom/appui/meetingscreen2.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uuid/uuid.dart';

// State Providers
final roomNameProvider = StateProvider<String>((ref) => '');
final userNameProvider = StateProvider<String>((ref) => '');

final tokenprovider = StateProvider<String>((ref) => '');

final isMicOnProvider = StateProvider<bool>((ref) => true);
final isVideoOnProvider = StateProvider<bool>((ref) => true);


class JoinMeetingScreen extends ConsumerWidget {
  int generateUuid3Digits() {
    var uuid = Uuid();
    String fullUuid = uuid.v4();
    int hash = fullUuid.hashCode;
    return (hash.abs() % 900 + 100);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final roomName = ref.watch(roomNameProvider);
    final userName = ref.watch(userNameProvider);

    final token = ref.watch(tokenProvider);

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
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) =>
                            MeetingScreen(
                          roomName: roomName,
                          userName: userName,
                          uid: generateUuid3Digits(),
                          isMicOn: isMicOn, // Pass mic state
                          isVideoOn: isVideoOn, // Pass video state
                        ),
                        transitionsBuilder:
                            (context, animation, secondaryAnimation, child) {
                          const begin =
                              Offset(1.0, 0.0); // Slide in from the right
                          const end = Offset.zero;
                          const curve = Curves.easeInOut;

                          var tween = Tween(begin: begin, end: end)
                              .chain(CurveTween(curve: curve));
                          var offsetAnimation = animation.drive(tween);

                          return SlideTransition(
                            position: offsetAnimation,
                            child: child,
                          );
                        },
                      ),
                    );
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
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                onChanged: (value) {
                  ref.read(roomNameProvider.notifier).state = value;
                },
                decoration: InputDecoration(
                  labelText: 'Room Name',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                onChanged: (value) {
                  ref.read(userNameProvider.notifier).state = value;
                },
                decoration: InputDecoration(
                  labelText: 'Your Name',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                onChanged: (value) {
                  ref.read(tokenProvider.notifier).state = value;
                },
                decoration: InputDecoration(
                  labelText: 'Meeting ID',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => Meetingscreen2(
                              roomName: roomName,
                              userName: userName,
                              uid: generateUuid3Digits(),
                              token: token,
                            )),
                  );
                },
                child: Text('Join'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                  textStyle: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ]),
    );
  }
}
