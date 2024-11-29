import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:doctor_doom/services/user_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:hive/hive.dart';
import 'dart:io';

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
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileProvider);

    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/loginbackground.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Profile Content
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 32.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 60),
                  profileAsync.when(
                    data: (profile) {
                      return Column(
                        children: [
                          // Profile Picture - Fetch from Hive or show a placeholder
                          FutureBuilder(
                            future: _getProfilePicture(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return CircleAvatar(
                                  radius: 60,
                                  child: Icon(Icons.person, size: 60),
                                );
                              }

                              if (snapshot.hasData) {
                                return CircleAvatar(
                                  radius: 60,
                                  backgroundImage: FileImage(File(snapshot.data!)),
                                );
                              }

                              return CircleAvatar(
                                radius: 60,
                                child: Icon(Icons.person, size: 60),
                              );
                            },
                          ),

                          const SizedBox(height: 20),

                          // Profile Info Container
                          Container(
                            padding: const EdgeInsets.all(16.0),
                            margin: const EdgeInsets.all(16.0),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.8),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Name: ${profile.name}',
                                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Email: ${profile.email}',
                                  style: TextStyle(fontSize: 18),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Phone Number: ${profile.phoneNumber}',
                                  style: TextStyle(fontSize: 18),
                                ),
                                const SizedBox(height: 32),
                              ],
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              // Trigger the profile picture picker
                              _pickAndSaveProfilePicture(context);
                            },
                            child: const Text('Change Profile Picture'),
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

  // Fetch the stored profile picture from Hive
  Future<String?> _getProfilePicture() async {
    final Box box = await Hive.openBox('profileBox');
    final String? imagePath = box.get('profile_picture');
    return imagePath;
  }
}

void main() {
  runApp(
    const ProviderScope(child: MyApp()),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Profile Page',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ProfilePage(),
    );
  }
}
