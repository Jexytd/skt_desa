// lib/services/base_service.dart - Base Service for Common Functionality
import 'package:flutter/material.dart';

abstract class BaseService {
  void showSnackBar(BuildContext context, String message, {Color? color});
  Future<void> handleLoading<T>(
    BuildContext context,
    Future<T> future, {
    String? successMessage,
    String? errorMessage,
    Function(T)? onSuccess,
  });
}

class ServiceImplementation implements BaseService {
  @override
  void showSnackBar(BuildContext context, String message, {Color? color}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color ?? Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Future<void> handleLoading<T>(
    BuildContext context,
    Future<T> future, {
    String? successMessage,
    String? errorMessage,
    Function(T)? onSuccess,
  }) async {
    try {
      final result = await future;
      if (successMessage != null) {
        showSnackBar(context, successMessage, color: Colors.green);
      }
      if (onSuccess != null) {
        onSuccess(result);
      }
    } catch (e) {
      showSnackBar(context, errorMessage ?? 'Terjadi kesalahan: $e');
    }
  }
}