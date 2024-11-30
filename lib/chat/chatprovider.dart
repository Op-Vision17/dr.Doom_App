import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

final websocketProvider = Provider<WebSocketChannel>((ref) {
  return WebSocketChannel.connect(
    Uri.parse('ws://agora-8ojc.onrender.com/ws/Chat/'),
  );
});

final messagesProvider =
    StateNotifierProvider<MessagesNotifier, List<Map<String, dynamic>>>((ref) {
  final channel = ref.watch(websocketProvider);

  return MessagesNotifier(channel);
});

class MessagesNotifier extends StateNotifier<List<Map<String, dynamic>>> {
  final WebSocketChannel channel;

  MessagesNotifier(this.channel) : super([]) {
    channel.stream.listen((data) {
      final message = json.decode(data);
      state = [...state, message];
    });
  }

  void sendMessage(String username, String message) {
    if (username.isEmpty || message.isEmpty) return;

    final data = {
      'username': username,
      'message': message,
    };

    channel.sink.add(json.encode(data));
  }

  void removeAllMessages() {
    state = [];
  }

  @override
  void dispose() {
    channel.sink.close();
    super.dispose();
  }
}
