import 'package:doctor_doom/appui/CreateMeeting.dart';
import 'package:doctor_doom/appui/MeetingIDscreen.dart';
import 'package:doctor_doom/appui/joinmeeting.dart';
import 'package:doctor_doom/appui/profile.dart';

import 'package:doctor_doom/appui/startmeeting.dart';

import 'package:doctor_doom/authentication/loginscreen.dart';
import 'package:doctor_doom/authentication/tokenmanage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  Future<void> logout(BuildContext context) async {
    await clearToken();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/homeui.png"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 30.0, bottom: 20),
                child: Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 15.0, right: 10.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Dr. Doom",
                            style: GoogleFonts.kablammo(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: const Color.fromRGBO(202, 239, 184, 1),
                              shadows: [
                                Shadow(
                                  color:
                                      const Color.fromARGB(255, 188, 232, 190)
                                          .withOpacity(0.5),
                                  offset: const Offset(2, 2),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                            textAlign: TextAlign.start,
                          ),
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.person_2_rounded,
                                    color: Colors.white),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => ProfilePage()),
                                  );
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.logout_rounded,
                                    color: Colors.white),
                                onPressed: () async {
                                  await logout(context);
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
              Text(
                'Be more Productive,\nand Efficient Work\nwith Teams...',
                style: GoogleFonts.barrio(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: const Color.fromARGB(255, 255, 255, 255),
                  shadows: [
                    Shadow(
                      color: const Color.fromARGB(255, 160, 160, 160)
                          .withOpacity(0.5),
                      offset: const Offset(2, 2),
                      blurRadius: 4,
                    ),
                  ],
                ),
                textAlign: TextAlign.start,
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.only(bottom: 30.0),
                child: Column(
                  children: [
                    ActionButton(
                      label: "Schedule Now",
                      onPressed: () {},
                    ),
                    const SizedBox(height: 20),
                    ActionButton(
                      label: "Start Meeting",
                      onPressed: () {
                        Navigator.of(context).push(PageRouteBuilder(
                          pageBuilder:
                              (context, animation, secondaryAnimation) =>
                                  Startmeeting(),
                          transitionsBuilder:
                              (context, animation, secondaryAnimation, child) {
                            const curve = Curves.easeInOut;

                            return SlideTransition(
                              position: Tween<Offset>(
                                begin: Offset(1.5, 0),
                                end: Offset.zero,
                              ).animate(CurvedAnimation(
                                parent: animation,
                                curve: curve,
                              )),
                              child: child,
                            );
                          },
                        ));
                      },
                    ),
                    const SizedBox(height: 20),
                    ActionButton(
                      label: "Join Meeting",
                      onPressed: () {
                        Navigator.of(context).push(PageRouteBuilder(
                          pageBuilder:
                              (context, animation, secondaryAnimation) =>
                                  JoinMeetingScreen(),
                          transitionsBuilder:
                              (context, animation, secondaryAnimation, child) {
                            const curve = Curves.easeInOut;

                            return SlideTransition(
                              position: Tween<Offset>(
                                begin: Offset(1.5, 0),
                                end: Offset.zero,
                              ).animate(CurvedAnimation(
                                parent: animation,
                                curve: curve,
                              )),
                              child: child,
                            );
                          },
                        ));
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class ActionButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const ActionButton({
    Key? key,
    required this.label,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20),
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          elevation: 10,
          shadowColor: Colors.black.withOpacity(0.4),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
