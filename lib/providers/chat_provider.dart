// lib/providers/chat_provider.dart - Updated with markAsReadForUser
import 'package:flutter/material.dart';
import '../models/chat_model.dart';
import '../services/chat_service.dart';

class ChatProvider with ChangeNotifier {
  final ChatService _chatService = ChatService();
  List<ChatModel> _messages = [];
  bool _isLoading = false;
  String? _error;
  int _unreadCount = 0;

  List<ChatModel> get messages => _messages;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get unreadCount => _unreadCount;

  Future<void> loadMessages(String userId, String adminId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final stream = _chatService.getChatMessages(userId, adminId);
      stream.listen((messages) {
        _messages = messages;
        notifyListeners();
      });
      
      _unreadCount = await _chatService.getUnreadMessageCount(userId, adminId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> sendMessage(String userId, String adminId, String message) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final chatMessage = ChatModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        senderId: userId,
        receiverId: adminId,
        message: message,
        timestamp: DateTime.now(),
      );

      await _chatService.sendMessage(chatMessage);
      _messages.insert(0, chatMessage);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> markMessagesAsRead(String userId, String adminId) async {
    try {
      await _chatService.markAsReadForUser(userId, adminId);
      _unreadCount = 0;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
}