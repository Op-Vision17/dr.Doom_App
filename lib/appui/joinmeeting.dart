import 'package:doctor_doom/appui/meetingscreen.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

final roomNameProvider = StateProvider<String>((ref) => '');
final userNameProvider = StateProvider<String>((ref) => '');

class JoinMeetingScreen extends ConsumerWidget {
  int generateUuid3Digits() {
    var uuid = Uuid();
    String fullUuid = uuid.v4();
    int hash = fullUuid.hashCode;
    return (hash.abs() % 900 + 100);
  }

  // Future<void> joinmeeting(BuildContext context, WidgetRef ref) async {
  //   final roomname = ref.read(roomNameProvider);
  //   final tokendata = await fetchAgoraToken(roomname);
  //   if (tokendata == null || tokendata.isEmpty) {
  //     throw Exception('Token fetch failed');
  //   }

  //   Navigator.pushReplacement(
  //     context,
  //     MaterialPageRoute(
  //         builder: (context) => VideoScreen(
  //               appId: '2f3131394cc6417b91aa93cfde567a37',
  //               channelName: roomname,
  //               token: tokendata['token'],
  //             )),
  //   );
  // }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final roomName = ref.watch(roomNameProvider);
    final userName = ref.watch(userNameProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Join Meeting'),
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
