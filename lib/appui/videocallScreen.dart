import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final participantsProvider = StateProvider<List<String>>((ref) {
  return ["1", "2", "3"];
});

final isMicOnProvider = StateProvider<bool>((ref) {
  return true;
});

final isVideoOnProvider = StateProvider<bool>((ref) {
  return true;
});

final isHandRaisedProvider = StateProvider<bool>((ref) {
  return false;
});

class VideoCallScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final participants = ref.watch(participantsProvider);
    final isMicOn = ref.watch(isMicOnProvider);
    final isVideoOn = ref.watch(isVideoOnProvider);
    final isHandRaised = ref.watch(isHandRaisedProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.symmetric(horizontal: 18, vertical: 15),
              padding: EdgeInsets.symmetric(horizontal: 28, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Project Reporting - Week 1",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "Anshika's Meeting Room",
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              padding: EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Anshika",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "Wants to join the meeting",
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          onPressed: () {},
                          icon: Icon(Icons.close, color: Colors.white),
                          iconSize: 28,
                        ),
                      ),
                      SizedBox(width: 5),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.black,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          onPressed: () {
                            ref
                                .read(participantsProvider.notifier)
                                .update((state) => [...state, "new"]);
                          },
                          icon: Icon(Icons.check, color: Colors.white),
                          iconSize: 28,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Container(
                        margin: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Stack(
                          children: [
                            Center(
                              child: Text(
                                "",
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ),
                            Positioned(
                              top: 10,
                              left: 16,
                              child: Container(
                                padding: EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.transparent,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.video_call,
                                        color: Colors.black, size: 17),
                                    SizedBox(width: 4),
                                    Text(
                                      "You",
                                      style: TextStyle(
                                          color: Colors.black, fontSize: 17),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 5,
                              child: Container(
                                height: 50,
                                width: 325,
                                margin: EdgeInsets.symmetric(horizontal: 10),
                                padding: EdgeInsets.symmetric(
                                  horizontal: 20,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.transparent,
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.voice_chat),
                                    SizedBox(
                                      width: 12,
                                    ),
                                    Column(
                                      children: [
                                        SizedBox(height: 3),
                                        Center(
                                          child: Text(
                                            ".......................",
                                            style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.grey[600]),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Container(
                    height: 100,
                    margin: EdgeInsets.symmetric(horizontal: 12),
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: participants.length,
                      itemBuilder: (context, index) {
                        bool micStatus = isMicOn;

                        return Container(
                          margin: EdgeInsets.symmetric(horizontal: 8),
                          width: 80,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Stack(
                            children: [
                              Positioned(
                                bottom: 8,
                                left: 0,
                                right: 0,
                                child: Center(
                                  child: Text(
                                    "${participants[index]}",
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 8,
                                right: 8,
                                child: GestureDetector(
                                  onTap: () {
                                    micStatus = !micStatus;
                                  },
                                  child: Container(
                                    height: 24,
                                    width: 24,
                                    decoration: BoxDecoration(
                                      color:
                                          micStatus ? Colors.black : Colors.red,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      micStatus ? Icons.mic : Icons.mic_off,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              padding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    onPressed: () {
                      ref
                          .read(isMicOnProvider.notifier)
                          .update((state) => !state);
                    },
                    icon: Icon(
                      isMicOn ? Icons.mic : Icons.mic_off,
                      color: Colors.black,
                    ),
                    iconSize: 28,
                  ),
                  IconButton(
                    onPressed: () {
                      ref
                          .read(isVideoOnProvider.notifier)
                          .update((state) => !state);
                    },
                    icon: Icon(
                      isVideoOn ? Icons.videocam : Icons.videocam_off,
                      color: Colors.black,
                    ),
                    iconSize: 28,
                  ),
                  IconButton(
                    onPressed: () {
                      ref
                          .read(isHandRaisedProvider.notifier)
                          .update((state) => !state);
                    },
                    icon: Icon(
                      Icons.front_hand,
                      color: isHandRaised
                          ? Color.fromARGB(255, 238, 185, 80)
                          : Colors.black,
                    ),
                    iconSize: 28,
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: Icon(Icons.chat, color: Colors.black),
                    iconSize: 28,
                  ),
                  Container(
                    width: 70,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: IconButton(
                      onPressed: () {},
                      icon: Icon(Icons.call_end, color: Colors.white),
                      iconSize: 28,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
