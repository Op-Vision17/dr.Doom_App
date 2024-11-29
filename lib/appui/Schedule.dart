import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

// State Providers for managing meeting details
final meetingNameProvider = StateProvider<String>((ref) => '');
final hostNameProvider = StateProvider<String>((ref) => '');
final meetingDateProvider = StateProvider<DateTime?>((ref) => null);
final meetingTimeProvider = StateProvider<TimeOfDay?>((ref) => null);
final meetingDescriptionProvider = StateProvider<String>((ref) => '');

class ScheduleMeetingScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final meetingName = ref.watch(meetingNameProvider);
    final hostName = ref.watch(hostNameProvider);
    final meetingDate = ref.watch(meetingDateProvider);
    final meetingTime = ref.watch(meetingTimeProvider);
    final meetingDescription = ref.watch(meetingDescriptionProvider);

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
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Title
                  SizedBox(
                    height: 100,
                  ),
                  Text(
                    "Schedule Meeting",
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
                  ),
                  const SizedBox(height: 30),
                  // Meeting Name Input
                  TextField(
                    onChanged: (value) {
                      ref.read(meetingNameProvider.notifier).state = value;
                    },
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.2),
                      hintText: 'Meeting Name',
                      hintStyle: const TextStyle(color: Colors.white70),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Host Name Input
                  TextField(
                    onChanged: (value) {
                      ref.read(hostNameProvider.notifier).state = value;
                    },
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.2),
                      hintText: 'Host Name',
                      hintStyle: const TextStyle(color: Colors.white70),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Date Picker
                  GestureDetector(
                    onTap: () async {
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2100),
                      );
                      ref.read(meetingDateProvider.notifier).state =
                          pickedDate;
                                        },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 15, horizontal: 20),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            meetingDate == null
                                ? 'Select Date'
                                : '${meetingDate.year}-${meetingDate.month}-${meetingDate.day}',
                            style: const TextStyle(
                                color: Colors.white70, fontSize: 16),
                          ),
                          const Icon(Icons.calendar_today, color: Colors.white),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Time Picker
                  GestureDetector(
                    onTap: () async {
                      TimeOfDay? pickedTime = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );
                      if (pickedTime != null) {
                        ref.read(meetingTimeProvider.notifier).state =
                            pickedTime;
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 15, horizontal: 20),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            meetingTime == null
                                ? 'Select Time'
                                : '${meetingTime.hour}:${meetingTime.minute}',
                            style: const TextStyle(
                                color: Colors.white70, fontSize: 16),
                          ),
                          const Icon(Icons.access_time, color: Colors.white),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Description Input
                  TextField(
                    onChanged: (value) {
                      ref.read(meetingDescriptionProvider.notifier).state =
                          value;
                    },
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.2),
                      hintText: 'Meeting Description (Optional)',
                      hintStyle: const TextStyle(color: Colors.white70),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    keyboardType: TextInputType.multiline,
                    maxLines: 3,
                  ),
                  const SizedBox(height: 30),
                  // Schedule Button
                  GestureDetector(
                    onTap: () {
                      // You can handle scheduling logic here
                      // Example: Send data to Firebase or API
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Meeting Scheduled'),
                          content: Text(
                              'Meeting "${meetingName}" has been scheduled!'),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: const Text('OK'),
                            ),
                          ],
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
                          'Schedule Meeting',
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
        ],
      ),
    );
  }
}
