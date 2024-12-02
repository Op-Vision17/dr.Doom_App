import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:loading_animation_widget/loading_animation_widget.dart';

final chatProvider =
    StateNotifierProvider<ChatNotifier, List<Map<String, String>>>(
  (ref) => ChatNotifier(),
);

class ChatNotifier extends StateNotifier<List<Map<String, String>>> {
  ChatNotifier() : super([]);

  bool isLoading = false;

  Future<void> sendMessage(String username, String message) async {
    final messages = List<Map<String, String>>.from(state);

    isLoading = true;
    state = [
      ...messages,
      {'username': username, 'message': message}
    ];

    try {
      final response = await http.post(
        Uri.parse('https://chat-l31s.onrender.com/detail'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'text': message}),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        dynamic botMessage = responseData['information'] ?? 'No response';

        state = [
          ...state,
          {'username': 'Bot', 'message': botMessage}
        ];
      } else {
        state = [
          ...state,
          {'username': 'Bot', 'message': 'Failed to fetch response.'}
        ];
      }
    } catch (e) {
      state = [
        ...state,
        {'username': 'Bot', 'message': 'Error: $e'}
      ];
    } finally {
      isLoading = false;
    }
  }

  void deleteAllMessages() {
    state = [];
  }
}

class Aichat extends ConsumerStatefulWidget {
  final String username;
  final String channelname;

  const Aichat({
    Key? key,
    required this.username,
    required this.channelname,
  }) : super(key: key);

  @override
  ConsumerState<Aichat> createState() => _AichatState();
}

class _AichatState extends ConsumerState<Aichat> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final message = _messageController.text.trim();
    if (message.isNotEmpty) {
      ref.read(chatProvider.notifier).sendMessage(widget.username, message);
      _messageController.clear();

      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 50,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final messages = ref.watch(chatProvider);
    final isLoading = ref.watch(chatProvider.notifier).isLoading;

    return Scaffold(
      backgroundColor: const Color(0xFF444444),
      body: Stack(
        children: [
          ClipPath(
            clipper: WaveClipper(),
            child: Container(
              height: MediaQuery.of(context).size.height * 0.15,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF333333), Color(0xFF1E1E1E)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Meeting: ${widget.channelname}',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFFFFA500),
                      ),
                    ),
                    const SizedBox(height: 5),
                  ],
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(top: 100.0),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 233, 201, 152),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16.0),
                    topRight: Radius.circular(16.0),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color.fromARGB(255, 84, 84, 84)
                          .withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(16.0),
                        itemCount: messages.length,
                        itemBuilder: (context, index) {
                          final message = messages[index];
                          final username = message['username']!;
                          final messageText = message['message']!;
                          final isUserMessage = username == widget.username;

                          return Align(
                            alignment: isUserMessage
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                            child: Container(
                              margin: const EdgeInsets.symmetric(vertical: 6.0),
                              padding: const EdgeInsets.symmetric(
                                  vertical: 8.0, horizontal: 14.0),
                              decoration: BoxDecoration(
                                color: isUserMessage
                                    ? const Color(0xFFFFA500)
                                    : const Color(0xFF444444),
                                borderRadius: BorderRadius.circular(12.0),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color.fromARGB(255, 14, 14, 14)
                                        .withOpacity(0.1),
                                    blurRadius: 4,
                                    offset: const Offset(2, 2),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: isUserMessage
                                    ? CrossAxisAlignment.end
                                    : CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "~ $username",
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    messageText,
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    if (isLoading) ...[
                      LoadingAnimationWidget.progressiveDots(
                        color: const Color.fromARGB(255, 14, 14, 14),
                        size: 50,
                      ),
                    ],
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _messageController,
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: const Color(0xFF444444),
                                hintText: 'Type your message...',
                                hintStyle: const TextStyle(
                                  color: Colors.white70,
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 12.0,
                                  horizontal: 16.0,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30.0),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8.0),
                          GestureDetector(
                            onTap: _sendMessage,
                            child: Container(
                              padding: const EdgeInsets.all(12.0),
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color(0xFFFFA500),
                              ),
                              child: const Icon(
                                Icons.send,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height - 50);
    path.quadraticBezierTo(
        size.width / 2, size.height, size.width, size.height - 50);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return false;
  }
}
