import 'package:shared_preferences/shared_preferences.dart';

Future<void> saveUserDetails(
    String firstName, String lastName, String email, String phoneNumber) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('firstName', firstName);
  await prefs.setString('lastName', lastName);
  await prefs.setString('email', email);
  await prefs.setString('phoneNumber', phoneNumber);
}
