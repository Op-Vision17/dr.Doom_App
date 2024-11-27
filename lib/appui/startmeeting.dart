import 'package:doctor_doom/agora/agoraservices.dart';
import 'package:doctor_doom/appui/meetingscreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

final roomNameProvider = StateProvider<String>((ref) => '');
final userNameProvider = StateProvider<String>((ref) => '');

class Startmeeting extends ConsumerWidget {
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

    return Scaffold(
      appBar: AppBar(
        title: Text('Start Meeting'),
        backgroundColor: Colors.teal,
      ),
      body: Stack(children: [
        Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/loginbackground.jpg"),
              fit: BoxFit.cover,
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
              SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  meetingServiceProvider;
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => MeetingScreen(
                              roomName: roomName,
                              userName: userName,
                              uid: generateUuid3Digits(),
                            )),
                  );
                },
                child: Text('Start'),
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
