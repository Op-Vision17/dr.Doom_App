import 'package:doctor_doom/appui/Schedule.dart';
import 'package:doctor_doom/appui/joinmeeting2.dart';
import 'package:doctor_doom/appui/profile.dart';
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
                padding: const EdgeInsets.only(top: 20.0, bottom: 20),
                child: Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.person_2_rounded,
                              color: Color.fromARGB(255, 240, 176, 58),
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ProfilePage()),
                              );
                            },
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.logout_rounded,
                              color: Color.fromARGB(255, 232, 156, 16),
                            ),
                            onPressed: () async {
                              await logout(context);
                            },
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
                  color: const Color.fromARGB(255, 210, 167, 89),
                  shadows: [
                    Shadow(
                      color: const Color(0xFF808080)
                          .withOpacity(0.5), // Gray shadow
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
                      onPressed: () {
                        Navigator.of(context).push(PageRouteBuilder(
                          pageBuilder:
                              (context, animation, secondaryAnimation) =>
                                  ScheduleMeetingScreen(),
                          transitionsBuilder:
                              (context, animation, secondaryAnimation, child) {
                            const curve = Curves.easeInOut;

                            return Stack(
                              children: [
                                SlideTransition(
                                  position: Tween<Offset>(
                                    begin: Offset(1.5, 0),
                                    end: Offset.zero,
                                  ).animate(CurvedAnimation(
                                    parent: animation,
                                    curve: curve,
                                  )),
                                  child: Container(color: Colors.blue),
                                ),
                                SlideTransition(
                                  position: Tween<Offset>(
                                    begin: Offset(1.0, 0),
                                    end: Offset.zero,
                                  ).animate(CurvedAnimation(
                                    parent: animation,
                                    curve: curve,
                                  )),
                                  child: child,
                                ),
                              ],
                            );
                          },
                        ));
                      },
                    ),
                    const SizedBox(height: 20),
                    const SizedBox(height: 20),
                    ActionButton(
                      label: "Join Meeting",
                      onPressed: () {
                        Navigator.of(context).push(PageRouteBuilder(
                          pageBuilder:
                              (context, animation, secondaryAnimation) =>
                                  Joinmeeting2(),
                          transitionsBuilder:
                              (context, animation, secondaryAnimation, child) {
                            const curve = Curves.easeInOut;

                            return Stack(
                              children: [
                                SlideTransition(
                                  position: Tween<Offset>(
                                    begin: Offset(1.5, 0),
                                    end: Offset.zero,
                                  ).animate(CurvedAnimation(
                                    parent: animation,
                                    curve: curve,
                                  )),
                                  child: Container(color: Colors.blue),
                                ),
                                SlideTransition(
                                  position: Tween<Offset>(
                                    begin: Offset(1.0, 0),
                                    end: Offset.zero,
                                  ).animate(CurvedAnimation(
                                    parent: animation,
                                    curve: curve,
                                  )),
                                  child: child,
                                ),
                              ],
                            );
                          },
                        ));
                      },
                    ),
                    const SizedBox(height: 20),
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
      padding: const EdgeInsets.symmetric(horizontal: 20),
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor:
              const Color.fromARGB(255, 234, 167, 43), // Shiny Orange
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
