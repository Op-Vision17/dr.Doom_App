import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class UserStorage {
  final _storage = FlutterSecureStorage();

  
  Future<void> saveUserData(Map<String, dynamic> user, String token) async {
    await _storage.write(key: 'token', value: token);
    await _storage.write(key: 'first_name', value: user['first_name']);
    await _storage.write(key: 'last_name', value: user['last_name']);
    await _storage.write(key: 'email', value: user['email']);
    await _storage.write(key: 'phone_number', value: user['phone_number']);
  }


  Future<Map<String, String>> getUserData() async {
    final firstName = await _storage.read(key: 'first_name') ?? '';
    final lastName = await _storage.read(key: 'last_name') ?? '';
    final email = await _storage.read(key: 'email') ?? '';
    final phoneNumber = await _storage.read(key: 'phone_number') ?? '';
    
    return {
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'phone_number': phoneNumber,
    };
  }
}
