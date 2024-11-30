import 'dart:convert';
import 'package:doctor_doom/authentication/loginscreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

final firstNameProvider = StateProvider<String>((ref) => "");
final lastNameProvider = StateProvider<String>((ref) => "");
final emailProvider = StateProvider<String>((ref) => "");
final phoneNumberProvider = StateProvider<String>((ref) => "");
final passwordProvider = StateProvider<String>((ref) => "");
final passwordVisibilityProvider = StateProvider<bool>((ref) => true);
final loadingProvider = StateProvider<bool>((ref) => false);

class SignupScreen extends ConsumerWidget {
  const SignupScreen({super.key});

  bool isEmailValid(String email) {
    final regex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    return regex.hasMatch(email);
  }

  bool isPasswordValid(String password) {
    final regex = RegExp(
        r'^(?=.*[A-Za-z])(?=.*\d)(?=.*[!@#\$%\^&\*\(\)_\+\-=\[\]\{\};:"\\|,<>\./?])(?=.{8,})');
    return regex.hasMatch(password);
  }

  bool isPhoneNumberValid(String phoneNumber) {
    return phoneNumber.length == 10 && int.tryParse(phoneNumber) != null;
  }

  Future<void> signUp(WidgetRef ref) async {
    ref.read(loadingProvider.notifier).state = true;

    final firstName = ref.read(firstNameProvider);
    final lastName = ref.read(lastNameProvider);
    final email = ref.read(emailProvider);
    final phoneNumber = ref.read(phoneNumberProvider);
    final password = ref.read(passwordProvider);

    if (firstName.isEmpty ||
        lastName.isEmpty ||
        email.isEmpty ||
        phoneNumber.isEmpty ||
        password.isEmpty) {
      ScaffoldMessenger.of(ref.context).showSnackBar(
        const SnackBar(content: Text("All fields are required!")),
      );
      ref.read(loadingProvider.notifier).state = false;
      return;
    }

    if (!isEmailValid(email)) {
      ScaffoldMessenger.of(ref.context).showSnackBar(
        const SnackBar(content: Text("Please enter a valid email address!")),
      );
      ref.read(loadingProvider.notifier).state = false;
      return;
    }

    if (!isPhoneNumberValid(phoneNumber)) {
      ScaffoldMessenger.of(ref.context).showSnackBar(
        const SnackBar(content: Text("Phone number must be 10 digits!")),
      );
      ref.read(loadingProvider.notifier).state = false;
      return;
    }

    if (!isPasswordValid(password)) {
      ScaffoldMessenger.of(ref.context).showSnackBar(
        const SnackBar(
            content: Text(
                "Password must be at least 8 characters and include a letter, a number, and a special character!")),
      );
      ref.read(loadingProvider.notifier).state = false;
      return;
    }

    const String url = "https://login-signup-docdoom.onrender.com/register/";

    final body = {
      "first_name": firstName,
      "last_name": lastName,
      "email": email,
      "phone_number": phoneNumber,
      "password": password,
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final message = jsonDecode(response.body)["message"];
        ScaffoldMessenger.of(ref.context).showSnackBar(
          SnackBar(content: Text(message)),
        );
        Navigator.push(
          ref.context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      } else {
        final error = jsonDecode(response.body);
        final errorMessage = error.values.map((e) => e.join(" ")).join("\n");
        ScaffoldMessenger.of(ref.context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(ref.context).showSnackBar(
        SnackBar(content: Text("Error: $e.")),
      );
    } finally {
      ref.read(loadingProvider.notifier).state = false;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final obscurePassword = ref.watch(passwordVisibilityProvider);
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
                child: Image.asset(
                  'assets/doom_logo.png', // Your logo path
                  width: 190, // Adjust the width as needed
                  height: 190, // Adjust the height as needed
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
                  padding: const EdgeInsets.all(14.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        "SIGNUP",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          color: const Color.fromARGB(
                              255, 234, 157, 14), // Shiny Orange
                        ),
                      ),
                      const SizedBox(height: 20),
                      // First Name Field
                      TextField(
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: "First Name",
                          labelStyle: const TextStyle(color: Colors.white),
                          border: const OutlineInputBorder(),
                          prefixIcon: Icon(Icons.person,
                              color: const Color.fromARGB(
                                  255, 235, 164, 30)), // Orange Icon
                          focusedBorder: const OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Color(0xFFFFA500), width: 2.0),
                          ),
                        ),
                        onChanged: (value) =>
                            ref.read(firstNameProvider.notifier).state = value,
                      ),
                      const SizedBox(height: 15),
                      // Last Name Field
                      TextField(
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: "Last Name",
                          labelStyle: const TextStyle(color: Colors.white),
                          border: const OutlineInputBorder(),
                          prefixIcon: Icon(Icons.person,
                              color: const Color.fromARGB(
                                  255, 235, 164, 30)), // Orange Icon
                          focusedBorder: const OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Color(0xFFFFA500), width: 2.0),
                          ),
                        ),
                        onChanged: (value) =>
                            ref.read(lastNameProvider.notifier).state = value,
                      ),
                      const SizedBox(height: 15),
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
                        onChanged: (value) =>
                            ref.read(emailProvider.notifier).state = value,
                      ),
                      const SizedBox(height: 15),
                      // Phone Number Field
                      TextField(
                        keyboardType: TextInputType.phone,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: "Phone Number",
                          labelStyle: const TextStyle(color: Colors.white),
                          border: const OutlineInputBorder(),
                          prefixIcon: Icon(Icons.phone,
                              color: const Color.fromARGB(
                                  255, 235, 164, 30)), // Orange Icon
                          focusedBorder: const OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Color(0xFFFFA500), width: 2.0),
                          ),
                        ),
                        onChanged: (value) => ref
                            .read(phoneNumberProvider.notifier)
                            .state = value,
                      ),
                      const SizedBox(height: 15),
                      // Password Field
                      TextField(
                        obscureText: obscurePassword,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: "Password",
                          labelStyle: const TextStyle(color: Colors.white),
                          border: const OutlineInputBorder(),
                          prefixIcon: const Icon(Icons.lock,
                              color: Color.fromARGB(
                                  255, 221, 157, 37)), // Orange Icon
                          suffixIcon: IconButton(
                            icon: Icon(
                              obscurePassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: const Color.fromARGB(
                                  255, 215, 151, 32), // Orange Icon
                            ),
                            onPressed: () {
                              ref
                                  .read(passwordVisibilityProvider.notifier)
                                  .state = !obscurePassword;
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
                        onPressed: isLoading ? null : () => signUp(ref),
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
                                "Create Account",
                                style: GoogleFonts.roboto(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Already have an account?",
                            style: TextStyle(color: Colors.white),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const LoginScreen()),
                              );
                            },
                            child: const Text(
                              "Login here",
                              style: TextStyle(color: Colors.amber),
                            ),
                          ),
                        ],
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
