import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import '../../models/surat_model.dart';
import '../../services/auth_service.dart';
import '../../services/database_service.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';
import '../../widgets/custom_button_widget.dart';

class KelolaSuratScreen extends StatefulWidget {
  final String? initialSuratId;
  
  const KelolaSuratScreen({Key? key, this.initialSuratId}) : super(key: key);

  @override
  _KelolaSuratScreenState createState() => _KelolaSuratScreenState();
}

class _KelolaSuratScreenState extends State<KelolaSuratScreen> {
  List<SuratModel> _suratList = [];
  SuratModel? _selectedSurat;
  UserModel? _pemohon;
  bool _isLoading = true;
  bool _isProcessing = false;
  final _catatanController = TextEditingController();
  String _selectedStatus = 'pending';

  @override
  void initState() {
    super.initState();
    _getSurat();
    if (widget.initialSuratId != null) {
      _getSuratDetail(widget.initialSuratId!);
    }
  }

  @override
  void dispose() {
    _catatanController.dispose();
    super.dispose();
  }

  Future<void> _getSurat() async {
    List<SuratModel> surat = await DatabaseService().getAllSurat();
    setState(() {
      _suratList = surat;
      _isLoading = false;
    });
  }

  Future<void> _getSuratDetail(String suratId) async {
    SuratModel? surat = _suratList.where((s) => s.id == suratId).firstOrNull;
    
    if (surat != null) {
      setState(() {
        _selectedSurat = surat;
        _selectedStatus = surat.status;
        _catatanController.text = surat.catatanAdmin ?? '';
      });
      
      // Get user data
      UserModel? user = await AuthService().getUserData(surat.userId);
      setState(() {
        _pemohon = user;
      });
    }
  }

  Future<void> _updateSuratStatus() async {
    if (_selectedSurat == null) return;
    
    setState(() {
      _isProcessing = true;
    });

    bool success = await DatabaseService().updateSuratStatus(
      _selectedSurat!.id,
      _selectedStatus,
      _catatanController.text.isEmpty ? null : _catatanController.text,
    );

    setState(() {
      _isProcessing = false;
    });

    if (success) {
      Helpers.showSnackBar(
        context,
        'Status surat berhasil diperbarui',
        color: Colors.green,
      );
      _getSurat();
      _getSuratDetail(_selectedSurat!.id);
    } else {
      Helpers.showSnackBar(
        context,
        'Gagal memperbarui status surat',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kelola Surat'),
        backgroundColor: AppColors.primaryColor,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Row(
              children: [
                // Surat List
                Expanded(
                  flex: 1,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _suratList.length,
                    itemBuilder: (context, index) {
                      final surat = _suratList[index];
                      final isSelected = _selectedSurat?.id == surat.id;
                      
                      return Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        elevation: isSelected ? 8 : 2,
                        color: isSelected ? AppColors.primaryColor.withOpacity(0.1) : null,
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          title: Text(
                            surat.jenisSurat,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Pemohon: ${surat.dataPemohon['nama']}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Tanggal: ${Helpers.formatDateTime(surat.tanggalPengajuan)}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Helpers.getStatusColor(surat.status),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              Helpers.getStatusText(surat.status),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          onTap: () => _getSuratDetail(surat.id),
                        ),
                      );
                    },
                  ),
                ),
                
                // Surat Detail
                Expanded(
                  flex: 2,
                  child: _selectedSurat == null
                      ? Container(
                          padding: const EdgeInsets.all(16),
                          child: Center(
                            child: Text(
                              'Pilih surat untuk melihat detail',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        )
                      : SingleChildScrollView(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Surat Header
                              Text(
                                'Detail Surat',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              
                              // Surat Info
                              _buildInfoCard('Jenis Surat', _selectedSurat!.jenisSurat),
                              _buildInfoCard('Status', Helpers.getStatusText(_selectedSurat!.status)),
                              _buildInfoCard('Tanggal Pengajuan', Helpers.formatDateTime(_selectedSurat!.tanggalPengajuan)),
                              if (_selectedSurat!.tanggalSelesai != null)
                                _buildInfoCard('Tanggal Selesai', Helpers.formatDateTime(_selectedSurat!.tanggalSelesai!)),
                              _buildInfoCard('Keperluan', _selectedSurat!.keperluan),
                              _buildInfoCard('Metode Penerimaan', _selectedSurat!.metodePenerimaan),
                              
                              const SizedBox(height: 24),
                              
                              // Pemohon Info
                              const Text(
                                'Data Pemohon',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              
                              _buildInfoCard('Nama', _selectedSurat!.dataPemohon['nama']),
                              _buildInfoCard('NIK', _selectedSurat!.dataPemohon['nik']),
                              _buildInfoCard('Nomor KK', _selectedSurat!.dataPemohon['noKK']),
                              _buildInfoCard('Tempat, Tanggal Lahir', '${_selectedSurat!.dataPemohon['tempatLahir']}, ${_selectedSurat!.dataPemohon['tanggalLahir']}'),
                              _buildInfoCard('Jenis Kelamin', _selectedSurat!.dataPemohon['jenisKelamin']),
                              _buildInfoCard('Pekerjaan', _selectedSurat!.dataPemohon['pekerjaan']),
                              _buildInfoCard('Agama', _selectedSurat!.dataPemohon['agama']),
                              _buildInfoCard('Status Perkawinan', _selectedSurat!.dataPemohon['statusPerkawinan']),
                              _buildInfoCard('Alamat KTP', _selectedSurat!.dataPemohon['alamatKTP']),
                              _buildInfoCard('Alamat Domisili', _selectedSurat!.dataPemohon['alamatDomisili']),
                              _buildInfoCard('Nomor Telepon', _selectedSurat!.dataPemohon['noTelp']),
                              
                              const SizedBox(height: 24),
                              
                              // Documents
                              const Text(
                                'Dokumen Pendukung',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              
                              _selectedSurat!.dokumenUrls.isEmpty
                                  ? const Text('Tidak ada dokumen pendukung')
                                  : Column(
                                      children: _selectedSurat!.dokumenUrls.map((url) {
                                        return Padding(
                                          padding: const EdgeInsets.only(bottom: 8),
                                          child: InkWell(
                                            onTap: () {
                                              // Open document in browser or viewer
                                            },
                                            child: Container(
                                              padding: const EdgeInsets.all(12),
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
                                              child: Row(
                                                children: [
                                                  const Icon(Icons.description),
                                                  const SizedBox(width: 12),
                                                  Expanded(
                                                    child: Text(
                                                      url.split('/').last,
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                  const Icon(Icons.open_in_new),
                                                ],
                                              ),
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                              
                              const SizedBox(height: 24),
                              
                              // Status Update
                              if (_selectedSurat!.status == 'pending') ...[
                                const Text(
                                  'Perbarui Status',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                
                                DropdownButtonFormField<String>(
                                  value: _selectedStatus,
                                  decoration: const InputDecoration(
                                    labelText: 'Status',
                                    border: OutlineInputBorder(),
                                  ),
                                  items: const [
                                    DropdownMenuItem(
                                      value: 'pending',
                                      child: Text('Menunggu Verifikasi'),
                                    ),
                                    DropdownMenuItem(
                                      value: 'approved',
                                      child: Text('Disetujui'),
                                    ),
                                    DropdownMenuItem(
                                      value: 'rejected',
                                      child: Text('Ditolak'),
                                    ),
                                  ],
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedStatus = value!;
                                    });
                                  },
                                ),
                                const SizedBox(height: 16),
                                
                                TextFormField(
                                  controller: _catatanController,
                                  maxLines: 3,
                                  decoration: const InputDecoration(
                                    labelText: 'Catatan (opsional)',
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                
                                CustomButtonWidget(
                                  text: 'Perbarui Status',
                                  onPressed: _updateSuratStatus,
                                  isLoading: _isProcessing,
                                ),
                              ],
                              
                              // Admin Notes
                              if (_selectedSurat!.status != 'pending' && _selectedSurat!.catatanAdmin != null) ...[
                                const Text(
                                  'Catatan Admin',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                
                                Container(
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
                                  child: Text(_selectedSurat!.catatanAdmin!),
                                ),
                              ],
                            ],
                          ),
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildInfoCard(String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}