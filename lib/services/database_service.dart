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
      print('Error creating surat: $e');
      if (e is FirebaseException) {
        throw 'Gagal membuat surat: ${e.message}';
      }
      throw 'Terjadi kesalahan sistem saat membuat surat';
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
      print('Error getting surat by user: $e');
      if (e is FirebaseException) {
        throw 'Gagal memuat data surat: ${e.message}';
      }
      throw 'Terjadi kesalahan sistem saat memuat data surat';
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
      print('Error getting all surat: $e');
      if (e is FirebaseException) {
        throw 'Gagal memuat data surat: ${e.message}';
      }
      throw 'Terjadi kesalahan sistem saat memuat data surat';
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
      print('Error updating surat status: $e');
      if (e is FirebaseException) {
        throw 'Gagal memperbarui status surat: ${e.message}';
      }
      throw 'Terjadi kesalahan sistem saat memperbarui status surat';
    }
  }

  // Berita operations
  Future<bool> createBerita(BeritaModel berita) async {
    try {
      await _firestore.collection('berita').doc(berita.id).set(berita.toMap());
      return true;
    } catch (e) {
      print('Error creating berita: $e');
      if (e is FirebaseException) {
        throw 'Gagal membuat berita: ${e.message}';
      }
      throw 'Terjadi kesalahan sistem saat membuat berita';
    }
  }

  Future<bool> updateBerita(BeritaModel berita) async {
    try {
      await _firestore.collection('berita').doc(berita.id).update(berita.toMap());
      return true;
    } catch (e) {
      print('Error updating berita: $e');
      if (e is FirebaseException) {
        throw 'Gagal memperbarui berita: ${e.message}';
      }
      throw 'Terjadi kesalahan sistem saat memperbarui berita';
    }
  }

  Future<bool> deleteBerita(String beritaId) async {
    try {
      await _firestore.collection('berita').doc(beritaId).delete();
      return true;
    } catch (e) {
      print('Error deleting berita: $e');
      if (e is FirebaseException) {
        throw 'Gagal menghapus berita: ${e.message}';
      }
      throw 'Terjadi kesalahan sistem saat menghapus berita';
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
      print('Error getting all berita: $e');
      if (e is FirebaseException) {
        throw 'Gagal memuat data berita: ${e.message}';
      }
      throw 'Terjadi kesalahan sistem saat memuat data berita';
    }
  }
}