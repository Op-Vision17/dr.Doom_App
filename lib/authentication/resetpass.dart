import 'dart:convert';
import 'package:doctor_doom/authentication/resetpass2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

final emailProvider = StateProvider<String>((ref) => "");
final loadingProvider = StateProvider<bool>((ref) => false);

class ResetPasswordScreen extends ConsumerWidget {
  const ResetPasswordScreen({Key? key}) : super(key: key);

  Future<void> sendResetLink(BuildContext context, WidgetRef ref) async {
    final email = ref.read(emailProvider).trim();

    if (email.isEmpty || !RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a valid email address!")),
      );
      return;
    }

    ref.read(loadingProvider.notifier).state = true;
    const String url =
        "https://login-signup-docdoom.onrender.com/password-reset-request/";
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );

      ref.read(loadingProvider.notifier).state = false;

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data['token'];

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('resetToken', token);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  "Reset token generated. Use it to reset your password.")),
        );
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ResetPasswordScreen2()),
        );
      } else if (response.statusCode == 400) {
        final error = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error['email'][0])),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Something went wrong. Please try again.")),
        );
      }
    } catch (e) {
      ref.read(loadingProvider.notifier).state = false;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = ref.watch(loadingProvider);

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 233, 201, 152),
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          // Gradient Background with Orange and Grey (without logo)
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

          // Centered Form Container
          Align(
            alignment: Alignment.center,
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  margin: const EdgeInsets.symmetric(
                      horizontal: 16.0), // Added horizontal padding
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
                      Text(
                        "RESET PASSWORD",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          color: const Color.fromARGB(
                              255, 234, 157, 14), // Shiny Orange
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Email Field
                      TextField(
                        style: const TextStyle(
                            color:
                                Colors.white), // Set input text color to white
                        decoration: InputDecoration(
                          labelText: "Email",
                          labelStyle: const TextStyle(color: Colors.white),
                          border: const OutlineInputBorder(),
                          prefixIcon: Icon(Icons.email,
                              color: const Color.fromARGB(
                                  255, 235, 164, 30)), // Orange Icon
                          focusedBorder: const OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Color(0xFFFFA500), width: 2.0),
                          ),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        onChanged: (value) =>
                            ref.read(emailProvider.notifier).state = value,
                      ),
                      const SizedBox(height: 20),
                      // Request Reset Button
                      ElevatedButton(
                        onPressed: isLoading
                            ? null
                            : () => sendResetLink(context, ref),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(
                              255, 232, 167, 48), // Shiny Orange
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14.0),
                        ),
                        child: isLoading
                            ? LoadingAnimationWidget.inkDrop(
                                color: const Color.fromARGB(255, 240, 195, 69),
                                size: 25,
                              )
                            : const Text(
                                "Request Reset",
                                style: TextStyle(
                                    fontSize: 16,
                                    color: Color.fromARGB(255, 0, 0, 0)),
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
