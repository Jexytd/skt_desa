// lib/screens/user/chat_screen.dart - New Chat Screen
import 'package:flutter/material.dart';
import 'package:skt_desa/models/chat_model.dart';
import 'package:skt_desa/widgets/error_message.dart';
import '../../providers/chat_provider.dart';
import '../../models/user_model.dart';
import '../../services/auth_service.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';
import '../../widgets/custom_card_widget.dart';

class ChatScreen extends StatefulWidget {
  final String? suratId;

  const ChatScreen({Key? key, this.suratId}) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _messageController = TextEditingController();
  final _chatProvider = ChatProvider();
  UserModel? _admin;
  String? _adminId;

  @override
  void initState() {
    super.initState();
    _getAdmin();
    _loadMessages();
  }

  Future<void> _getAdmin() async {
    try {
      // Get admin user (you might want to store admin ID in a better way)
      // For demo, we'll assume admin has fixed ID or get from somewhere
      _adminId = 'adminUserId'; // Replace with actual admin ID retrieval logic
      UserModel? admin = await AuthService().getUserData(_adminId!);
      setState(() {
        _admin = admin;
      });
    } catch (e) {
      Helpers.showSnackBar(context, 'Gagal memuat data admin: $e');
    }
  }

  Future<void> _loadMessages() async {
    final userId = AuthService().currentUser!.uid;
    if (_adminId != null) {
      _chatProvider.loadMessages(userId, _adminId!);
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_admin?.name ?? 'Chat Admin'),
        backgroundColor: AppColors.primaryColor,
        actions: [
          if (_chatProvider.unreadCount > 0)
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _chatProvider.unreadCount.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // Messages List
          Expanded(
            child: _chatProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : _chatProvider.error != null
                    ? ErrorMessage(
                        message: _chatProvider.error!,
                        onRetry: _loadMessages,
                      )
                    : ListView.builder(
                        reverse: true,
                        padding: const EdgeInsets.all(16),
                        itemCount: _chatProvider.messages.length,
                        itemBuilder: (context, index) {
                          final message = _chatProvider.messages[index];
                          final isMe = message.senderId == AuthService().currentUser!.uid;
                          
                          return _buildMessageBubble(message, isMe);
                        },
                      ),
          ),
          
          // Message Input
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatModel message, bool isMe) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isMe ? AppColors.primaryColor : Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              message.message,
              style: TextStyle(
                color: isMe ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              Helpers.formatDateTime(message.timestamp),
              style: TextStyle(
                fontSize: 10,
                color: isMe ? Colors.white.withOpacity(0.7) : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: const InputDecoration(
                hintText: 'Ketik pesan...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(24)),
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.send, color: AppColors.primaryColor),
            onPressed: _sendMessage,
          ),
        ],
      ),
    );
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;
    
    final userId = AuthService().currentUser!.uid;
    if (_adminId != null) {
      _chatProvider.sendMessage(userId, _adminId!, _messageController.text.trim());
      _messageController.clear();
    }
  }
}