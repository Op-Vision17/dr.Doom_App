import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final profileProvider = StateNotifierProvider<ProfileNotifier, Profile>((ref) {
  return ProfileNotifier();
});

class Profile {
  String gender;
  String age;
  String occupation;

  Profile({
    this.gender = '',
    this.age = '',
    this.occupation = '',
  });
}

class ProfileNotifier extends StateNotifier<Profile> {
  ProfileNotifier() : super(Profile());

  void updateGender(String value) {
    state =
        Profile(gender: value, age: state.age, occupation: state.occupation);
  }

  void updateAge(String value) {
    state =
        Profile(gender: state.gender, age: value, occupation: state.occupation);
  }

  void updateOccupation(String value) {
    state = Profile(gender: state.gender, age: state.age, occupation: value);
  }
}

class Editprofile extends ConsumerWidget {
  Editprofile({super.key});

  Future<Map<String, String>> _getUserDetails() async {
    final prefs = await SharedPreferences.getInstance();
    final firstName = prefs.getString('firstName') ?? 'N/A';
    final lastName = prefs.getString('lastName') ?? 'N/A';
    final email = prefs.getString('email') ?? 'N/A';
    final phoneNumber = prefs.getString('phoneNumber') ?? 'N/A';

    return {
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phoneNumber': phoneNumber,
    };
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileProvider);
    final profileNotifier = ref.read(profileProvider.notifier);

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 233, 201, 152),
      appBar: AppBar(
        title: Text('Profile', style: GoogleFonts.poppins(fontSize: 24)),
        backgroundColor: const Color(0xFF2C2C2C),
        centerTitle: true,
        elevation: 0,
      ),
      body: FutureBuilder<Map<String, String>>(
        future: _getUserDetails(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasData) {
            final userDetails = snapshot.data!;
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildCard(
                      title: 'Name',
                      content:
                          '${userDetails['firstName']} ${userDetails['lastName']}',
                      icon: Icons.person,
                      isMutable: false,
                    ),
                    _buildCard(
                      title: 'Email',
                      content: userDetails['email']!,
                      icon: Icons.email,
                      isMutable: false,
                    ),
                    _buildCard(
                      title: 'Phone Number',
                      content: userDetails['phoneNumber']!,
                      icon: Icons.phone,
                      isMutable: false,
                    ),
                    _buildEditableCard(
                      title: 'Gender',
                      value: profile.gender,
                      icon: Icons.person_outline,
                      onChanged: profileNotifier.updateGender,
                    ),
                    _buildEditableCard(
                      title: 'Age',
                      value: profile.age,
                      icon: Icons.cake,
                      onChanged: profileNotifier.updateAge,
                    ),
                    _buildEditableCard(
                      title: 'Occupation',
                      value: profile.occupation,
                      icon: Icons.work,
                      onChanged: profileNotifier.updateOccupation,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        // Submit logic can be added here
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Details submitted!')),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orangeAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.0),
                        ),
                      ),
                      child: Text(
                        'Submit',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return const Center(child: Text('Error loading user details'));
        },
      ),
    );
  }

  Widget _buildCard({
    required String title,
    required String content,
    required IconData icon,
    required bool isMutable,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(icon, size: 32, color: Colors.orangeAccent),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    content,
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
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

  Widget _buildEditableCard({
    required String title,
    required String value,
    required IconData icon,
    required Function(String) onChanged,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(icon, size: 32, color: Colors.orangeAccent),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    onSubmitted: onChanged,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 8.0,
                        horizontal: 12.0,
                      ),
                      hintText: 'Enter $title',
                      hintStyle: const TextStyle(color: Colors.grey),
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
