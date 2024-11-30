import 'dart:convert';
import 'package:doctor_doom/authentication/resetpass.dart';
import 'package:doctor_doom/authentication/signupscreen.dart';
import 'package:doctor_doom/appui/homescreen.dart';
import 'package:doctor_doom/authentication/tokenmanage.dart';
import 'package:doctor_doom/services/user_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

final passwordVisibilityProvider = StateProvider<bool>((ref) => true);
final emailProvider = StateProvider<String>((ref) => '');
final passwordProvider = StateProvider<String>((ref) => '');
final loadingProvider = StateProvider<bool>((ref) => false);

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  bool isEmailValid(String email) {
    final regex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    return regex.hasMatch(email);
  }

  Future<void> login(WidgetRef ref) async {
    final email = ref.read(emailProvider);
    final password = ref.read(passwordProvider);

    if (!isEmailValid(email)) {
      ScaffoldMessenger.of(ref.context).showSnackBar(
        const SnackBar(content: Text("Please enter a valid email address!")),
      );
      return;
    }

    ref.read(loadingProvider.notifier).state = true;

    const String url = "https://login-signup-docdoom.onrender.com/login/";
    final body = {"email": email, "password": password};

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      final data = jsonDecode(response.body);

      ref.read(loadingProvider.notifier).state = false;

      if (response.statusCode == 200) {
        final token = data['token'];
        final user = data['user'];

        await saveToken(token);

        final userStorage = UserStorage();
        await userStorage.saveUserData(user, token);

        ScaffoldMessenger.of(ref.context).showSnackBar(
          const SnackBar(content: Text("Login Successful!")),
        );

        Navigator.pushReplacement(
          ref.context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      } else if (response.statusCode == 400) {
        final error =
            data['non_field_errors']?.join(' ') ?? "Invalid credentials.";
        ScaffoldMessenger.of(ref.context).showSnackBar(
          SnackBar(content: Text(error)),
        );
      } else {
        ScaffoldMessenger.of(ref.context).showSnackBar(
          const SnackBar(
              content: Text(
                  "An unexpected error occurred. Please try again later.")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(ref.context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final _obscurePassword = ref.watch(passwordVisibilityProvider);
    final isLoading = ref.watch(loadingProvider);

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 233, 201, 152),
      body: Stack(
        children: [
          // Gradient Background with Orange and Grey
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
              child: Center(
                child: Center(
                  child: Image.asset(
                    'assets/doom_logo.png', // Your logo path
                    width: 210, // Adjust the width as needed
                    height: 200, // Adjust the height as needed
                  ),
                ),
              ),
            ),
          ),

          // Grey Form Container moved higher
          Align(
            alignment: Alignment.bottomCenter,
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  margin: const EdgeInsets.only(top: 150.0), // Adjusted margin
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
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        "LOGIN",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          color: const Color.fromARGB(
                              255, 234, 157, 14), // Shiny Orange
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        style: const TextStyle(
                            color: Colors.white), // White text color
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
                        onChanged: (value) =>
                            ref.read(emailProvider.notifier).state = value,
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        obscureText: _obscurePassword,
                        style: const TextStyle(
                            color: Colors.white), // White text color
                        decoration: InputDecoration(
                          labelText: "Password",
                          labelStyle: const TextStyle(color: Colors.white),
                          border: const OutlineInputBorder(),
                          prefixIcon: const Icon(Icons.lock,
                              color: Color.fromARGB(
                                  255, 221, 157, 37)), // Orange Icon
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: const Color.fromARGB(
                                  255, 215, 151, 32), // Orange Icon
                            ),
                            onPressed: () {
                              ref
                                  .read(passwordVisibilityProvider.notifier)
                                  .state = !_obscurePassword;
                            },
                          ),
                          focusedBorder: const OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Color.fromARGB(255, 222, 159, 41),
                                width: 2.0),
                          ),
                        ),
                        onChanged: (value) =>
                            ref.read(passwordProvider.notifier).state = value,
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: isLoading ? null : () => login(ref),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(
                              255, 232, 167, 48), // Shiny Orange Button
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                        ),
                        child: isLoading
                            ? const CircularProgressIndicator(
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              )
                            : Text(
                                "Login",
                                style: GoogleFonts.roboto(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () {
                              // Navigate to the Reset Password screen
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const ResetPasswordScreen()),
                              );
                            },
                            child: Text(
                              "Forgot Password?",
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                color: const Color(0xFFFFA500), // Orange Text
                              ),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "New user? ",
                            style: GoogleFonts.roboto(
                              fontSize: 16,
                              color:
                                  const Color(0xFFFFA500), // Shiny Orange Text
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const SignupScreen()),
                              );
                            },
                            child: Text(
                              "Register",
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                color: const Color(
                                    0xFFFFA500), // Shiny Orange Text
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      // Forgot Password Button aligned to the right
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
