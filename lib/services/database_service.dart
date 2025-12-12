import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/surat_model.dart';
import '../models/berita_model.dart';

class DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Surat operations
  Future<bool> createSurat(SuratModel surat) async {
    try {
      await _firestore.collection('surat').doc(surat.id).set(surat.toMap());
      return true;
    } catch (e) {
      print(e.toString());
      return false;
    }
  }

  Future<List<SuratModel>> getSuratByUserId(String userId) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('surat')
          .where('userId', isEqualTo: userId)
          .orderBy('tanggalPengajuan', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => SuratModel.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print(e.toString());
      return [];
    }
  }

  Future<List<SuratModel>> getAllSurat() async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('surat')
          .orderBy('tanggalPengajuan', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => SuratModel.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print(e.toString());
      return [];
    }
  }

  Future<bool> updateSuratStatus(String suratId, String status, String? catatan) async {
    try {
      Map<String, dynamic> updateData = {
        'status': status,
        'tanggalSelesai': DateTime.now().toIso8601String(),
      };
      
      if (catatan != null) {
        updateData['catatanAdmin'] = catatan;
      }

      await _firestore.collection('surat').doc(suratId).update(updateData);
      return true;
    } catch (e) {
      print(e.toString());
      return false;
    }
  }

  // Berita operations
  Future<bool> createBerita(BeritaModel berita) async {
    try {
      await _firestore.collection('berita').doc(berita.id).set(berita.toMap());
      return true;
    } catch (e) {
      print(e.toString());
      return false;
    }
  }

  Future<bool> updateBerita(BeritaModel berita) async {
    try {
      await _firestore.collection('berita').doc(berita.id).update(berita.toMap());
      return true;
    } catch (e) {
      print(e.toString());
      return false;
    }
  }

  Future<bool> deleteBerita(String beritaId) async {
    try {
      await _firestore.collection('berita').doc(beritaId).delete();
      return true;
    } catch (e) {
      print(e.toString());
      return false;
    }
  }

  Future<List<BeritaModel>> getAllBerita() async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('berita')
          .orderBy('tanggal', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => BeritaModel.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print(e.toString());
      return [];
    }
  }
}