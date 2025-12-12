// lib/providers/auth_provider.dart - New Provider
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  UserModel? _currentUser;
  bool _isLoading = false;
  String? _error;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      UserCredential? result = await _authService.signInWithEmailAndPassword(
        email.trim(),
        password,
      );

      if (result != null) {
        UserModel? user = await _authService.getUserData(result.user!.uid);
        _currentUser = user;
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> register(String email, String password, String name, String role) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      UserCredential? result = await _authService.registerWithEmailAndPassword(
        email.trim(),
        password,
        name,
        role,
      );

      if (result != null) {
        UserModel? user = await _authService.getUserData(result.user!.uid);
        _currentUser = user;
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _authService.signOut();
    _currentUser = null;
    notifyListeners();
  }

  Future<void> updateProfile(UserModel updatedUser) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      bool success = await _authService.updateUserData(updatedUser);
      if (success) {
        _currentUser = updatedUser;
      } else {
        _error = 'Gagal memperbarui profil';
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}