import 'package:doctor_doom/appui/homescreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

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
      backgroundColor: const Color.fromARGB(255, 233, 201, 152),
      appBar: AppBar(
        backgroundColor: const Color(0xFF333333),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back,
              color: Color.fromARGB(255, 231, 179, 35)),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HomeScreen()),
            );
          },
        ),
        title: Text(
          "Schedule Meeting",
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
      body: Stack(
        children: [
          // Gradient Background
          ClipPath(
            clipper: WaveClipper(),
            child: Container(
              height: MediaQuery.of(context).size.height * 0.45,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF333333), // Dark Grey
                    Color(0xFF1E1E1E), // Black
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),

          // Centered Schedule Meeting Container
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
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 20),

                      // Meeting Name Input with Prefix Icon
                      buildTextField(
                        label: "Meeting Name",
                        icon: Icons.meeting_room,
                        onChanged: (value) => ref
                            .read(meetingNameProvider.notifier)
                            .state = value,
                      ),
                      const SizedBox(height: 20),

                      // Host Name Input with Prefix Icon
                      buildTextField(
                        label: "Host Name",
                        icon: Icons.person,
                        onChanged: (value) =>
                            ref.read(hostNameProvider.notifier).state = value,
                      ),
                      const SizedBox(height: 20),

                      // Date Picker with Custom Theme
                      buildPicker(
                        context: context,
                        label: meetingDate == null
                            ? 'Select Date'
                            : '${meetingDate.year}-${meetingDate.month}-${meetingDate.day}',
                        icon: Icons.calendar_today,
                        onTap: () async {
                          DateTime? pickedDate = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime.now(),
                            lastDate: DateTime(2100),
                            builder: (context, child) {
                              return Theme(
                                data: Theme.of(context).copyWith(
                                  colorScheme: const ColorScheme.dark(
                                    primary: const Color.fromARGB(
                                        255, 232, 167, 48), // Light Yellow
                                    onPrimary: Color.fromARGB(
                                        128, 0, 0, 0), // Black text
                                    surface: Color.fromARGB(
                                        255, 30, 30, 30), // Black background
                                    onSurface: Colors.white, // White text
                                  ),
                                  dialogBackgroundColor: const Color.fromARGB(
                                      255, 24, 24, 24), // Black
                                ),
                                child: child!,
                              );
                            },
                          );
                          ref.read(meetingDateProvider.notifier).state =
                              pickedDate;
                        },
                      ),
                      const SizedBox(height: 20),

                      // Time Picker with Custom Theme
                      buildPicker(
                        context: context,
                        label: meetingTime == null
                            ? 'Select Time'
                            : '${meetingTime.hour}:${meetingTime.minute}',
                        icon: Icons.access_time,
                        onTap: () async {
                          TimeOfDay? pickedTime = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.now(),
                            builder: (context, child) {
                              return Theme(
                                data: Theme.of(context).copyWith(
                                  colorScheme: const ColorScheme.dark(
                                    primary: const Color.fromARGB(
                                        255, 232, 167, 48), // Light Yellow
                                    onPrimary: Colors.black, // Black text
                                    surface: Colors.black, // Black background
                                    onSurface: Colors.white, // White text
                                  ),
                                  dialogBackgroundColor: const Color.fromARGB(
                                      145, 0, 0, 0), // Black
                                ),
                                child: child!,
                              );
                            },
                          );
                          if (pickedTime != null) {
                            ref.read(meetingTimeProvider.notifier).state =
                                pickedTime;
                          }
                        },
                      ),
                      const SizedBox(height: 20),

                      // Description Input
                      buildTextField(
                        label: "Meeting Description (Optional)",
                        maxLines: 3,
                        icon: Icons.description,
                        onChanged: (value) => ref
                            .read(meetingDescriptionProvider.notifier)
                            .state = value,
                      ),
                      const SizedBox(height: 30),

                      ElevatedButton(
                        onPressed: () {
                          // Handle scheduling logic here
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
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color.fromARGB(255, 232, 167, 48),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                        ),
                        child: Text(
                          "Schedule Meeting",
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
    int maxLines = 1,
  }) {
    return TextField(
      onChanged: onChanged,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white),
        border: const OutlineInputBorder(),
        filled: true,
        fillColor: Colors.white.withOpacity(0.1),
        prefixIcon: Icon(
          icon,
          color: const Color.fromARGB(255, 232, 167, 48), // Shiny Orange Icon
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

  Widget buildPicker({
    required BuildContext context,
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color.fromARGB(255, 232, 167, 48),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(color: Colors.white70, fontSize: 16),
            ),
            Icon(icon, color: const Color.fromARGB(255, 232, 167, 48)),
          ],
        ),
      ),
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
