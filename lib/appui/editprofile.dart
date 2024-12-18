import 'package:doctor_doom/appui/widgets.dart';
import 'package:doctor_doom/authentication/tokenmanage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

final emailProvider = FutureProvider<String>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('email') ?? 'N/A';
});

final profileProvider = StateNotifierProvider<ProfileNotifier, Profile>((ref) {
  return ProfileNotifier();
});

class Profile {
  String name;
  String email;
  String phoneNumber;
  String dateOfBirth;
  String institution;
  String occupation;

  Profile({
    this.name = '',
    this.email = '',
    this.phoneNumber = '',
    this.dateOfBirth = '',
    this.institution = '',
    this.occupation = '',
  });
}

class ProfileNotifier extends StateNotifier<Profile> {
  ProfileNotifier() : super(Profile());

  void updateDateOfBirth(String value) {
    state = Profile(
      name: state.name,
      email: state.email,
      phoneNumber: state.phoneNumber,
      dateOfBirth: value,
      institution: state.institution,
      occupation: state.occupation,
    );
  }

  void updateInstitution(String value) {
    state = Profile(
      name: state.name,
      email: state.email,
      phoneNumber: state.phoneNumber,
      dateOfBirth: state.dateOfBirth,
      institution: value,
      occupation: state.occupation,
    );
  }

  void updateOccupation(String value) {
    state = Profile(
      name: state.name,
      email: state.email,
      phoneNumber: state.phoneNumber,
      dateOfBirth: state.dateOfBirth,
      institution: state.institution,
      occupation: value,
    );
  }

  Future<void> fetchProfileData(String email) async {
    const url = 'https://agora.naitikk.tech/profile/';
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        state = Profile(
          name: '${data['first_name'] ?? ''} ${data['last_name'] ?? ''}',
          email: data['email'] ?? '',
          phoneNumber: data['phone'] ?? '',
          dateOfBirth: data['dob'] ?? '',
          institution: data['institution'] ?? '',
          occupation: data['occupation'] ?? '',
        );
      } else {
        print('Failed to fetch data: ${response.body}');
      }
    } catch (e) {
      print('Error fetching profile data');
    }
  }

  Future<String?> _getAccessToken() async {
    final authToken = getToken();

    try {
      final response = await http.post(
        Uri.parse('https://agora.naitikk.tech/token/refresh/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'refresh': authToken}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        String access_token = data['access'];
        submitData(access_token);
      } else {
        print('Failed to fetch access token: ${response.body}');
      }
    } catch (e) {
      print('Error fetching access token');
    }
    return null;
  }

  Future<void> submitData(String access) async {
    const url = 'https://agora.naitikk.tech/update-info/';
    try {
      final response = await http.put(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $access',
        },
        body: json.encode({
          'dob': state.dateOfBirth,
          'institution': state.institution,
          'occupation': state.occupation,
        }),
      );

      if (response.statusCode == 200) {
        print('Data submitted successfully: ${response.body}');
      } else {
        print('Failed to submit data: ${response.body}');
      }
    } catch (e) {
      print('Error submitting data');
    }
  }
}

class EditProfile extends ConsumerWidget {
  const EditProfile({super.key});

  Future<String> _getEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('email') ?? '';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileProvider);
    final profileNotifier = ref.read(profileProvider.notifier);

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 233, 201, 152),
      appBar: AppBar(
        title: Text('Edit Profile', style: GoogleFonts.poppins(fontSize: 24)),
        backgroundColor: const Color(0xFF2C2C2C),
        centerTitle: true,
        elevation: 0,
      ),
      body: FutureBuilder<String>(
        future: _getEmail(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasData) {
            final sharedEmail = snapshot.data!;

            profileNotifier.fetchProfileData(sharedEmail);

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    buildImmutableCard(
                      title: 'Name',
                      value: profile.name,
                      icon: Icons.person,
                    ),
                    buildImmutableCard(
                      title: 'Email',
                      value: profile.email,
                      icon: Icons.email,
                    ),
                    buildImmutableCard(
                      title: 'Phone Number',
                      value: profile.phoneNumber,
                      icon: Icons.phone,
                    ),
                    buildEditableCard(
                      title: 'Date of Birth [YYYY-MM-DD]',
                      value: profile.dateOfBirth,
                      icon: Icons.calendar_today,
                      onChanged: profileNotifier.updateDateOfBirth,
                    ),
                    buildEditableCard(
                      title: 'Institution',
                      value: profile.institution,
                      icon: Icons.school,
                      onChanged: profileNotifier.updateInstitution,
                    ),
                    buildEditableCard(
                      title: 'Occupation',
                      value: profile.occupation,
                      icon: Icons.work,
                      onChanged: profileNotifier.updateOccupation,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () async {
                        await profileNotifier._getAccessToken();
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

          return const Center(child: Text('Error loading email'));
        },
      ),
    );
  }
}
