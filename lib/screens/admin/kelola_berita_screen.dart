// lib/screens/admin/kelola_berita_screen.dart
import 'package:flutter/material.dart';
import 'package:skt_desa/widgets/custom_button_widget.dart';
import 'package:skt_desa/widgets/error_message.dart';
import '../../providers/berita_provider.dart';
import '../../models/berita_model.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';
import '../../widgets/berita_card.dart';

class KelolaBeritaScreen extends StatefulWidget {
  final String? initialBeritaId;

  const KelolaBeritaScreen({Key? key, this.initialBeritaId}) : super(key: key);

  @override
  _KelolaBeritaScreenState createState() => _KelolaBeritaScreenState();
}

class _KelolaBeritaScreenState extends State<KelolaBeritaScreen> {
  final BeritaProvider beritaProvider = BeritaProvider();

  bool _isSaving = false;
  BeritaModel? _editingBerita;

  final TextEditingController _judulController = TextEditingController();
  final TextEditingController _penulisController = TextEditingController();
  final TextEditingController _isiController = TextEditingController();
  String? _imageUrl;

  @override
  void initState() {
    super.initState();
    beritaProvider.loadBerita();
    if (widget.initialBeritaId != null) {
      _loadBeritaDetail(widget.initialBeritaId!);
    }
  }

  Future<void> _loadBeritaDetail(String beritaId) async {
    try {
      final berita = beritaProvider.beritaList.firstWhere(
        (b) => b.id == beritaId,
        orElse: () => throw Exception('Berita tidak ditemukan'),
      );

      setState(() {
        _editingBerita = berita;
        _judulController.text = berita.judul;
        _penulisController.text = berita.author;
        _isiController.text = berita.isi;
        _imageUrl = berita.imageUrl;
      });
    } catch (e) {
      Helpers.showSnackBar(context, 'Gagal memuat detail berita: $e');
    }
  }

  Future<void> _pickImage() async {
    // TODO: Implement image picker
    // Example: _imageUrl = pickedImageUrl;
  }

  Future<bool> _showConfirmDialog(String title, String message) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(title),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Batal'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Ya'),
              ),
            ],
          ),
        ) ??
        false;
  }

  Future<void> _saveBerita() async {
    if (_judulController.text.isEmpty ||
        _penulisController.text.isEmpty ||
        _isiController.text.isEmpty) {
      Helpers.showSnackBar(context, 'Semua field harus diisi');
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      if (_editingBerita != null) {
        // Edit berita
        final confirm =
            await _showConfirmDialog('Edit Berita', 'Perbarui berita ini?');
        if (!confirm) return;

        final updatedBerita = _editingBerita!.copyWith(
          judul: _judulController.text,
          author: _penulisController.text,
          isi: _isiController.text,
          imageUrl: _imageUrl ?? _editingBerita!.imageUrl,
        );

        await beritaProvider.updateBerita(updatedBerita);
        Helpers.showSnackBar(context, 'Berita berhasil diperbarui',
            color: Colors.green);
      } else {
        // Tambah berita baru
        final confirm =
            await _showConfirmDialog('Tambah Berita', 'Tambahkan berita ini?');
        if (!confirm) return;

        final berita = BeritaModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          judul: _judulController.text,
          author: _penulisController.text,
          isi: _isiController.text,
          imageUrl: _imageUrl ?? 'https://picsum.photos/300/200',
          tanggal: DateTime.now(),
        );

        await beritaProvider.createBerita(berita);
        Helpers.showSnackBar(context, 'Berita berhasil ditambahkan',
            color: Colors.green);

        // Reset form
        _judulController.clear();
        _penulisController.clear();
        _isiController.clear();
        _imageUrl = null;
      }

      beritaProvider.loadBerita();
    } catch (e) {
      Helpers.showSnackBar(context, 'Terjadi kesalahan: $e');
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  Future<void> _deleteBerita(String beritaId) async {
    final confirm =
        await _showConfirmDialog('Hapus Berita', 'Hapus berita ini?');
    if (!confirm) return;

    try {
      await beritaProvider.deleteBerita(beritaId);
      Helpers.showSnackBar(context, 'Berita berhasil dihapus', color: Colors.green);
      beritaProvider.loadBerita();
    } catch (e) {
      Helpers.showSnackBar(context, 'Gagal menghapus berita: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_editingBerita != null ? 'Edit Berita' : 'Tambah Berita'),
        backgroundColor: AppColors.primaryColor,
      ),
      body: beritaProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : beritaProvider.error != null
              ? ErrorMessage(
                  message: beritaProvider.error!,
                  onRetry: () => beritaProvider.loadBerita(),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Form
                      _buildBeritaForm(),
                      const SizedBox(height: 24),
                      // Daftar Berita
                      const Text(
                        'Daftar Berita',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      beritaProvider.beritaList.isEmpty
                          ? _buildEmptyState()
                          : ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: beritaProvider.beritaList.length,
                              itemBuilder: (context, index) {
                                final berita =
                                    beritaProvider.beritaList[index];
                                return BeritaCard(
                                  berita: berita,
                                  onTap: () {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            KelolaBeritaScreen(
                                                initialBeritaId: berita.id),
                                      ),
                                    );
                                  },
                                  // onDelete: () => _deleteBerita(berita.id),
                                );
                              },
                            ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildBeritaForm() {
    return Column(
      children: [
        TextFormField(
          controller: _judulController,
          decoration: const InputDecoration(
            labelText: 'Judul Berita',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _penulisController,
          decoration: const InputDecoration(
            labelText: 'Penulis',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _isiController,
          maxLines: 10,
          decoration: const InputDecoration(
            labelText: 'Isi Berita',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        // Image Section
        const Text(
          'Gambar Berita',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Container(
          height: 200,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(8),
          ),
          child: _imageUrl != null
              ? Image.network(_imageUrl!, fit: BoxFit.cover)
              : const Center(child: Text('Belum ada gambar')),
        ),
        const SizedBox(height: 8),
        ElevatedButton.icon(
          onPressed: _pickImage,
          icon: const Icon(Icons.image),
          label: const Text('Pilih Gambar'),
        ),
        const SizedBox(height: 24),
        CustomButtonWidget(
          text: _editingBerita != null ? 'Perbarui' : 'Simpan',
          onPressed: _saveBerita,
          isLoading: _isSaving,
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        children: [
          Icon(Icons.article_outlined, size: 64, color: AppColors.textSecondary),
          const SizedBox(height: 16),
          Text(
            'Tidak ada berita',
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary),
          ),
          const SizedBox(height: 8),
          Text(
            'Belum ada berita yang dibuat',
            style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
