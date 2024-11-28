import 'package:doctor_doom/agora/agoraservices.dart';
import 'package:doctor_doom/agora/apiwork.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Define a class to hold meeting state
class MeetingState {
  final String token;
  final int? uid;
  final bool meetingJoined;

  MeetingState({
    required this.token,
    this.uid,
    required this.meetingJoined,
  });

  // CopyWith method to create a new instance with updated values
  MeetingState copyWith({
    String? token,
    int? uid,
    bool? meetingJoined,
  }) {
    return MeetingState(
      token: token ?? this.token,
      uid: uid ?? this.uid,
      meetingJoined: meetingJoined ?? this.meetingJoined,
    );
  }
}

// Provider to store and manage the meeting state (token, uid, meetingJoined status)
final meetingStateProvider = StateProvider<MeetingState>((ref) {
  return MeetingState(
    token: '',
    uid: null,
    meetingJoined: false,
  );
});

// Provider for storing the room name
final roomNameProvider = StateProvider<String>((ref) => '');

// Provider for storing the user name
final userNameProvider = StateProvider<String>((ref) => '');

// Provider for storing mute status
final muteProvider = StateProvider<bool>((ref) => false);

// Provider for storing camera off status
final cameraProvider = StateProvider<bool>((ref) => false);

// Provider to initialize the meeting (returns Future<void>)
final meetingServiceProvider = FutureProvider.autoDispose<void>((ref) async {
  final roomName = ref.watch(roomNameProvider); // Get the room name
  final userName = ref.watch(userNameProvider); // Get the user name

  // Fetch the token for Agora (we can safely call fetchAgoraToken now)
  final token = await fetchAgoraToken(roomName); // Pass both roomName and ref

  // Check if token is null or empty
  if (token == null || token.isEmpty) {
    throw Exception('Token fetch failed');
  }

  // Get the UID if it's available in the state (update this based on your use case)
  final uid =
      ref.read(meetingUidProvider); // Access the UID using meetingUidProvider

  // Log token and UID for debugging
  print("Fetched Token: $token");
  print("Fetched UID: $uid");

  // Initialize Agora service
  await AgoraService.initializeAgora();
  await AgoraService.joinChannel(roomName, userName);
});
