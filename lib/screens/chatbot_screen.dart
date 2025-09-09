import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
} 

class _ChatbotScreenState extends State<ChatbotScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = [];
  bool _isLoading = false;

  // Human-like responses
  final Map<String, String> _keywordReplies = {
    "hi": "Hey! Great to see you. How's your day going?",
    "hello": "Hello! How are you feeling today?",
    "hey": "Hi there! Ready to chat about staying healthy?",
    " calculate my bmi": "You can check your BMI using the calculator on the dashboard—it helps track your health!",
    "bye": "It was nice talking to you! Take care and stay active!",
    "midterm snack": "Try enjoying some fresh fruits or a handful of nuts instead of chips—they keep you full and energized!",
    "increase protein in diet": "Adding eggs, chicken, or legumes to your meals can really help you stay strong and healthy.",
    "tips for weight loss": "Focus on balanced meals and regular movement. Small, consistent changes make a huge difference!",
    "tips for weight gain": "Eating nutrient-rich meals with protein and healthy fats can help you gain weight safely.",
    "opinion about exercise": "A little daily exercise goes a long way—maybe a short walk or stretching today?",
    "proper sleep": "Try to get 6–8 hours of restful sleep—it makes your body and mind feel great.",
    "sugar cut": "Sweet treats are okay sometimes, but moderation keeps you feeling good and energetic.",
    "ideal breakfast": "A healthy breakfast could be eggs, oats, or even a smoothie. It sets the tone for the day!",
    "lunch": "Include a mix of proteins, vegetables, and whole grains to keep your energy steady.",
    "dinner": "Keep it light—vegetables and protein work best, and avoid heavy carbs before bed.",
    "a cheat day": "It’s okay to treat yourself once in a while. Balance is key!",
    "need motivation": "Remember, consistency is more important than perfection. You’ve got this!",
    "how to overcome stress": "Take a deep breath, maybe a short walk, or just relax for a few minutes—it helps a lot!",
    "fiber foods benefits": "Eating fruits, vegetables, and oats helps digestion and keeps you feeling lighter.",
  };

  String _generateBotReply(String userMessage) {
    final msgLower = userMessage.toLowerCase();
    for (var keyword in _keywordReplies.keys) {
      if (msgLower.contains(keyword)) {
        return _keywordReplies[keyword]!;
      }
    }
    return "I see! Can you tell me a bit more, so I can give better advice?";
  }

  void _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    _controller.clear();

    // Add user message locally
    setState(() {
      _messages.add({'role': 'user', 'content': text});
      _isLoading = true;
    });

    // Generate bot reply
    String botReply = _generateBotReply(text);

    // Add bot reply locally
    setState(() {
      _messages.add({'role': 'bot', 'content': botReply});
      _isLoading = false;
    });

    // Save messages to Firebase
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        await FirebaseFirestore.instance
            .collection('chats')
            .doc(user.uid)
            .set({
          'messages': FieldValue.arrayUnion([
            {'role': 'user', 'content': text},
            {'role': 'bot', 'content': botReply},
          ])
        }, SetOptions(merge: true));
      } catch (e) {
        print("Firebase save error: $e");
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Diet Chatbot"),
        backgroundColor: Colors.green,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final isUser = msg['role'] == 'user';
                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.7,
                    ),
                    decoration: BoxDecoration(
                      color: isUser ? Colors.green : Colors.grey[300],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      msg['content']!,
                      style: TextStyle(color: isUser ? Colors.white : Colors.black87),
                    ),
                  ),
                );
              },
            ),
          ),
          if (_isLoading) const LinearProgressIndicator(),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: "Ask me anything about your health...",
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send),
                  color: Colors.green,
                  onPressed: _isLoading ? null : _sendMessage,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
