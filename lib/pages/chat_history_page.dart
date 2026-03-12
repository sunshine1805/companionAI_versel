import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class ChatHistoryPage extends StatelessWidget {
  const ChatHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat History'),
        backgroundColor: const Color(0xFF9C88D9),
        foregroundColor: Colors.white,
      ),
      body: user == null
          ? const Center(child: Text('Please log in'))
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(user.uid)
                  .collection('chats')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final messages = snapshot.data?.docs ?? [];

                if (messages.isEmpty) {
                  return const Center(
                    child: Text('No chat history yet'),
                  );
                }

                // Group messages by date
                final groupedMessages = <String, List<QueryDocumentSnapshot>>{};
                for (var msg in messages) {
                  final timestamp = (msg['timestamp'] as Timestamp?)?.toDate();
                  if (timestamp != null) {
                    final dateKey = DateFormat('yyyy-MM-dd').format(timestamp);
                    groupedMessages.putIfAbsent(dateKey, () => []);
                    groupedMessages[dateKey]!.add(msg);
                  }
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: groupedMessages.length,
                  itemBuilder: (context, index) {
                    final dateKey = groupedMessages.keys.elementAt(index);
                    final dayMessages = groupedMessages[dateKey]!;
                    final date = DateTime.parse(dateKey);

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Text(
                            DateFormat('EEEE, MMM d, yyyy').format(date),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Color(0xFF9C88D9),
                            ),
                          ),
                        ),
                        ...dayMessages.map((msg) {
                          final isUser = msg['role'] == 'user';
                          final text = msg['message'] as String;
                          final timestamp = (msg['timestamp'] as Timestamp?)?.toDate();

                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: isUser
                                    ? const Color(0xFF9C88D9)
                                    : const Color(0xFF6B9B8E),
                                child: Icon(
                                  isUser ? Icons.person : Icons.smart_toy,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                              title: Text(
                                text,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              subtitle: timestamp != null
                                  ? Text(DateFormat('h:mm a').format(timestamp))
                                  : null,
                              trailing: IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _deleteMessage(context, user.uid, msg.id),
                              ),
                            ),
                          );
                        }).toList(),
                        const SizedBox(height: 16),
                      ],
                    );
                  },
                );
              },
            ),
    );
  }

  Future<void> _deleteMessage(BuildContext context, String userId, String messageId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Message'),
        content: const Text('Are you sure you want to delete this message?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('chats')
            .doc(messageId)
            .delete();

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Message deleted')),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }
}