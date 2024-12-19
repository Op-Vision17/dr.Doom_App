import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

final emailProvider = FutureProvider<String>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('email') ?? 'N/A';
});

final userDetailsProvider = FutureProvider<Map<String, String>>((ref) async {
  final email = await ref.watch(emailProvider.future);
  print('email iska $email');

  final response = await http.post(
    Uri.parse('https://agora.naitikk.tech/profile/'),
    body: {'email': email},
  );

  if (response.statusCode == 200) {
    final data = json.decode(response.body) as Map<String, dynamic>;
    return {
      'First name': data['First name:'] ?? 'N/A',
      'Last name': data['Last name'] ?? 'N/A',
      'Email': data['email'] ?? 'N/A',
      'Phone': data['Phone'] ?? 'N/A',
      'DOB': data['DOB'] ?? 'N/A',
      'Occupation': data['Occupation'] ?? 'N/A',
      'Institution': data['Institution'] ?? 'N/A',
    };
  } else {
    throw Exception('Failed to fetch user details');
  }
});

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.refresh(userDetailsProvider);

    final userDetailsAsync = ref.watch(userDetailsProvider);

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 233, 201, 152),
      appBar: AppBar(
        title: Text(
          'Profile',
          style: GoogleFonts.poppins(
              fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: const Color(0xFF2C2C2C),
        centerTitle: true,
        elevation: 2,
      ),
      body: userDetailsAsync.when(
        data: (userDetails) => Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            children: [
              _buildCard(
                title: 'Name',
                content:
                    '${userDetails['First name']} ${userDetails['Last name']}',
                icon: Icons.person,
              ),
              _buildCard(
                title: 'Email',
                content: userDetails['Email']!,
                icon: Icons.email,
              ),
              _buildCard(
                title: 'Phone',
                content: userDetails['Phone']!,
                icon: Icons.phone,
              ),
              _buildCard(
                title: 'DOB',
                content: userDetails['DOB']!,
                icon: Icons.calendar_today,
              ),
              _buildCard(
                title: 'Occupation',
                content: userDetails['Occupation']!,
                icon: Icons.work,
              ),
              _buildCard(
                title: 'Institution',
                content: userDetails['Institution']!,
                icon: Icons.school,
              ),
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }

  Widget _buildCard({
    required String title,
    required String content,
    required IconData icon,
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
}
