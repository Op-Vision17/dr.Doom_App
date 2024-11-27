import 'package:agora_rtc_engine/agora_rtc_engine.dart'; // Correct import
import 'dart:convert';
import 'package:http/http.dart' as http;

RtcEngine? _engine; // Declare the Agora engine as nullable

// Fill in the app ID obtained from the Agora console
const appId = "2f3131394cc6417b91aa93cfde567a37";
// Fill in the temporary token generated from Agora Console
const token = "<-- Insert token -->";
// Fill in the channel name you used to generate the token
const channel = "<-- Insert channel name -->";

/// Initialize the Agora engine
Future<void> initializeAgoraEngine(String appId) async {
  _engine = createAgoraRtcEngine(); // Create the engine instance

  await _engine!.initialize(
    RtcEngineContext(appId: appId),
  );

  print('Agora engine initialized.');
}

/// Join an Agora meeting
Future<void> joinAgoraMeeting(String token, String roomName, int uid) async {
  if (_engine == null) {
    print('Agora engine is not initialized.');
    return;
  }

  await _engine!
      .setChannelProfile(ChannelProfileType.channelProfileCommunication);

  await _engine!.joinChannel(
    token: token,
    channelId: roomName,
    uid: uid,
    options: const ChannelMediaOptions(),
  );

  print('Joined meeting successfully in channel: $roomName');
}

/// Leave an Agora meeting
Future<void> leaveAgoraMeeting(String name, int uid, String roomName) async {
  if (_engine == null) {
    print('Agora engine is not initialized.');
    return;
  }

  await _engine!.leaveChannel();
  print('Left Agora channel.');

  // Call the API to delete the member
  final result = await leaveMeeting(name, uid, roomName);

  if (result != null && result == "Member deleted") {
    print('Member deleted from the server: $name');
  } else {
    print('Failed to delete member from the server.');
  }
}

/// Call the API to delete a member from the server
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
      return response.body; // Return the response body as a string
    } else {
      print('Error: ${response.body}');
      return null;
    }
  } catch (e) {
    print('Failed to call delete_member API: $e');
    return null;
  }
}

/// Fetch an Agora token from the server
Future<String?> fetchAgoraToken(String roomName) async {
  const String apiUrl = 'https://agora-8ojc.onrender.com/get_token/';

  try {
    final response = await http.get(
      Uri.parse('$apiUrl?channel=$roomName'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['token']; // Extract and return the token
    } else {
      print('Error: ${response.body}');
      return null;
    }
  } catch (e) {
    print('Failed to fetch Agora token: $e');
    return null;
  }
}

/// Create a member in the Agora channel
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
      return data['name']; // Extracting the 'name' field from the response
    } else {
      print('Failed to load member details');
      return null;
    }
  } catch (e) {
    print('Error: $e');
    return null;
  }
}
