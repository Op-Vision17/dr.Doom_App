import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

final websocketProvider =
    Provider.family<WebSocketChannel, String>((ref, channelname) {
  return WebSocketChannel.connect(
    Uri.parse('ws://agora.naitikk.tech:8000/ws/chat/$channelname/'),
  );
});

final messagesProvider = StateNotifierProvider.family<MessagesNotifier,
    List<Map<String, dynamic>>, String>((ref, channelname) {
  final channel = ref.watch(websocketProvider(channelname));
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
