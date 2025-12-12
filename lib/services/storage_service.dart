// lib/services/storage_service.dart - Improved file upload with better error handling
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String?> uploadFile(File file, String fileName, String folder) async {
    try {
      // Validasi file sebelum upload
      if (!file.existsSync()) {
        throw Exception('File tidak ditemukan: ${file.path}');
      }

      Reference ref = _storage.ref().child('$folder/$fileName');
      UploadTask uploadTask = ref.putFile(file);
      
      // Monitor upload progress
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        print('Upload progress: ${snapshot.bytesTransferred}/${snapshot.totalBytes}');
      });

      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Error uploading file ${file.path}: $e');
      // Re-throw the error so it can be caught by the caller
      throw Exception('Gagal mengupload file: $e');
    }
  }

  Future<String?> uploadMultipleFiles(List<File> files, List<String> fileNames, String folder) async {
    try {
      List<String> downloadUrls = [];
      
      for (int i = 0; i < files.length; i++) {
        File file = files[i];
        String fileName = fileNames[i];
        
        // Validasi file sebelum upload
        if (!file.existsSync()) {
          throw Exception('File tidak ditemukan: ${file.path}');
        }

        String? url = await uploadFile(file, fileName, folder);
        if (url != null) {
          downloadUrls.add(url);
        } else {
          throw Exception('Gagal mengupload file ${file.path}');
        }
      }
      
      // Return a JSON string of URLs
      return downloadUrls.join(',');
    } catch (e) {
      print('Error uploading multiple files: $e');
      throw Exception('Gagal mengupload beberapa file: $e');
    }
  }
}