// lib/screens/user/layanan_screen.dart - Updated with proper file handling
import 'package:flutter/material.dart';
import 'package:skt_desa/screens/user/chat_screen.dart';
import 'package:skt_desa/screens/user/service_selection_screen.dart';
import 'dart:io';
import '../../models/user_model.dart';
import '../../models/surat_model.dart';
import '../../providers/surat_provider.dart';
import '../../services/auth_service.dart';
import '../../services/database_service.dart';
import '../../services/storage_service.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';
import '../../widgets/form_surat_widget.dart';

class LayananScreen extends StatefulWidget {
  final String? selectedService;

  const LayananScreen({Key? key, this.selectedService}) : super(key: key);

  @override
  _LayananScreenState createState() => _LayananScreenState();
}

class _LayananScreenState extends State<LayananScreen> {
  UserModel? _currentUser;
  bool _isSubmitting = false;
  String? _selectedService;
  final suratProvider = SuratProvider();

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
    _selectedService = widget.selectedService;
  }

  Future<void> _getCurrentUser() async {
    try {
      UserModel? user = await AuthService().getUserData(
        AuthService().currentUser!.uid,
      );
      setState(() {
        _currentUser = user;
      });
    } catch (e) {
      Helpers.showSnackBar(context, 'Gagal memuat data pengguna: $e');
    }
  }

  // Fungsi ini akan dipanggil oleh FormSuratWidget
  Future<void> _handleFormSubmission(Map<String, dynamic> formData) async {
    setState(() => _isSubmitting = true);

    try {
      // 1. Validasi file dokumen
      List<File> dokumenFiles = formData['dokumenFiles'];
      if (dokumenFiles.isEmpty) {
        Helpers.showSnackBar(context, 'Harap pilih setidaknya satu dokumen');
        setState(() => _isSubmitting = false);
        return;
      }

      // 2. Upload dokumen dengan validasi file existence
      List<String> dokumenUrls = [];
      for (int i = 0; i < dokumenFiles.length; i++) {
        File file = dokumenFiles[i];
        
        // Validasi file ada sebelum upload
        if (!file.existsSync()) {
          Helpers.showSnackBar(context, 'File tidak ditemukan: ${file.path}');
          setState(() => _isSubmitting = false);
          return;
        }

        String? url = await _uploadFileSafely(file, i);
        if (url != null) {
          dokumenUrls.add(url);
        } else {
          // Jika gagal upload satu file, hentikan proses
          Helpers.showSnackBar(context, 'Gagal mengupload dokumen');
          setState(() => _isSubmitting = false);
          return;
        }
      }

      // 3. Buat model SuratModel
      SuratModel surat = SuratModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: _currentUser!.uid,
        jenisSurat: _selectedService ?? formData['jenisSurat'],
        dataPemohon: formData['dataPemohon'],
        keperluan: formData['keperluan'],
        dokumenUrls: dokumenUrls,
        metodePenerimaan: formData['metodePenerimaan'],
        tanggalPengajuan: DateTime.now(),
        // Tambahkan data tambahan jika ada
        dataTambahan: formData['dataTambahan'],
      );

      // 4. Simpan ke database
      bool success = await suratProvider.createSurat(surat);

      if (success) {
        Helpers.showSnackBar(
          context,
          'Pengajuan surat berhasil dikirim',
          color: Colors.green,
        );
        
        // Navigate to chat screen after successful submission
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatScreen(suratId: surat.id),
          ),
        );
      } else {
        Helpers.showSnackBar(
          context,
          'Gagal mengirim pengajuan surat',
        );
      }
    } catch (e) {
      Helpers.showSnackBar(
        context,
        'Gagal mengirim pengajuan surat: $e',
      );
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  /// Helper method to safely upload files with proper error handling
  Future<String?> _uploadFileSafely(File file, int index) async {
    try {
      String fileName = 'dokumen_${DateTime.now().millisecondsSinceEpoch}_$index';
      String? url = await StorageService().uploadFile(
        file,
        fileName,
        'dokumen_surat',
      );
      return url;
    } catch (e) {
      print('Error uploading file ${file.path}: $e');
      Helpers.showSnackBar(context, 'Gagal mengupload dokumen: $e');
      return null;
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
          : _selectedService != null
              ? SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  // Gunakan widget form di sini
                  child: FormSuratWidget(
                    userData: _currentUser,
                    selectedService: _selectedService!,
                    onSubmit: _handleFormSubmission,
                  ),
                )
              : const ServiceSelectionScreen(),
    );
  }
}