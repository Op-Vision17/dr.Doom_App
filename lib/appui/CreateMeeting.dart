import 'package:doctor_doom/appui/videocallScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:doctor_doom/appui/videocallScreen.dart';

final roomNameProvider = StateProvider<String?>((ref) => null);
final userNameProvider = StateProvider<String?>((ref) => null);

class CreateMeetingScreen extends ConsumerWidget {
  const CreateMeetingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final roomNameController = TextEditingController();
    final userNameController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Create Meeting"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Enter your name",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: userNameController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Your name",
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "Enter room name",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: roomNameController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Room name",
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  final roomName = roomNameController.text.trim();
                  final userName = userNameController.text.trim();

                  if (roomName.isNotEmpty && userName.isNotEmpty) {
                    // Save room name and user name in providers
                    ref.read(roomNameProvider.notifier).state = roomName;
                    ref.read(userNameProvider.notifier).state = userName;

                    // Navigate to VideoCallScreen
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => VideoCallScreen(),
                      ),
                    );
                  }
                },
                child: const Text("Create Room"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
