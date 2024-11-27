import 'dart:convert';
import 'package:http/http.dart' as http;

Future<String?> leaveMeeting(String name, int uid, String roomName) async {
  const String apiUrl = 'https://agora-8ojc.onrender.com/delete_member/';

  try {
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name,
        'UID': uid,
        'room_name': roomName,
      }),
    );

    if (response.statusCode == 200) {
      return response.body;
    } else {
      print('Error: ${response.body}');
      return null;
    }
  } catch (e) {
    print('Failed to call delete_member API: $e');
    return null;
  }
}

Future<Map<String, dynamic>?> fetchAgoraToken(String roomName) async {
  const String apiUrl = 'https://agora-8ojc.onrender.com/get_token/';

  try {
    final response = await http.get(
      Uri.parse('$apiUrl?channel=$roomName'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      final token = data['token'];
      final int uid = data['uid'];

      return {'token': token, 'uid': uid};
    } else {
      print('Error: ${response.body}');
      return null;
    }
  } catch (e) {
    print('Failed to fetch Agora token: $e');
    return null;
  }
}

Future<bool> createMember(String name, int uid, String roomName) async {
  const String apiUrl = 'https://agora-8ojc.onrender.com/create_member/';

  try {
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name,
        'UID': uid,
        'room_name': roomName,
      }),
    );

    if (response.statusCode == 200) {
      print('Member created successfully: ${response.body}');
      return true;
    } else {
      print('Error: ${response.body}');
      return false;
    }
  } catch (e) {
    print('Failed to create member: $e');
    return false;
  }
}

Future<String?> fetchMemberDetails(String uid, String roomName) async {
  final url = Uri.parse(
      'https://agora-8ojc.onrender.com/get_member/?UID=$uid&room_name=$roomName');

  try {
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['name'];
    } else {
      print('Failed to load member details');
      return null;
    }
  } catch (e) {
    print('Error: $e');
    return null;
  }
}
