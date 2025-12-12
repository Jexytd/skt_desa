import 'package:flutter/material.dart';
import 'dart:io';
import '../../models/user_model.dart';
import '../../models/surat_model.dart';
import '../../services/auth_service.dart';
import '../../services/database_service.dart';
import '../../services/storage_service.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';
import '../../widgets/form_surat_widget.dart';

class LayananScreen extends StatefulWidget {
  const LayananScreen({Key? key}) : super(key: key);

  @override
  _LayananScreenState createState() => _LayananScreenState();
}

class _LayananScreenState extends State<LayananScreen> {
  UserModel? _currentUser;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
  }

  Future<void> _getCurrentUser() async {
    UserModel? user = await AuthService().getUserData(
      AuthService().currentUser!.uid,
    );
    setState(() {
      _currentUser = user;
    });
  }

  // Fungsi ini akan dipanggil oleh FormSuratWidget
  Future<void> _handleFormSubmission(Map<String, dynamic> formData) async {
    setState(() => _isSubmitting = true);

    // 1. Upload dokumen
    List<String> dokumenUrls = [];
    List<File> dokumenFiles = formData['dokumenFiles'];
    for (int i = 0; i < dokumenFiles.length; i++) {
      String? url = await StorageService().uploadFile(
        dokumenFiles[i],
        'dokumen_${DateTime.now().millisecondsSinceEpoch}_$i',
        'dokumen_surat',
      );
      if (url != null) {
        dokumenUrls.add(url);
      }
    }

    // 2. Buat model SuratModel
    SuratModel surat = SuratModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: _currentUser!.uid,
      jenisSurat: formData['jenisSurat'],
      dataPemohon: formData['dataPemohon'],
      keperluan: formData['keperluan'],
      dokumenUrls: dokumenUrls,
      metodePenerimaan: formData['metodePenerimaan'],
      tanggalPengajuan: DateTime.now(),
      // Tambahkan data tambahan jika ada
      dataTambahan: formData['dataTambahan'],
    );

    // 3. Simpan ke database
    bool success = await DatabaseService().createSurat(surat);

    setState(() => _isSubmitting = false);

    if (success) {
      Helpers.showSnackBar(
        context,
        'Pengajuan surat berhasil dikirim',
        color: Colors.green,
      );
      Navigator.pop(context); // Kembali ke halaman sebelumnya
    } else {
      Helpers.showSnackBar(
        context,
        'Gagal mengirim pengajuan surat',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengajuan Surat'),
        backgroundColor: AppColors.primaryColor,
      ),
      body: _isSubmitting
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              // Gunakan widget form di sini
              child: FormSuratWidget(
                userData: _currentUser,
                onSubmit: _handleFormSubmission,
              ),
            ),
    );
  }
}