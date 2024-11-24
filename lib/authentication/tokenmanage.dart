import 'package:shared_preferences/shared_preferences.dart';

Future<void> saveToken(String token) async {
  final prefs = await SharedPreferences.getInstance();
  prefs.setString('auth_token', token);
}

Future<String?> getToken() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('auth_token');
}

Future<bool> isUserLoggedIn() async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('auth_token');
  return token != null && token.isNotEmpty;
}

Future<void> clearToken() async {
  final prefs = await SharedPreferences.getInstance();
  prefs.remove('auth_token');
}
