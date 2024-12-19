import 'package:doctor_doom/appui/profile.dart';
import 'package:doctor_doom/appui/profileedit.dart';

import 'package:doctor_doom/authentication/tokenmanage.dart';
import 'package:doctor_doom/services/user_storage.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:doctor_doom/authentication/loginscreen.dart';

class AccountScreen extends StatelessWidget {
  AccountScreen({super.key});

  Future<void> logout(BuildContext context) async {
    await clearToken();
    await emaildelete();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 233, 201, 152),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2C2C2C),
        title: Text(
          'Account',
          style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        elevation: 2,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.05,
          vertical: screenHeight * 0.02,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                stylecontainer(
                  label: 'Your Profile',
                  icon: FontAwesomeIcons.userLarge,
                  navigationScreen: ProfilePage(),
                ),
                stylecontainer(
                  label: 'Edit Profile',
                  icon: FontAwesomeIcons.userEdit,
                  navigationScreen: UpdateProfilePage(),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2C2C2C),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                padding: EdgeInsets.symmetric(
                  vertical: screenHeight * 0.02,
                  horizontal: screenWidth * 0.25,
                ),
              ),
              child: Text(
                "Settings",
                style: GoogleFonts.roboto(
                  fontSize: screenWidth * 0.05,
                  fontWeight: FontWeight.bold,
                  color: Colors.orangeAccent,
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2C2C2C),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                padding: EdgeInsets.symmetric(
                  vertical: screenHeight * 0.02,
                  horizontal: screenWidth * 0.25,
                ),
              ),
              child: Text(
                "customer review",
                style: GoogleFonts.roboto(
                  fontSize: screenWidth * 0.05,
                  fontWeight: FontWeight.bold,
                  color: Colors.orangeAccent,
                ),
              ),
            ),
            const SizedBox(height: 30),
            Spacer(),
            Align(
              alignment: Alignment.bottomLeft,
              child: ElevatedButton(
                onPressed: () async {
                  await logout(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  padding: EdgeInsets.symmetric(
                    vertical: screenHeight * 0.02,
                    horizontal: screenWidth * 0.15,
                  ),
                ),
                child: Text(
                  "Logout",
                  style: GoogleFonts.roboto(
                    fontSize: screenWidth * 0.05,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class stylecontainer extends StatelessWidget {
  final String label;
  final IconData icon;
  final Widget navigationScreen;
  const stylecontainer({
    required this.label,
    required this.icon,
    required this.navigationScreen,
  });

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => navigationScreen),
        );
      },
      child: Container(
        padding: EdgeInsets.all(screenWidth * 0.03),
        margin: EdgeInsets.all(screenWidth * 0.03),
        decoration: BoxDecoration(
          color: const Color(0xFF2C2C2C),
          borderRadius: BorderRadius.circular(16.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: Colors.orangeAccent,
              size: screenWidth * 0.2,
            ),
            const SizedBox(height: 20),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: screenWidth * 0.05,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
