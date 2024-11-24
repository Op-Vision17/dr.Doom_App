import 'package:doctor_doom/authentication/loginscreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

final firstNameProvider = StateProvider<String>((ref) => "");
final lastNameProvider = StateProvider<String>((ref) => "");
final emailProvider = StateProvider<String>((ref) => "");
final phoneNumberProvider = StateProvider<String>((ref) => "");
final passwordProvider = StateProvider<String>((ref) => "");
final passwordVisibilityProvider = StateProvider<bool>((ref) => true);

class SignupScreen extends ConsumerWidget {
  const SignupScreen({Key? key}) : super(key: key);

  bool isEmailValid(String email) {
    final regex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    return regex.hasMatch(email);
  }

  bool isPasswordValid(String password) {
    final regex = RegExp(
        r'^(?=.*[A-Za-z])(?=.*\d)(?=.*[!@#\$%\^&\*\(\)_\+\-=\[\]\{\};:"\\|,<>\./?])(?=.{6,})');
    return regex.hasMatch(password);
  }

  bool isPhoneNumberValid(String phoneNumber) {
    return phoneNumber.length == 10 && int.tryParse(phoneNumber) != null;
  }

  Future<void> signUp(WidgetRef ref) async {
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
      return;
    }

    if (!isEmailValid(email)) {
      ScaffoldMessenger.of(ref.context).showSnackBar(
        const SnackBar(content: Text("Please enter a valid email address!")),
      );
      return;
    }

    if (!isPhoneNumberValid(phoneNumber)) {
      ScaffoldMessenger.of(ref.context).showSnackBar(
        const SnackBar(content: Text("Phone number must be 10 digits!")),
      );
      return;
    }

    if (!isPasswordValid(password)) {
      ScaffoldMessenger.of(ref.context).showSnackBar(
        const SnackBar(
            content: Text(
                "Password must be at least 6 characters and include a letter, a number, and a special character!")),
      );
      return;
    }

    const String url = "https://huddlehub-75fx.onrender.com/signup/";

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

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(ref.context).showSnackBar(
          SnackBar(content: Text("Signup Successful!")),
        );
        Navigator.push(
          ref.context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      } else {
        ScaffoldMessenger.of(ref.context).showSnackBar(
          SnackBar(content: Text("Error: ${response.body}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(ref.context).showSnackBar(
        SnackBar(content: Text("Error: $e.")),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final _obscurePassword = ref.watch(passwordVisibilityProvider);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/loginbackground.jpg"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Column(
            children: [
              Padding(
                  padding: const EdgeInsets.only(top: 50.0),
                  child: Text(
                    "Dr. Doom",
                    style: GoogleFonts.kablammo(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: const Color.fromARGB(255, 0, 0, 0),
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.5),
                          offset: const Offset(2, 2),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  )),
              SizedBox(
                height: 30,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(200, 255, 255, 255),
                    borderRadius: BorderRadius.circular(16.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'SIGNUP',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 0, 0, 0),
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        decoration: const InputDecoration(
                          labelText: "First Name",
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.name,
                        onChanged: (value) =>
                            ref.read(firstNameProvider.notifier).state = value,
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        decoration: const InputDecoration(
                          labelText: "Last Name",
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.name,
                        onChanged: (value) =>
                            ref.read(lastNameProvider.notifier).state = value,
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        decoration: const InputDecoration(
                          labelText: "Email",
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        onChanged: (value) =>
                            ref.read(emailProvider.notifier).state = value,
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        decoration: const InputDecoration(
                          labelText: "Phone No.",
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (value) => ref
                            .read(phoneNumberProvider.notifier)
                            .state = value,
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        decoration: InputDecoration(
                          labelText: "Password",
                          border: OutlineInputBorder(),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            onPressed: () {
                              ref
                                  .read(passwordVisibilityProvider.notifier)
                                  .state = !_obscurePassword;
                            },
                          ),
                        ),
                        obscureText: _obscurePassword,
                        onChanged: (value) =>
                            ref.read(passwordProvider.notifier).state = value,
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () => signUp(ref),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color.fromRGBO(202, 239, 184, 1),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14.0),
                        ),
                        child: const Text(
                          "Create Account",
                          style: TextStyle(
                              fontSize: 16,
                              color: Color.fromARGB(255, 0, 0, 0)),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
