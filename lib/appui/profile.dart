import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePage extends StatelessWidget {
  ProfilePage({super.key});

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
  Widget build(BuildContext context) {
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildCard(
                    title: 'Name',
                    content:
                        '${userDetails['firstName']} ${userDetails['lastName']}',
                    icon: Icons.person,
                  ),
                  _buildCard(
                    title: 'Email',
                    content: userDetails['email']!,
                    icon: Icons.email,
                  ),
                  _buildCard(
                    title: 'Phone Number',
                    content: userDetails['phoneNumber']!,
                    icon: Icons.phone,
                  ),
                ],
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
