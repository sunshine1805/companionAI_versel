import 'dart:convert';
import 'dart:math';
import 'dart:js' as js;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> with SingleTickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = [];
  final ScrollController _scrollController = ScrollController();
  bool _isTyping = false;
  bool _isLoading = true;
  late AnimationController _animationController;

  // Voice input
  bool _isListening = false;
  String _voiceText = '';

  // Chat sessions
  String? _currentSessionId;
  List<Map<String, dynamic>> _chatSessions = [];

  final List<String> motivationalQuotes = [
    "You are capable of amazing things 💪",
    "Every small step counts 🌟",
    "It's okay to not be okay sometimes 💙",
    "You're doing better than you think 🌈",
    "Be kind to yourself today 🌸",
    "Your feelings are valid 💚",
    "Progress, not perfection ✨",
    "You are not alone in this 🤝",
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
    loadChatSessions();
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  String getRandomQuote() {
    return motivationalQuotes[Random().nextInt(motivationalQuotes.length)];
  }

  // ── Voice: Web Speech API via dart:js ──────────────────────────────────────

  void _startListening() {
    setState(() {
      _isListening = true;
      _voiceText = '';
    });

    js.context.callMethod('startSpeechRecognition', [
      js.allowInterop((String transcript) {
        if (mounted) {
          setState(() {
            _voiceText = transcript;
            _controller.text = transcript;
          });
        }
      }),
      js.allowInterop(() {
        if (mounted) setState(() => _isListening = false);
      }),
    ]);
  }

  void _stopListening() {
    js.context.callMethod('stopSpeechRecognition', []);
    setState(() => _isListening = false);
  }

  // ──────────────────────────────────────────────────────────────────────────

  Future<void> loadChatSessions() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('chat_sessions')
          .orderBy('last_updated', descending: true)
          .get();

      setState(() {
        _chatSessions = snapshot.docs.map((doc) {
          return {
            'id': doc.id,
            'title': doc['title'] ?? 'Chat Session',
            'last_updated': doc['last_updated'],
            'message_count': doc['message_count'] ?? 0,
          };
        }).toList();

        if (_chatSessions.isNotEmpty) {
          _currentSessionId = _chatSessions[0]['id'];
          loadSessionMessages(_currentSessionId!);
        } else {
          _createNewSession();
        }
      });
    } catch (e) {
      print('Error loading sessions: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> loadSessionMessages(String sessionId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() => _isLoading = true);

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('chat_sessions')
          .doc(sessionId)
          .collection('messages')
          .orderBy('timestamp')
          .get();

      setState(() {
        _messages.clear();
        for (var doc in snapshot.docs) {
          _messages.add({
            "role": doc['role'],
            "text": doc['message'],
          });
        }
        _currentSessionId = sessionId;
        _isLoading = false;
      });

      _scrollToBottom();
    } catch (e) {
      print('Error loading messages: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _createNewSession() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final sessionRef = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('chat_sessions')
          .add({
        'title': 'New Chat',
        'created_at': FieldValue.serverTimestamp(),
        'last_updated': FieldValue.serverTimestamp(),
        'message_count': 0,
      });

      setState(() {
        _currentSessionId = sessionRef.id;
        _messages.clear();
        _isLoading = false;
      });

      loadChatSessions();
    } catch (e) {
      print('Error creating session: $e');
      _showError('Failed to create new chat: $e');
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      Future.delayed(const Duration(milliseconds: 100), () {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  Future<void> sendMessage(String text) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || _currentSessionId == null) return;

    final sessionRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('chat_sessions')
        .doc(_currentSessionId);

    final messagesRef = sessionRef.collection('messages');

    try {
      await messagesRef.add({
        'role': 'user',
        'message': text,
        'timestamp': FieldValue.serverTimestamp(),
      });

      if (_messages.isEmpty) {
        final title = text.length > 30 ? '${text.substring(0, 30)}...' : text;
        await sessionRef.update({'title': title});
      }

      setState(() {
        _messages.add({"role": "user", "text": text});
        _isTyping = true;
      });

      _scrollToBottom();

      final conversationHistory = _messages.length > 10
          ? _messages.sublist(_messages.length - 10)
          : _messages;

      final apiUrl = "https://companion-ai-versel.vercel.app/api/chat";

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "messages": conversationHistory,
        }),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        await messagesRef.add({
          'role': 'ai',
          'message': data['reply'],
          'timestamp': FieldValue.serverTimestamp(),
        });

        await sessionRef.update({
          'last_updated': FieldValue.serverTimestamp(),
          'message_count': FieldValue.increment(2),
        });

        setState(() {
          _messages.add({"role": "ai", "text": data['reply']});
          _isTyping = false;
        });

        _scrollToBottom();
      } else {
        throw Exception('Server returned ${response.statusCode}');
      }
    } catch (e) {
      print('Error sending message: $e');
      setState(() => _isTyping = false);
      _showError("Failed to get response: $e");
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showSessionsDrawer() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Text(
                    'Chat Sessions',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.add_circle, color: Color(0xFF9C88D9)),
                    onPressed: () {
                      Navigator.pop(context);
                      _createNewSession();
                    },
                    tooltip: 'New Chat',
                  ),
                ],
              ),
            ),
            Expanded(
              child: _chatSessions.isEmpty
                  ? const Center(child: Text('No chat sessions yet'))
                  : ListView.builder(
                      itemCount: _chatSessions.length,
                      itemBuilder: (context, index) {
                        final session = _chatSessions[index];
                        final isActive = session['id'] == _currentSessionId;

                        return ListTile(
                          selected: isActive,
                          selectedTileColor:
                              const Color(0xFF9C88D9).withOpacity(0.1),
                          leading: CircleAvatar(
                            backgroundColor: isActive
                                ? const Color(0xFF9C88D9)
                                : Colors.grey[300],
                            child: Icon(
                              Icons.chat,
                              color: isActive ? Colors.white : Colors.grey,
                              size: 20,
                            ),
                          ),
                          title: Text(
                            session['title'],
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontWeight: isActive
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                          subtitle: Text(
                            '${session['message_count']} messages',
                            style: const TextStyle(fontSize: 12),
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete,
                                color: Colors.red, size: 20),
                            onPressed: () => _deleteSession(session['id']),
                          ),
                          onTap: () {
                            Navigator.pop(context);
                            loadSessionMessages(session['id']);
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteSession(String sessionId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final messages = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('chat_sessions')
          .doc(sessionId)
          .collection('messages')
          .get();

      for (var doc in messages.docs) {
        await doc.reference.delete();
      }

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('chat_sessions')
          .doc(sessionId)
          .delete();

      if (sessionId == _currentSessionId) {
        await loadChatSessions();
      } else {
        loadChatSessions();
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Chat session deleted')),
        );
      }
    } catch (e) {
      _showError('Failed to delete session: $e');
    }
  }

  Widget _buildLogoAvatar({double size = 30}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 5,
          ),
        ],
      ),
      child: ClipOval(
        child: Image.asset(
          'assets/images/logo.png',
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: const Color(0xFF6B9B8E).withOpacity(0.1),
              child: Icon(
                Icons.favorite,
                color: const Color(0xFF6B9B8E),
                size: size * 0.6,
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F0FF),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.grey),
          onPressed: _showSessionsDrawer,
          tooltip: 'Chat Sessions',
        ),
        title: Row(
          children: [
            _buildLogoAvatar(size: 35),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'CompanionAI',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    'Always here for you',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline,
                color: Color(0xFF9C88D9)),
            tooltip: 'New chat',
            onPressed: _createNewSession,
          ),
        ],
      ),
      body: SafeArea(
        child: _isLoading
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(
                      color: Color(0xFF9C88D9),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Loading conversation...',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              )
            : Column(
                children: [
                  Expanded(
                    child: _messages.isEmpty
                        ? _buildEmptyState()
                        : ListView.builder(
                            controller: _scrollController,
                            padding: const EdgeInsets.all(16),
                            itemCount: _messages.length,
                            itemBuilder: (context, index) {
                              final msg = _messages[index];
                              final isUser = msg['role'] == 'user';
                              return _buildMessageBubble(
                                  msg['text']!, isUser);
                            },
                          ),
                  ),
                  if (_isTyping) _buildTypingIndicator(),
                  if (_isListening) _buildListeningIndicator(),
                  _buildInputArea(),
                ],
              ),
      ),
    );
  }

  Widget _buildListeningIndicator() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: const Color(0xFF9C88D9).withOpacity(0.1),
      child: Row(
        children: [
          const Icon(Icons.mic, color: Color(0xFF9C88D9)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _voiceText.isEmpty ? 'Listening...' : _voiceText,
              style: const TextStyle(fontSize: 15),
            ),
          ),
          TextButton(
            onPressed: _stopListening,
            child: const Text('Stop',
                style: TextStyle(color: Color(0xFF9C88D9))),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: const Color(0xFF9C88D9).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.chat_bubble_outline,
                size: 60,
                color: Color(0xFF9C88D9),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Hi! I\'m CompanionAI',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D3748),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              getRandomQuote(),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFF6B9B8E),
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildSuggestion('How to manage stress?'),
                  const Divider(height: 16),
                  _buildSuggestion('I feel overwhelmed'),
                  const Divider(height: 16),
                  _buildSuggestion('Tips for better sleep'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestion(String text) {
    return InkWell(
      onTap: () {
        _controller.text = text;
        sendMessage(text);
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.lightbulb_outline,
            size: 18,
            color: Color(0xFF9C88D9),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14),
            ),
          ),
          Icon(
            Icons.arrow_forward_ios,
            size: 14,
            color: Colors.grey[400],
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(String text, bool isUser) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!isUser) ...[
            _buildLogoAvatar(),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                gradient: isUser
                    ? const LinearGradient(
                        colors: [Color(0xFF9C88D9), Color(0xFF6B9B8E)],
                      )
                    : null,
                color: isUser ? null : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: Radius.circular(isUser ? 20 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                text,
                style: TextStyle(
                  color: isUser ? Colors.white : Colors.black87,
                  fontSize: 15,
                  height: 1.4,
                ),
              ),
            ),
          ),
          if (isUser) const SizedBox(width: 8),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildLogoAvatar(),
          const SizedBox(width: 8),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 5,
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDot(0),
                const SizedBox(width: 4),
                _buildDot(1),
                const SizedBox(width: 4),
                _buildDot(2),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDot(int index) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        final delay = index * 0.2;
        final value = ((_animationController.value - delay) % 1.0);
        final opacity = (sin(value * pi * 2) + 1) / 2;

        return Opacity(
          opacity: opacity * 0.5 + 0.5,
          child: Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: Color(0xFF9C88D9),
              shape: BoxShape.circle,
            ),
          ),
        );
      },
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Voice input button
          Container(
            decoration: BoxDecoration(
              color: _isListening
                  ? const Color(0xFF9C88D9)
                  : const Color(0xFFF5F0FF),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: Icon(
                _isListening ? Icons.mic : Icons.mic_none,
                color: _isListening
                    ? Colors.white
                    : const Color(0xFF9C88D9),
              ),
              onPressed: _isListening ? _stopListening : _startListening,
              tooltip: _isListening ? 'Stop recording' : 'Voice input',
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              constraints: const BoxConstraints(maxHeight: 120),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F0FF),
                borderRadius: BorderRadius.circular(24),
              ),
              child: TextField(
                controller: _controller,
                maxLines: null,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  hintText: "Share what's on your mind...",
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Colors.grey),
                ),
                style: const TextStyle(fontSize: 15),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF9C88D9), Color(0xFF6B9B8E)],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF9C88D9).withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              icon: const Icon(Icons.send_rounded, color: Colors.white),
              onPressed: _isTyping
                  ? null
                  : () {
                      if (_controller.text.trim().isNotEmpty) {
                        sendMessage(_controller.text.trim());
                        _controller.clear();
                      }
                    },
            ),
          ),
        ],
      ),
    );
  }
}