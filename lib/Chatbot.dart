import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:intl/intl.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _userMessage = TextEditingController();

  static const apiKey = "AIzaSyAvD04sAlETnC8JiPeje4oiDqVRIQQXCeI";

  final model = GenerativeModel(model: 'gemini-pro', apiKey: apiKey);

  final List<Message> _messages = [];
  bool _isLoading = false;

  Future<void> sendMessage() async {
    final message = _userMessage.text.trim();
    if (message.isEmpty) return;

    _userMessage.clear();

    setState(() {
      _messages.add(Message(
        isUser: true,
        message: message,
        date: DateTime.now(),
      ));
      _isLoading = true; // Start loader
    });

    try {
      final content = [Content.text(message)];
      final response = await model.generateContent(content);

      setState(() {
        _messages.add(Message(
          isUser: false,
          message: response.text?.trim() ?? "No response received.",
          date: DateTime.now(),
        ));
      });
    } catch (e) {
      setState(() {
        _messages.add(Message(
          isUser: false,
          message: "Error: Unable to process your request.",
          date: DateTime.now(),
        ));
      });
    } finally {
      setState(() {
        _isLoading = false; // Stop loader
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent, // Transparent to show gradient
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.green.shade800, Colors.green.shade200], // TrashNada gradient
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // AppBar with TrashBot title
              AppBar(
                elevation: 0, // Remove shadow to blend with gradient
                backgroundColor: Colors.transparent, // Transparent to show gradient
                title: const Text(
                  'TrashBot',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 25,
                  ),
                ),
                centerTitle: true,
                leading: IconButton(
                  icon: Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                actions: [
                  IconButton(
                    icon: Icon(Icons.notifications, color: Colors.white),
                    onPressed: () {
                      // Placeholder for notifications
                    },
                  ),
                ],
              ),
              // Chat messages
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    final message = _messages[index];
                    return Messages(
                      isUser: message.isUser,
                      message: message.message,
                      date: DateFormat('HH:mm').format(message.date),
                    );
                  },
                ),
              ),
              // Loader for bot response
              if (_isLoading)
                const Padding(
                  padding: EdgeInsets.all(10.0),
                  child: CircularProgressIndicator(color: Colors.white),
                ),
              // Message input area
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 15),
                child: Row(
                  children: [
                    Expanded(
                      flex: 15,
                      child: TextFormField(
                        style: const TextStyle(color: Colors.white),
                        controller: _userMessage,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.green.shade700.withOpacity(0.2), // Light green for input
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(60),
                            borderSide: BorderSide(color: Colors.green.shade600),
                          ),
                          labelText: "Enter your message",
                          labelStyle: const TextStyle(color: Colors.white70),
                          suffixIcon: IconButton(
                            icon: Icon(Icons.send, color: Colors.white),
                            onPressed: sendMessage,
                          ),
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
    );
  }
}

class Messages extends StatelessWidget {
  final bool isUser;
  final String message;
  final String date;

  const Messages({
    super.key,
    required this.isUser,
    required this.message,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      margin: const EdgeInsets.symmetric(vertical: 10).copyWith(
        left: isUser ? 100 : 10,
        right: isUser ? 10 : 100,
      ),
      decoration: BoxDecoration(
        color: isUser ? Colors.green.shade700 : Colors.green.shade600, // TrashNada green colors
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(15),
          bottomLeft: isUser ? const Radius.circular(15) : Radius.zero,
          topRight: const Radius.circular(15),
          bottomRight: isUser ? Radius.zero : const Radius.circular(15),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 4,
            offset: Offset(2, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: isUser
                ? Text(
                    message,
                    style: const TextStyle(color: Colors.white),
                  )
                : RichText(
                    text: TextSpan(
                      children: formatMessage(message),
                      style: const TextStyle(color: Colors.white), // White text for bot messages
                    ),
                  ),
          ),
          const SizedBox(height: 5),
          Text(
            date,
            style: TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  List<TextSpan> formatMessage(String message) {
    final regex = RegExp(r'\*\*(.*?)\*\*'); // Match text within ** **
    final spans = <TextSpan>[];

    int currentIndex = 0;
    for (final match in regex.allMatches(message)) {
      // Add text before the match
      if (match.start > currentIndex) {
        spans.add(TextSpan(text: message.substring(currentIndex, match.start)));
      }
      // Add the matched text as bold
      spans.add(
        TextSpan(
          text: match.group(1), // Get the text inside **
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
      );
      currentIndex = match.end;
    }
    // Add remaining text
    if (currentIndex < message.length) {
      spans.add(TextSpan(text: message.substring(currentIndex)));
    }

    return spans;
  }
}

class Message {
  final bool isUser;
  final String message;
  final DateTime date;

  Message({
    required this.isUser,
    required this.message,
    required this.date,
  });
}