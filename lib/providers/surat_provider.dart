// lib/providers/surat_provider.dart - Added createSurat method
import 'package:flutter/material.dart';
import '../models/surat_model.dart';
import '../services/database_service.dart';

class SuratProvider with ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();
  List<SuratModel> _suratList = [];
  SuratModel? _selectedSurat;
  bool _isLoading = false;
  String? _error;
  int _unreadCount = 0;

  List<SuratModel> get suratList => _suratList;
  SuratModel? get selectedSurat => _selectedSurat;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get unreadCount => _unreadCount;

  Future<void> loadSurat() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      List<SuratModel> surat = await _databaseService.getAllSurat();
      _suratList = surat;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadSuratDetail(String suratId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      SuratModel? surat = _suratList.where((s) => s.id == suratId).firstOrNull;
      
      if (surat != null) {
        _selectedSurat = surat;
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateSuratStatus(String suratId, String status, String? catatan) async {
    try {
      bool success = await _databaseService.updateSuratStatus(
        suratId,
        status,
        catatan,
      );

      if (success) {
        await loadSurat();
        if (_selectedSurat?.id == suratId) {
          await loadSuratDetail(suratId);
        }
      }
      return success;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Tambahkan method createSurat
  Future<bool> createSurat(SuratModel surat) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      bool success = await _databaseService.createSurat(surat);
      
      if (success) {
        await loadSurat();
      }
      
      return success;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
    }
  }
}