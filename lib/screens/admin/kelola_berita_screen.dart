import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../models/berita_model.dart';
import '../../services/database_service.dart';
import '../../services/storage_service.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';
import '../../widgets/custom_button_widget.dart';

class KelolaBeritaScreen extends StatefulWidget {
  final String? initialBeritaId;
  
  const KelolaBeritaScreen({Key? key, this.initialBeritaId}) : super(key: key);

  @override
  _KelolaBeritaScreenState createState() => _KelolaBeritaScreenState();
}

class _KelolaBeritaScreenState extends State<KelolaBeritaScreen> {
  final _formKey = GlobalKey<FormState>();
  final _judulController = TextEditingController();
  final _isiController = TextEditingController();
  final _authorController = TextEditingController();
  
  File? _imageFile;
  String? _imageUrl;
  bool _isLoading = true;
  bool _isSaving = false;
  List<BeritaModel> _beritaList = [];

  @override
  void initState() {
    super.initState();
    _getBerita();
    if (widget.initialBeritaId != null) {
      _getBeritaDetail(widget.initialBeritaId!);
    }
  }

  Future<void> _getBerita() async {
    List<BeritaModel> berita = await DatabaseService().getAllBerita();
    setState(() {
      _beritaList = berita;
      _isLoading = false;
    });
  }

  Future<void> _getBeritaDetail(String beritaId) async {
    // Find the berita in the list
    BeritaModel? berita = _beritaList.where((b) => b.id == beritaId).firstOrNull;
    
    if (berita != null) {
      setState(() {
        _judulController.text = berita.judul;
        _isiController.text = berita.isi;
        _authorController.text = berita.author;
        _imageUrl = berita.imageUrl;
      });
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    
    if (image != null) {
      setState(() {
        _imageFile = File(image.path);
      });
    }
  }

  Future<void> _saveBerita() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSaving = true;
      });

      String? imageUrl = _imageUrl;
      
      // Upload image if a new one is selected
      if (_imageFile != null) {
        imageUrl = await StorageService().uploadFile(
          _imageFile!,
          'berita_${DateTime.now().millisecondsSinceEpoch}',
          'berita',
        );
      }

      if (imageUrl == null && _imageUrl == null) {
        Helpers.showSnackBar(
          context,
          'Gambar berita wajib diupload',
        );
        setState(() {
          _isSaving = false;
        });
        return;
      }

      BeritaModel berita;
      
      if (widget.initialBeritaId != null) {
        // Update existing berita
        berita = BeritaModel(
          id: widget.initialBeritaId!,
          judul: _judulController.text,
          isi: _isiController.text,
          imageUrl: imageUrl!,
          tanggal: DateTime.now(),
          author: _authorController.text,
        );
        
        bool success = await DatabaseService().updateBerita(berita);
        
        if (success) {
          Helpers.showSnackBar(
            context,
            'Berita berhasil diperbarui',
            color: Colors.green,
          );
          Navigator.pop(context);
        } else {
          Helpers.showSnackBar(
            context,
            'Gagal memperbarui berita',
          );
        }
      } else {
        // Create new berita
        berita = BeritaModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          judul: _judulController.text,
          isi: _isiController.text,
          imageUrl: imageUrl!,
          tanggal: DateTime.now(),
          author: _authorController.text,
        );
        
        bool success = await DatabaseService().createBerita(berita);
        
        if (success) {
          Helpers.showSnackBar(
            context,
            'Berita berhasil ditambahkan',
            color: Colors.green,
          );
          _clearForm();
        } else {
          Helpers.showSnackBar(
            context,
            'Gagal menambahkan berita',
          );
        }
      }

      setState(() {
        _isSaving = false;
      });
      
      // Refresh the berita list
      _getBerita();
    }
  }

  void _clearForm() {
    _formKey.currentState?.reset();
    setState(() {
      _imageFile = null;
      _imageUrl = null;
    });
  }

  Future<void> _deleteBerita(String beritaId) async {
    bool confirm = await _showConfirmDialog('Hapus Berita', 'Apakah Anda yakin ingin menghapus berita ini?');
    
    if (confirm) {
      bool success = await DatabaseService().deleteBerita(beritaId);
      
      if (success) {
        Helpers.showSnackBar(
          context,
          'Berita berhasil dihapus',
          color: Colors.green,
        );
        _getBerita();
      } else {
        Helpers.showSnackBar(
          context,
          'Gagal menghapus berita',
        );
      }
    }
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
            child: const Text('Hapus'),
          ),
        ],
      ),
    ) ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.initialBeritaId != null ? 'Edit Berita' : 'Tambah Berita'),
        backgroundColor: AppColors.primaryColor,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Form Section
                    TextFormField(
                      controller: _judulController,
                      decoration: const InputDecoration(
                        labelText: 'Judul Berita',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Judul berita tidak boleh kosong';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _authorController,
                      decoration: const InputDecoration(
                        labelText: 'Penulis',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Penulis tidak boleh kosong';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _isiController,
                      maxLines: 10,
                      decoration: const InputDecoration(
                        labelText: 'Isi Berita',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Isi berita tidak boleh kosong';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Image Section
                    const Text(
                      'Gambar Berita',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _imageFile != null
                        ? Container(
                            height: 200,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              image: DecorationImage(
                                image: FileImage(_imageFile!),
                                fit: BoxFit.cover,
                              ),
                            ),
                          )
                        : _imageUrl != null
                            ? Container(
                                height: 200,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  image: DecorationImage(
                                    image: NetworkImage(_imageUrl!),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              )
                            : Container(
                                height: 200,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Center(
                                  child: Text('Belum ada gambar'),
                                ),
                              ),
                    const SizedBox(height: 8),
                    ElevatedButton.icon(
                      onPressed: _pickImage,
                      icon: const Icon(Icons.image),
                      label: const Text('Pilih Gambar'),
                    ),
                    const SizedBox(height: 24),
                    
                    // Submit Button
                    CustomButtonWidget(
                      text: widget.initialBeritaId != null ? 'Perbarui' : 'Simpan',
                      onPressed: _saveBerita,
                      isLoading: _isSaving,
                    ),
                    const SizedBox(height: 24),
                    
                    // Berita List Section
                    const Text(
                      'Daftar Berita',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _beritaList.isEmpty
                        ? Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.cardColor,
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.2),
                                  spreadRadius: 1,
                                  blurRadius: 3,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                'Belum ada berita',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _beritaList.length,
                            itemBuilder: (context, index) {
                              final berita = _beritaList[index];
                              return Card(
                                margin: const EdgeInsets.only(bottom: 16),
                                elevation: 4,
                                child: ListTile(
                                  contentPadding: const EdgeInsets.all(16),
                                  leading: Container(
                                    width: 60,
                                    height: 60,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      image: DecorationImage(
                                        image: NetworkImage(berita.imageUrl),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  title: Text(
                                    berita.judul,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        berita.isi,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${Helpers.formatDate(berita.tanggal)} - ${berita.author}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.edit, color: Colors.blue),
                                        onPressed: () {
                                          Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => KelolaBeritaScreen(
                                                initialBeritaId: berita.id,
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete, color: Colors.red),
                                        onPressed: () => _deleteBerita(berita.id),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ],
                ),
              ),
            ),
    );
  }
}