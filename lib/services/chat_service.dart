// lib/services/chat_service.dart - Updated with markAsReadForUser
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/chat_model.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collectionName = 'chats';

  // Get chat messages between user and admin
  Stream<List<ChatModel>> getChatMessages(String userId, String adminId) {
    return _firestore
        .collection(_collectionName)
        .where('senderId', isEqualTo: userId)
        .where('receiverId', isEqualTo: adminId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => ChatModel.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    });
  }

  // Get chat messages for admin (all users)
  Stream<List<ChatModel>> getAdminChatMessages(String adminId) {
    return _firestore
        .collection(_collectionName)
        .where('receiverId', isEqualTo: adminId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => ChatModel.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    });
  }

  // Send message
  Future<void> sendMessage(ChatModel message) async {
    await _firestore
        .collection(_collectionName)
        .doc(message.id)
        .set(message.toMap());
  }

  // Mark message as read for specific user
  Future<void> markAsReadForUser(String userId, String adminId) async {
    final snapshot = await _firestore
        .collection(_collectionName)
        .where('senderId', isEqualTo: userId)
        .where('receiverId', isEqualTo: adminId)
        .where('isRead', isEqualTo: false)
        .get();

    for (var doc in snapshot.docs) {
      await doc.reference.update({'isRead': true});
    }
  }

  // Get unread message count for user
  Future<int> getUnreadMessageCount(String userId, String adminId) async {
    final snapshot = await _firestore
        .collection(_collectionName)
        .where('senderId', isEqualTo: userId)
        .where('receiverId', isEqualTo: adminId)
        .where('isRead', isEqualTo: false)
        .get();

    return snapshot.docs.length;
  }
}