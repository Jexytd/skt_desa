import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:skt_desa/models/user_model.dart';
import 'dart:io';
import '../utils/constants.dart';
import '../utils/helpers.dart';
import '../widgets/custom_button_widget.dart';

class FormSuratWidget extends StatefulWidget {
  // Callback untuk mengirim data form ke parent (LayananScreen)
  final Function(Map<String, dynamic>) onSubmit;

  const FormSuratWidget({
    Key? key,
    required this.onSubmit, UserModel? userData,
  }) : super(key: key);

  @override
  _FormSuratWidgetState createState() => _FormSuratWidgetState();
}

class _FormSuratWidgetState extends State<FormSuratWidget> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();

  // Controllers untuk Data Diri
  final _namaController = TextEditingController();
  final _nikController = TextEditingController();
  final _noKKController = TextEditingController();
  final _tempatLahirController = TextEditingController();
  final _tanggalLahirController = TextEditingController();
  final _pekerjaanController = TextEditingController();
  final _alamatKTPController = TextEditingController();
  final _alamatDomisiliController = TextEditingController();
  final _noTelpController = TextEditingController();
  final _keperluanController = TextEditingController();

  // Controllers untuk Form Tambahan
  final _namaBayiController = TextEditingController();
  final _tanggalLahirBayiController = TextEditingController();
  final _namaAlmarhumController = TextEditingController();
  final _tanggalMeninggalController = TextEditingController();
  final _namaUsahaController = TextEditingController();
  final _jenisUsahaController = TextEditingController();
  final _alamatUsahaController = TextEditingController();
  final _alasanSktmController = TextEditingController();

  // State variables
  String _jenisKelamin = 'Laki-laki';
  String _agama = 'Islam';
  String _statusPerkawinan = 'Belum Menikah';
  String _jenisSurat = AppStrings.jenisSuratList.first;
  String _metodePenerimaan = AppStrings.metodePenerimaanList.first;
  List<File> _dokumenFiles = [];
  List<String> _dokumenNames = [];
  bool _isDataBenar = false;
  bool _isLoading = false;

  @override
  void dispose() {
    // Dispose semua controllers
    _namaController.dispose();
    _nikController.dispose();
    _noKKController.dispose();
    _tempatLahirController.dispose();
    _tanggalLahirController.dispose();
    _pekerjaanController.dispose();
    _alamatKTPController.dispose();
    _alamatDomisiliController.dispose();
    _noTelpController.dispose();
    _keperluanController.dispose();
    _namaBayiController.dispose();
    _tanggalLahirBayiController.dispose();
    _namaAlmarhumController.dispose();
    _tanggalMeninggalController.dispose();
    _namaUsahaController.dispose();
    _jenisUsahaController.dispose();
    _alamatUsahaController.dispose();
    _alasanSktmController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        controller.text = Helpers.formatDate(picked);
      });
    }
  }

  Future<void> _pickDocument() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _dokumenFiles.add(File(image.path));
        _dokumenNames.add(image.name);
      });
    }
  }

  void _removeDocument(int index) {
    setState(() {
      _dokumenFiles.removeAt(index);
      _dokumenNames.removeAt(index);
    });
  }

  void _submitForm() {
    if (_formKey.currentState!.validate() && _isDataBenar) {
      setState(() => _isLoading = true);

      // Kumpulkan semua data dari form
      Map<String, dynamic> formData = {
        'dataPemohon': {
          'nama': _namaController.text,
          'nik': _nikController.text,
          'noKK': _noKKController.text,
          'tempatLahir': _tempatLahirController.text,
          'tanggalLahir': _tanggalLahirController.text,
          'jenisKelamin': _jenisKelamin,
          'pekerjaan': _pekerjaanController.text,
          'agama': _agama,
          'statusPerkawinan': _statusPerkawinan,
          'alamatKTP': _alamatKTPController.text,
          'alamatDomisili': _alamatDomisiliController.text.isEmpty
              ? _alamatKTPController.text
              : _alamatDomisiliController.text,
          'noTelp': _noTelpController.text,
        },
        'jenisSurat': _jenisSurat,
        'keperluan': _keperluanController.text,
        'dokumenFiles': _dokumenFiles, // Kirim file untuk di-upload di parent
        'metodePenerimaan': _metodePenerimaan,
        'dataTambahan': _getAdditionalData(), // Ambil data dari form tambahan
      };

      // Panggil callback onSubmit dari parent widget
      widget.onSubmit(formData);

      // Reset loading state (diasumsikan parent akan menangani navigasi/error)
      setState(() => _isLoading = false);

    } else if (!_isDataBenar) {
      Helpers.showSnackBar(context, 'Anda harus menyatakan bahwa data yang diisi adalah benar');
    }
  }

  // Fungsi untuk mengambil data dari form tambahan yang aktif
  Map<String, dynamic> _getAdditionalData() {
    switch (_jenisSurat) {
      case 'Surat Keterangan Kelahiran':
        return {
          'namaBayi': _namaBayiController.text,
          'tanggalLahirBayi': _tanggalLahirBayiController.text,
        };
      case 'Surat Keterangan Kematian':
        return {
          'namaAlmarhum': _namaAlmarhumController.text,
          'tanggalMeninggal': _tanggalMeninggalController.text,
        };
      case 'Surat Keterangan Usaha':
        return {
          'namaUsaha': _namaUsahaController.text,
          'jenisUsaha': _jenisUsahaController.text,
          'alamatUsaha': _alamatUsahaController.text,
        };
      case 'Surat Keterangan Tidak Mampu':
        return {
          'alasan': _alasanSktmController.text,
        };
      default:
        return {};
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDataDiriSection(),
          const SizedBox(height: 24),
          _buildJenisSuratSection(),
          const SizedBox(height: 24),
          _buildAdditionalFormSection(), // Form tambahan bersyarat
          const SizedBox(height: 24),
          _buildDokumenSection(),
          const SizedBox(height: 24),
          _buildMetodePenerimaanSection(),
          const SizedBox(height: 24),
          _buildPernyataanSection(),
          const SizedBox(height: 24),
          CustomButtonWidget(
            text: 'Kirim Pengajuan',
            onPressed: _submitForm,
            isLoading: _isLoading,
          ),
        ],
      ),
    );
  }

  // --- Builder Methods untuk setiap bagian form ---

  Widget _buildDataDiriSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Data Diri', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        TextFormField(
          controller: _namaController,
          decoration: const InputDecoration(labelText: AppStrings.namaLabel, border: OutlineInputBorder()),
          validator: (value) => value == null || value.isEmpty ? 'Nama tidak boleh kosong' : null,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _nikController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: AppStrings.nikLabel, border: OutlineInputBorder()),
          validator: (value) {
            if (value == null || value.isEmpty) return 'NIK tidak boleh kosong';
            if (!Helpers.validateNIK(value)) return 'NIK harus 16 digit angka';
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _noKKController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: AppStrings.noKKLabel, border: OutlineInputBorder()),
          validator: (value) => value == null || value.isEmpty ? 'Nomor KK tidak boleh kosong' : null,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: TextFormField(
              controller: _tempatLahirController,
              decoration: const InputDecoration(labelText: 'Tempat Lahir', border: OutlineInputBorder()),
              validator: (value) => value == null || value.isEmpty ? 'Tempat lahir tidak boleh kosong' : null,
            )),
            const SizedBox(width: 16),
            Expanded(child: TextFormField(
              controller: _tanggalLahirController,
              readOnly: true,
              decoration: InputDecoration(
                labelText: 'Tanggal Lahir',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(icon: const Icon(Icons.calendar_today), onPressed: () => _selectDate(context, _tanggalLahirController)),
              ),
              validator: (value) => value == null || value.isEmpty ? 'Tanggal lahir tidak boleh kosong' : null,
            )),
          ],
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          value: _jenisKelamin,
          decoration: const InputDecoration(labelText: AppStrings.jenisKelaminLabel, border: OutlineInputBorder()),
          items: const ['Laki-laki', 'Perempuan'].map((gender) => DropdownMenuItem(value: gender, child: Text(gender))).toList(),
          onChanged: (value) => setState(() => _jenisKelamin = value!),
        ),
        const SizedBox(height: 16),
        // ... Tambahkan field lainnya (Pekerjaan, Agama, Status, Alamat, No Telp) dengan pola yang sama
        // Untuk menghemat ruang, saya tidak menulis semuanya di sini, tapi polanya sudah jelas.
        TextFormField(controller: _pekerjaanController, decoration: const InputDecoration(labelText: AppStrings.pekerjaanLabel, border: OutlineInputBorder()), validator: (value) => value == null || value.isEmpty ? 'Pekerjaan tidak boleh kosong' : null),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(value: _agama, decoration: const InputDecoration(labelText: AppStrings.agamaLabel, border: OutlineInputBorder()), items: const ['Islam', 'Kristen', 'Katolik', 'Hindu', 'Buddha', 'Konghucu'].map((a) => DropdownMenuItem(value: a, child: Text(a))).toList(), onChanged: (value) => setState(() => _agama = value!)),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(value: _statusPerkawinan, decoration: const InputDecoration(labelText: AppStrings.statusPerkawinanLabel, border: OutlineInputBorder()), items: const ['Belum Menikah', 'Menikah', 'Janda/Duda'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(), onChanged: (value) => setState(() => _statusPerkawinan = value!)),
        const SizedBox(height: 16),
        TextFormField(controller: _alamatKTPController, maxLines: 3, decoration: const InputDecoration(labelText: AppStrings.alamatKTPLabel, border: OutlineInputBorder()), validator: (value) => value == null || value.isEmpty ? 'Alamat KTP tidak boleh kosong' : null),
        const SizedBox(height: 16),
        TextFormField(controller: _alamatDomisiliController, maxLines: 3, decoration: const InputDecoration(labelText: AppStrings.alamatDomisiliLabel, border: OutlineInputBorder())),
        const SizedBox(height: 16),
        TextFormField(controller: _noTelpController, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: AppStrings.noTelpLabel, border: OutlineInputBorder()), validator: (value) {
          if (value == null || value.isEmpty) return 'Nomor telepon tidak boleh kosong';
          if (!Helpers.validatePhone(value)) return 'Format nomor telepon tidak valid';
          return null;
        }),
      ],
    );
  }

  Widget _buildJenisSuratSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Detail Surat', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          value: _jenisSurat,
          decoration: const InputDecoration(labelText: 'Pilih Jenis Surat', border: OutlineInputBorder()),
          items: AppStrings.jenisSuratList.map((jenis) => DropdownMenuItem(value: jenis, child: Text(jenis))).toList(),
          onChanged: (value) => setState(() => _jenisSurat = value!),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _keperluanController,
          maxLines: 3,
          decoration: const InputDecoration(labelText: AppStrings.keperluanLabel, border: OutlineInputBorder()),
          validator: (value) => value == null || value.isEmpty ? 'Keperluan tidak boleh kosong' : null,
        ),
      ],
    );
  }

  Widget _buildAdditionalFormSection() {
    // Menampilkan form tambahan berdasarkan pilihan jenis surat
    switch (_jenisSurat) {
      case 'Surat Keterangan Kelahiran':
        return _buildKelahiranForm();
      case 'Surat Keterangan Kematian':
        return _buildKematianForm();
      case 'Surat Keterangan Usaha':
        return _buildUsahaForm();
      case 'Surat Keterangan Tidak Mampu':
        return _buildSktmForm();
      default:
        return const SizedBox.shrink(); // Tidak menampilkan apa-apa
    }
  }

  Widget _buildKelahiranForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Data Bayi', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        TextFormField(
          controller: _namaBayiController,
          decoration: const InputDecoration(labelText: 'Nama Lengkap Bayi', border: OutlineInputBorder()),
          validator: (value) => _jenisSurat == 'Surat Keterangan Kelahiran' && (value == null || value.isEmpty) ? 'Nama bayi tidak boleh kosong' : null,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _tanggalLahirBayiController,
          readOnly: true,
          decoration: InputDecoration(
            labelText: 'Tanggal Lahir Bayi',
            border: const OutlineInputBorder(),
            suffixIcon: IconButton(icon: const Icon(Icons.calendar_today), onPressed: () => _selectDate(context, _tanggalLahirBayiController)),
          ),
          validator: (value) => _jenisSurat == 'Surat Keterangan Kelahiran' && (value == null || value.isEmpty) ? 'Tanggal lahir bayi tidak boleh kosong' : null,
        ),
      ],
    );
  }

  Widget _buildKematianForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Data Almarhum', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        TextFormField(
          controller: _namaAlmarhumController,
          decoration: const InputDecoration(labelText: 'Nama Lengkap Almarhum', border: OutlineInputBorder()),
          validator: (value) => _jenisSurat == 'Surat Keterangan Kematian' && (value == null || value.isEmpty) ? 'Nama almarhum tidak boleh kosong' : null,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _tanggalMeninggalController,
          readOnly: true,
          decoration: InputDecoration(
            labelText: 'Tanggal Meninggal',
            border: const OutlineInputBorder(),
            suffixIcon: IconButton(icon: const Icon(Icons.calendar_today), onPressed: () => _selectDate(context, _tanggalMeninggalController)),
          ),
          validator: (value) => _jenisSurat == 'Surat Keterangan Kematian' && (value == null || value.isEmpty) ? 'Tanggal meninggal tidak boleh kosong' : null,
        ),
      ],
    );
  }

  Widget _buildUsahaForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Data Usaha', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        TextFormField(
          controller: _namaUsahaController,
          decoration: const InputDecoration(labelText: 'Nama Usaha', border: OutlineInputBorder()),
          validator: (value) => _jenisSurat == 'Surat Keterangan Usaha' && (value == null || value.isEmpty) ? 'Nama usaha tidak boleh kosong' : null,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _jenisUsahaController,
          decoration: const InputDecoration(labelText: 'Jenis Usaha', border: OutlineInputBorder()),
          validator: (value) => _jenisSurat == 'Surat Keterangan Usaha' && (value == null || value.isEmpty) ? 'Jenis usaha tidak boleh kosong' : null,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _alamatUsahaController,
          maxLines: 3,
          decoration: const InputDecoration(labelText: 'Alamat Usaha', border: OutlineInputBorder()),
          validator: (value) => _jenisSurat == 'Surat Keterangan Usaha' && (value == null || value.isEmpty) ? 'Alamat usaha tidak boleh kosong' : null,
        ),
      ],
    );
  }

  Widget _buildSktmForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Alasan Permohonan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        TextFormField(
          controller: _alasanSktmController,
          maxLines: 4,
          decoration: const InputDecoration(labelText: 'Jelaskan alasan permohonan SKTM', border: OutlineInputBorder()),
          validator: (value) => _jenisSurat == 'Surat Keterangan Tidak Mampu' && (value == null || value.isEmpty) ? 'Alasan tidak boleh kosong' : null,
        ),
      ],
    );
  }

  Widget _buildDokumenSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Dokumen Pendukung', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        const Text('Upload dokumen pendukung (KTP, KK, dll)', style: TextStyle(fontSize: 14)),
        const SizedBox(height: 8),
        ElevatedButton.icon(
          onPressed: _pickDocument,
          icon: const Icon(Icons.upload_file),
          label: const Text('Pilih Dokumen'),
        ),
        const SizedBox(height: 16),
        if (_dokumenNames.isNotEmpty)
          Column(
            children: _dokumenNames.asMap().entries.map((entry) {
              int index = entry.key;
              String name = entry.value;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.green),
                    const SizedBox(width: 8),
                    Expanded(child: Text(name, overflow: TextOverflow.ellipsis)),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _removeDocument(index),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
      ],
    );
  }

  Widget _buildMetodePenerimaanSection() {
    return DropdownButtonFormField<String>(
      value: _metodePenerimaan,
      decoration: const InputDecoration(labelText: AppStrings.metodePenerimaanLabel, border: OutlineInputBorder()),
      items: AppStrings.metodePenerimaanList.map((metode) => DropdownMenuItem(value: metode, child: Text(metode))).toList(),
      onChanged: (value) => setState(() => _metodePenerimaan = value!),
    );
  }

  Widget _buildPernyataanSection() {
    return CheckboxListTile(
      title: const Text('Saya menyatakan bahwa data yang saya isi adalah benar dan dapat dipertanggungjawabkan', style: TextStyle(fontSize: 14)),
      value: _isDataBenar,
      onChanged: (value) => setState(() => _isDataBenar = value!),
      controlAffinity: ListTileControlAffinity.leading,
      contentPadding: EdgeInsets.zero,
    );
  }
}