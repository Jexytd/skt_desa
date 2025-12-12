// lib/widgets/form_surat_widget.dart - Full implementation with file picker
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart'; // Import file_picker
import 'package:skt_desa/models/user_model.dart';
import 'package:skt_desa/utils/helpers.dart';
import '../../utils/constants.dart';

class FormSuratWidget extends StatefulWidget {
  final UserModel? userData;
  final String? selectedService;
  final Function(Map<String, dynamic>) onSubmit;

  const FormSuratWidget({
    Key? key,
    this.userData,
    this.selectedService,
    required this.onSubmit,
  }) : super(key: key);

  @override
  _FormSuratWidgetState createState() => _FormSuratWidgetState();
}

class _FormSuratWidgetState extends State<FormSuratWidget> {
  final _formKey = GlobalKey<FormState>();
  final _keperluanController = TextEditingController();
  final _metodePenerimaanController = TextEditingController();
  
  String? _selectedJenisSurat;
  String? _selectedMetodePenerimaan;
  List<File> _dokumenFiles = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedJenisSurat = widget.selectedService;
    _selectedMetodePenerimaan = AppStrings.metodePenerimaanList.first;
  }

  @override
  void dispose() {
    _keperluanController.dispose();
    _metodePenerimaanController.dispose();
    super.dispose();
  }

  Future<void> _pickDocuments() async {
    try {
      // Show file picker dialog
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'jpeg', 'png'],
        allowMultiple: true,
      );

      if (result != null) {
        // Convert picked files to File objects
        List<File> files = result.files.map((pickedFile) {
          return File(pickedFile.path!);
        }).toList();
        
        setState(() {
          _dokumenFiles = files;
        });
      } else {
        // User canceled the picker
        print('User canceled file picking');
      }
    } catch (e) {
      print('Error picking files: $e');
      Helpers.showSnackBar(context, 'Gagal memilih file: $e');
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final formData = {
        'jenisSurat': _selectedJenisSurat,
        'keperluan': _keperluanController.text,
        'metodePenerimaan': _selectedMetodePenerimaan,
        'dokumenFiles': _dokumenFiles,
        'dataPemohon': widget.userData?.toMap() ?? {},
        'dataTambahan': {}, // Add any additional data
      };
      
      widget.onSubmit(formData);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Jenis Surat Section
            const Text(
              'Jenis Surat',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedJenisSurat,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.grey,
              ),
              items: AppStrings.jenisSuratList.map((service) {
                return DropdownMenuItem(
                  value: service,
                  child: Text(service),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedJenisSurat = value;
                });
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Jenis surat harus dipilih';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            // Keperluan Section
            const Text(
              'Keperluan Penggunaan Surat',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _keperluanController,
              maxLines: 3,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.grey,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Keperluan tidak boleh kosong';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            // Metode Penerimaan Section
            const Text(
              'Metode Penerimaan Surat',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedMetodePenerimaan,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.grey,
              ),
              items: AppStrings.metodePenerimaanList.map((method) {
                return DropdownMenuItem(
                  value: method,
                  child: Text(method),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedMetodePenerimaan = value;
                });
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Metode penerimaan harus dipilih';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            // Dokumen Pendukung Section
            const Text(
              'Dokumen Pendukung',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            _dokumenFiles.isEmpty
                ? ElevatedButton.icon(
                    onPressed: _pickDocuments,
                    icon: const Icon(Icons.upload_file),
                    label: const Text('Pilih Dokumen'),
                  )
                : Column(
                    children: _dokumenFiles.map((file) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: InkWell(
                          onTap: () {
                            // Open document in browser or viewer
                          },
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.file_present),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    file.path.split('/').last,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () {
                                    setState(() {
                                      _dokumenFiles.remove(file);
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
            const SizedBox(height: 24),
            
            // Submit Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Kirim Pengajuan',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}