import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:doctor_doom/authentication/loginscreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final emailProvider = StateProvider<String>((ref) => "");
final newPasswordProvider = StateProvider<String>((ref) => "");
final passwordVisibilityProvider = StateProvider<bool>((ref) => true);
final loadingProvider = StateProvider<bool>((ref) => false);

class ResetPasswordScreen2 extends ConsumerWidget {
  const ResetPasswordScreen2({Key? key}) : super(key: key);

  Future<void> resetPassword(BuildContext context, WidgetRef ref) async {
    final email = ref.read(emailProvider).trim();
    final newPassword = ref.read(newPasswordProvider).trim();

    if (newPassword.isEmpty || newPassword.length < 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Password must be at least 8 characters long!")),
      );
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('resetToken');

    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("No reset token found. Please request again.")),
      );
      return;
    }

    ref.read(loadingProvider.notifier).state = true;
    const String url =
        "https://login-signup-docdoom.onrender.com/set-new-password/";
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'token': token,
          'new_password': newPassword,
        }),
      );

      ref.read(loadingProvider.notifier).state = false;

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Password reset successfully!")),
        );
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
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
    final _obscurePassword = ref.watch(passwordVisibilityProvider);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor:
          const Color.fromARGB(255, 233, 201, 152), // Light background color
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
                  margin: const EdgeInsets.symmetric(horizontal: 16.0),
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
                        style: const TextStyle(color: Colors.white),
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
                      // New Password Field
                      TextField(
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: "New Password",
                          labelStyle: const TextStyle(color: Colors.white),
                          border: const OutlineInputBorder(),
                          prefixIcon: Icon(Icons.lock,
                              color: const Color.fromARGB(
                                  255, 235, 164, 30)), // Orange Icon
                          focusedBorder: const OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Color(0xFFFFA500), width: 2.0),
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            color: Color(0xFFFFA500),
                            onPressed: () {
                              ref
                                  .read(passwordVisibilityProvider.notifier)
                                  .state = !_obscurePassword;
                            },
                          ),
                        ),
                        obscureText: _obscurePassword,
                        onChanged: (value) => ref
                            .read(newPasswordProvider.notifier)
                            .state = value,
                      ),
                      const SizedBox(height: 20),
                      // Reset Button
                      ElevatedButton(
                        onPressed: isLoading
                            ? null
                            : () => resetPassword(context, ref),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(
                              255, 232, 167, 48), // Shiny Orange
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14.0),
                        ),
                        child: isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.black)
                            : const Text(
                                "Reset",
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
