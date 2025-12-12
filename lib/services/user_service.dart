// lib/services/user_service.dart - New User Service
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get user data
  Future<UserModel?> getUserData(String uid) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return UserModel.fromMap(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      print('Error getting user data: $e');
      return null;
    }
  }

  // Get all users (for admin)
  Future<List<UserModel>> getAllUsers() async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('users')
          .orderBy('name')
          .get();

      return querySnapshot.docs
          .map((doc) => UserModel.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error getting all users: $e');
      return [];
    }
  }

  // Update user data
  Future<bool> updateUserData(UserModel user) async {
    try {
      await _firestore.collection('users').doc(user.uid).update(user.toMap());
      return true;
    } catch (e) {
      print('Error updating user data: $e');
      return false;
    }
  }

  // Delete user (admin only)
  Future<bool> deleteUser(String uid) async {
    try {
      await _firestore.collection('users').doc(uid).delete();
      return true;
    } catch (e) {
      print('Error deleting user: $e');
      return false;
    }
  }
}