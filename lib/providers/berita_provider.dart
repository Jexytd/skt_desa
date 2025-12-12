// lib/providers/berita_provider.dart - New Provider
import 'package:flutter/material.dart';
import '../models/berita_model.dart';
import '../services/database_service.dart';

class BeritaProvider with ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();
  List<BeritaModel> _beritaList = [];
  bool _isLoading = false;
  String? _error;

  List<BeritaModel> get beritaList => _beritaList;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadBerita() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      List<BeritaModel> berita = await _databaseService.getAllBerita();
      _beritaList = berita;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createBerita(BeritaModel berita) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      bool success = await _databaseService.createBerita(berita);
      if (success) {
        await loadBerita();
      } else {
        _error = 'Gagal membuat berita';
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateBerita(BeritaModel berita) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      bool success = await _databaseService.updateBerita(berita);
      if (success) {
        await loadBerita();
      } else {
        _error = 'Gagal memperbarui berita';
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteBerita(String beritaId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      bool success = await _databaseService.deleteBerita(beritaId);
      if (success) {
        await loadBerita();
      } else {
        _error = 'Gagal menghapus berita';
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}