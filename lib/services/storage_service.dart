import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String?> uploadFile(File file, String fileName, String folder) async {
    try {
      Reference ref = _storage.ref().child('$folder/$fileName');
      UploadTask uploadTask = ref.putFile(file);
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  Future<String?> uploadMultipleFiles(List<File> files, List<String> fileNames, String folder) async {
    try {
      List<String> downloadUrls = [];
      
      for (int i = 0; i < files.length; i++) {
        String? url = await uploadFile(files[i], fileNames[i], folder);
        if (url != null) {
          downloadUrls.add(url);
        }
      }
      
      // Return a JSON string of URLs
      return downloadUrls.join(',');
    } catch (e) {
      print(e.toString());
      return null;
    }
  }
}