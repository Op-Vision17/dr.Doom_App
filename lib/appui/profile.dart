import 'package:doctor_doom/appui/Schedule.dart';
import 'package:doctor_doom/appui/joinmeeting2.dart';
import 'package:doctor_doom/authentication/loginscreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:doctor_doom/services/user_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:hive/hive.dart';
import 'dart:io';
import 'package:google_fonts/google_fonts.dart';

// Model
class Profile {
  final String name;
  final String email;
  final String phoneNumber;
  final String? profilePicture;

  Profile({
    required this.name,
    required this.email,
    required this.phoneNumber,
    this.profilePicture,
  });
}

final profileProvider = FutureProvider<Profile>((ref) async {
  final userStorage = UserStorage();
  final userData = await userStorage.getUserData();

  return Profile(
    name: '${userData['first_name']} ${userData['last_name']}',
    email: userData['email'] ?? '',
    phoneNumber: userData['phone_number'] ?? '',
    profilePicture: userData['profile_picture'],
  );
});

class ProfilePage extends ConsumerWidget {
  ProfilePage({super.key});

  // Initialize the ImagePicker
  final ImagePicker _picker = ImagePicker();

  // Method to pick an image and save it to Hive
  Future<void> _pickAndSaveProfilePicture(BuildContext context) async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final String imagePath = pickedFile.path;

      // Store the picked image path in Hive
      final Box box = await Hive.openBox('profileBox');
      await box.put('profile_picture', imagePath);

      // Refresh the UI after saving
       Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) =>  ProfilePage()));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileProvider);

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 233, 201, 152),
      body: Stack(
        children: [
          // Gradient Background with Black and Orange (from the first code)
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
              child: Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: Center(
                  child: FutureBuilder(
                    future: _getProfilePicture(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        // Placeholder CircleAvatar with a neutral background when waiting for data
                        return CircleAvatar(
                          radius: 90,
                          backgroundColor: Colors.grey[300], // Placeholder color
                        );
                      }

                      if (snapshot.hasData) {
                        // Display the profile picture if available
                        return CircleAvatar(
                          radius: 90,
                          backgroundImage: FileImage(File(snapshot.data!)),
                        );
                      }

                      // Default CircleAvatar with no image if none is found
                      return CircleAvatar(
                        radius: 90,
                        backgroundColor: Colors.grey[300], // Placeholder color when no image is available
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
          
          // Profile Content (from the second code)
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 280.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 60),
                  profileAsync.when(
                    data: (profile) {
                      return Column(
                        children: [
                          // Profile Info (using first code style)
                          Container(
                            padding: const EdgeInsets.all(12.0),
                            margin: const EdgeInsets.all(12.0),
                            decoration: BoxDecoration(
                              color: Color(0xFF2C2C2C), // Dark Grey container
                              borderRadius: BorderRadius.circular(16.0),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  profile.name,
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.poppins(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                // Email Data with Icon
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.email,
                                      color: Colors.orangeAccent,
                                    ),
                                    const SizedBox(width: 10),
                                    Flexible( // Ensures that the text can be wrapped or truncated
                                      child: Text(
                                        profile.email,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 20,
                                        ),
                                        overflow: TextOverflow.ellipsis, // Adds "..." when the text overflows
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 15),
                                // Phone Number Data with Icon
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.phone,
                                      color: Colors.orangeAccent,
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      profile.phoneNumber,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                  // Change Profile Picture Button
                                ElevatedButton(
                                  onPressed: () {
                                    // Trigger the profile picture picker
                                    _pickAndSaveProfilePicture(context);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color.fromARGB(255, 232, 167, 48),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                    padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 46.0),
                                  ),
                                  child: Text(
                                    "Change Profile Picture",
                                    style: GoogleFonts.roboto(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                                

                                const SizedBox(height: 20),
                                 // Logout Button
                                ElevatedButton(
  onPressed: () {
    _logout(context); // Call your logout logic here
  },
  style: ElevatedButton.styleFrom(
    backgroundColor: const Color.fromARGB(255, 232, 167, 48), // Same color as the "Change Profile Picture" button
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8.0), // Matching border radius
    ),
    padding: const EdgeInsets.symmetric(vertical: 16.0 , horizontal: 109.0), // Same padding
  ),
  child: Text(
    "Logout",
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
                        ],
                      );
                    },
                    loading: () {
                      return const Center(child: CircularProgressIndicator());
                    },
                    error: (error, stackTrace) {
                      return Center(child: Text('Error: $error'));
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Method to handle logout
  void _logout(BuildContext context) {
    // Add your logout logic here
    // For example, clear user data from Hive and navigate to the login page
  
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) =>  LoginScreen()));
  }

  // Fetch the stored profile picture from Hive
  Future<String?> _getProfilePicture() async {
    final Box box = await Hive.openBox('profileBox');
    final String? imagePath = box.get('profile_picture');
    return imagePath;
  }
}

// Custom Clipper for Gradient Wave (from the first code)
class WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0.0, 0.0);
    path.lineTo(0.0, size.height - 30);
    path.quadraticBezierTo(size.width / 4, size.height, size.width / 2, size.height - 30);
    path.quadraticBezierTo(size.width * 3 / 4, size.height - 60, size.width, size.height - 30);
    path.lineTo(size.width, 0.0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}
