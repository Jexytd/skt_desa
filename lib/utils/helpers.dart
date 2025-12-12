import 'package:flutter/material.dart';

class Helpers {
  // Show snackbar
  static void showSnackBar(BuildContext context, String message, {Color? color}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color ?? Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // Format date
  static String formatDate(DateTime date) {
    return '${date.day}-${date.month}-${date.year}';
  }

  // Format date time
  static String formatDateTime(DateTime dateTime) {
    return '${dateTime.day}-${dateTime.month}-${dateTime.year} ${dateTime.hour}:${dateTime.minute}';
  }

  // Validate email
  static bool validateEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  // Validate NIK (16 digits)
  static bool validateNIK(String nik) {
    return RegExp(r'^[0-9]{16}$').hasMatch(nik);
  }

  // Validate phone number
  static bool validatePhone(String phone) {
    return RegExp(r'^[0-9]{10,13}$').hasMatch(phone);
  }

  // Get status color
  static Color getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  // Get status text
  static String getStatusText(String status) {
    switch (status) {
      case 'pending':
        return 'Menunggu Verifikasi';
      case 'approved':
        return 'Disetujui';
      case 'rejected':
        return 'Ditolak';
      default:
        return 'Tidak Diketahui';
    }
  }
}