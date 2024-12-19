import 'package:doctor_doom/authentication/tokenmanage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class UpdateProfilePage extends StatefulWidget {
  const UpdateProfilePage({super.key});

  @override
  _UpdateProfilePageState createState() => _UpdateProfilePageState();
}

class _UpdateProfilePageState extends State<UpdateProfilePage> {
  final _dobController = TextEditingController();
  final _institutionController = TextEditingController();
  final _occupationController = TextEditingController();

  Future<void> submitProfile() async {
    String dob = _dobController.text;
    String institution = _institutionController.text;
    String occupation = _occupationController.text;

    Map<String, String> updatedFields = {
      'DOB': dob,
      'Institution': institution,
      'Occupation': occupation,
    };

    print('DOB: $dob, Institution: $institution, Occupation: $occupation');

    final accessToken = await getAccessToken();
    if (accessToken == null) {
      print('Failed to get access token');
      return;
    }

    print('Access token is $accessToken');
    print(
        'Updated fields: ${updatedFields['DOB']}....${updatedFields['Institution']}....${updatedFields['Occupation']}');

    final response = await http.put(
      Uri.parse('https://agora.naitikk.tech/update-info/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
      body: json.encode({
        'dob': updatedFields['DOB'],
        'institution': updatedFields['Institution'],
        'occupation': updatedFields['Occupation'],
      }),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Details submitted successfully!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to submit details')),
      );
    }
  }

  Future<String?> getAccessToken() async {
    final authToken = await getToken();
    print('Auth token is $authToken');

    try {
      final response = await http.post(
        Uri.parse('https://agora.naitikk.tech/token/refresh/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'refresh': authToken}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        String accessToken = data['access'];
        return accessToken;
      } else {
        print('Failed to fetch access token: ${response.body}');
      }
    } catch (e) {
      print('Error fetching access token: $e');
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 233, 201, 152),
      appBar: AppBar(
        title: Text(
          'Update Profile',
          style: GoogleFonts.poppins(
              fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: const Color(0xFF2C2C2C),
        centerTitle: true,
        elevation: 2,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            TextField(
              controller: _dobController,
              decoration: InputDecoration(
                labelText: 'Date of Birth',
                prefixIcon: Icon(Icons.calendar_today),
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.datetime,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _institutionController,
              decoration: InputDecoration(
                labelText: 'Institution',
                prefixIcon: Icon(Icons.school),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _occupationController,
              decoration: InputDecoration(
                labelText: 'Occupation',
                prefixIcon: Icon(Icons.work),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: submitProfile,
              child: Text(
                'Submit',
                style: GoogleFonts.poppins(fontSize: 18),
              ),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                foregroundColor: const Color(0xFF2C2C2C),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
