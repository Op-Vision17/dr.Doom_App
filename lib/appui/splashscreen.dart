import 'package:flutter/material.dart';
import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:lottie/lottie.dart';
import 'package:page_transition/page_transition.dart';
import 'package:doctor_doom/authentication/loginscreen.dart';
import 'package:doctor_doom/authentication/tokenmanage.dart';
import 'package:doctor_doom/appui/homescreen.dart';

class Splashscreen extends StatelessWidget {
  const Splashscreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedSplashScreen(
      splash: LayoutBuilder(
        builder: (context, constraints) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                flex: 3,
                child: Center(
                  child: Lottie.asset(
                    'assets/animations/Animation - 1732589897308.json',
                    fit: BoxFit.contain,
                    height: constraints.maxHeight * 0.4,
                  ),
                ),
              ),
              Image.asset(
                'assets/logo.png',
                fit: BoxFit.contain,
                height: constraints.maxHeight * 0.3,
              ),
            ],
          );
        },
      ),
      nextScreen: FutureBuilder<bool>(
        future: isUserLoggedIn(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text("Error checking login status"));
          }

          final bool isLoggedIn = snapshot.data ?? false;

          return isLoggedIn ? const HomeScreen() : const LoginScreen();
        },
      ),
      splashIconSize: double.infinity,
      backgroundColor: Colors.white,
      pageTransitionType: PageTransitionType.fade,
      duration: 3000,
    );
  }
}
