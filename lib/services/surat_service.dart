// lib/services/surat_service.dart - Refactored Surat Service
import 'package:flutter/material.dart';
import '../models/surat_model.dart';
import '../services/base_service.dart';
import '../services/database_service.dart';

class SuratService extends ServiceImplementation {
  final DatabaseService _databaseService = DatabaseService();

  Future<bool> createSurat(SuratModel surat) async {
    return await _databaseService.createSurat(surat);
  }

  Future<List<SuratModel>> getSuratByUserId(String userId) async {
    return await _databaseService.getSuratByUserId(userId);
  }

  Future<List<SuratModel>> getAllSurat() async {
    return await _databaseService.getAllSurat();
  }

  Future<bool> updateSuratStatus(String suratId, String status, String? catatan) async {
    return await _databaseService.updateSuratStatus(suratId, status, catatan);
  }
}