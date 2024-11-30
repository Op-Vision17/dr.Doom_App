import 'package:doctor_doom/chat/chatprovider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final String username;
  final String channelname;

  const ChatScreen({
    Key? key,
    required this.username,
    required this.channelname,
  }) : super(key: key);

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
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
      ref.read(messagesProvider.notifier).sendMessage(widget.username, message);
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
    final messages = ref.watch(messagesProvider);

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 233, 201, 152), // Light beige
      body: Stack(
        children: [
          // Gradient Header
          ClipPath(
            clipper: WaveClipper(),
            child: Container(
              height: MediaQuery.of(context).size.height * 0.2,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF333333), // Dark Grey
                    Color(0xFF1E1E1E), // Black
                  ],
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
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFFFFA500), // Shiny orange
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'User: ${widget.username}',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Chat and Input Section
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(top: 145.0),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF2C2C2C), // Dark Grey container
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16.0),
                    topRight: Radius.circular(16.0),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
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
                          final username = message['username'] ?? 'Unknown';
                          final messageText =
                              message['message'] ?? 'No message';
                          final isUserMessage = username == widget.username;

                          return Align(
                            alignment: isUserMessage
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                            child: Container(
                              margin: const EdgeInsets.symmetric(vertical: 6.0),
                              padding: const EdgeInsets.symmetric(
                                  vertical: 12.0, horizontal: 16.0),
                              decoration: BoxDecoration(
                                color: isUserMessage
                                    ? const Color(0xFFFFA500) // Shiny orange
                                    : const Color(0xFF444444), // Dark grey
                                borderRadius: BorderRadius.circular(12.0),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 4,
                                    offset: const Offset(2, 2),
                                  ),
                                ],
                              ),
                              child: Text(
                                messageText,
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
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
                                fillColor: const Color(0xFF444444), // Dark grey
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
                                color: Color(0xFFFFA500), // Shiny orange
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

// Custom Clipper for Gradient Wave
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
