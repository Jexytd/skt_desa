import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/surat_provider.dart';
import '../../models/surat_model.dart';
import '../../models/user_model.dart';
import '../../services/auth_service.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';
import '../../widgets/error_message.dart';
import '../../widgets/surat_card.dart';
import '../../widgets/custom_button_widget.dart';

class KelolaSuratScreen extends StatefulWidget {
  final String? initialSuratId;

  const KelolaSuratScreen({Key? key, this.initialSuratId}) : super(key: key);

  @override
  State<KelolaSuratScreen> createState() => _KelolaSuratScreenState();
}

class _KelolaSuratScreenState extends State<KelolaSuratScreen> {
  final _catatanController = TextEditingController();
  String _selectedStatus = 'pending';
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    // Load data saat widget pertama kali dibuat
    Future.microtask(() {
      final provider = context.read<SuratProvider>();
      provider.loadSurat().then((_) {
        if (widget.initialSuratId != null) {
          provider.loadSuratDetail(widget.initialSuratId!);
        }
      });
    });
  }

  Future<void> _updateSuratStatus(SuratProvider provider) async {
    final surat = provider.selectedSurat;
    if (surat == null) return;

    setState(() => _isProcessing = true);

    try {
      final confirm = await showDialog<bool>(
            context: context,
            builder: (_) => AlertDialog(
              title: const Text('Perbarui Status'),
              content: const Text('Apakah Anda yakin ingin memperbarui status surat ini?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Batal'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Perbarui'),
                ),
              ],
            ),
          ) ??
          false;

      if (!confirm) return;

      await provider.updateSuratStatus(
        surat.id,
        _selectedStatus,
        _catatanController.text.isEmpty ? null : _catatanController.text,
      );

      Helpers.showSnackBar(
        context,
        'Status surat berhasil diperbarui',
        color: Colors.green,
      );

      // Reload detail
      await provider.loadSuratDetail(surat.id);
    } catch (e) {
      Helpers.showSnackBar(context, 'Gagal memperbarui status: $e');
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SuratProvider>(
      builder: (context, provider, _) {
        final surat = provider.selectedSurat;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Kelola Surat'),
            backgroundColor: AppColors.primaryColor,
            elevation: 0,
          ),
          body: provider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : provider.error != null
                  ? ErrorMessage(
                      message: provider.error!,
                      onRetry: () => provider.loadSurat(),
                    )
                  : DefaultTabController(
                      length: 2,
                      child: Column(
                        children: [
                          // Tabs
                          Container(
                            decoration: BoxDecoration(
                              color: AppColors.cardColor,
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(20),
                                topRight: Radius.circular(20),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.1),
                                  spreadRadius: 1,
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: TabBar(
                              tabs: const [
                                Tab(text: 'Daftar Surat'),
                                Tab(text: 'Detail Surat'),
                              ],
                              indicatorColor: AppColors.primaryColor,
                              labelColor: AppColors.primaryColor,
                              unselectedLabelColor: AppColors.textSecondary,
                            ),
                          ),

                          // TabBarView
                          Expanded(
                            child: TabBarView(
                              children: [
                                // Daftar Surat
                                _buildSuratList(provider),
                                // Detail Surat
                                surat == null ? _buildNoSelection() : _buildSuratDetail(provider),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
        );
      },
    );
  }

  Widget _buildSuratList(SuratProvider provider) {
    final list = provider.suratList;

    if (list.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox, size: 64, color: AppColors.textSecondary),
            const SizedBox(height: 16),
            Text(
              'Tidak ada surat',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 8),
            Text(
              'Belum ada pengajuan surat dari masyarakat',
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final surat = list[index];
        final isSelected = provider.selectedSurat?.id == surat.id;

        return SuratCard(
          surat: surat,
          isSelected: isSelected,
          onTap: () => provider.loadSuratDetail(surat.id),
        );
      },
    );
  }

  Widget _buildNoSelection() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search, size: 64, color: AppColors.textSecondary),
          const SizedBox(height: 16),
          Text(
            'Pilih surat untuk melihat detail',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildSuratDetail(SuratProvider provider) {
    final surat = provider.selectedSurat!;
    final pemohon = surat.dataPemohon; // Asumsi sudah ada field dataPemohon Map<String, String>
    _selectedStatus = surat.status;
    _catatanController.text = surat.catatanAdmin ?? '';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Surat Info
          _buildInfoSection('Jenis Surat', surat.jenisSurat),
          _buildInfoSection('Status', Helpers.getStatusText(surat.status)),
          _buildInfoSection('Tanggal Pengajuan', Helpers.formatDateTime(surat.tanggalPengajuan)),
          if (surat.tanggalSelesai != null)
            _buildInfoSection('Tanggal Selesai', Helpers.formatDateTime(surat.tanggalSelesai!)),
          _buildInfoSection('Keperluan', surat.keperluan),
          _buildInfoSection('Metode Penerimaan', surat.metodePenerimaan),

          const SizedBox(height: 24),

          // Data Pemohon
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.cardColor,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Data Pemohon', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                const SizedBox(height: 12),
                _buildInfoSection('Nama', pemohon['nama']),
                _buildInfoSection('NIK', pemohon['nik']),
                _buildInfoSection('Nomor KK', pemohon['noKK']),
                _buildInfoSection('Tempat, Tanggal Lahir', '${pemohon['tempatLahir']}, ${pemohon['tanggalLahir']}'),
                _buildInfoSection('Jenis Kelamin', pemohon['jenisKelamin']),
                _buildInfoSection('Pekerjaan', pemohon['pekerjaan']),
                _buildInfoSection('Agama', pemohon['agama']),
                _buildInfoSection('Status Perkawinan', pemohon['statusPerkawinan']),
                _buildInfoSection('Alamat KTP', pemohon['alamatKTP']),
                _buildInfoSection('Alamat Domisili', pemohon['alamatDomisili']),
                _buildInfoSection('Nomor Telepon', pemohon['noTelp']),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Dokumen Pendukung
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.cardColor,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Dokumen Pendukung', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                const SizedBox(height: 12),
                if (surat.dokumenUrls.isEmpty)
                  const Text('Tidak ada dokumen pendukung')
                else
                  ...surat.dokumenUrls.map((url) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: InkWell(
                          onTap: () {
                            // Buka dokumen
                          },
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.cardColor,
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.1),
                                  spreadRadius: 1,
                                  blurRadius: 5,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.description, color: AppColors.primaryColor),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(url.split('/').last, overflow: TextOverflow.ellipsis),
                                ),
                                const Icon(Icons.open_in_new, color: AppColors.primaryColor),
                              ],
                            ),
                          ),
                        ),
                      )),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Update Status
          if (surat.status == 'pending') ...[
            DropdownButtonFormField<String>(
              value: _selectedStatus,
              decoration: InputDecoration(
                labelText: 'Status',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Colors.grey[50],
              ),
              items: const [
                DropdownMenuItem(value: 'pending', child: Text('Menunggu Verifikasi')),
                DropdownMenuItem(value: 'approved', child: Text('Disetujui')),
                DropdownMenuItem(value: 'rejected', child: Text('Ditolak')),
              ],
              onChanged: (value) => setState(() => _selectedStatus = value!),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _catatanController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Catatan (opsional)',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Colors.grey[50],
              ),
            ),
            const SizedBox(height: 12),
            CustomButtonWidget(
              text: 'Perbarui Status',
              onPressed: () => _updateSuratStatus(provider),
              isLoading: _isProcessing,
            ),
          ],

          // Catatan Admin
          if (surat.status != 'pending' && surat.catatanAdmin != null) ...[
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.cardColor,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Catatan Admin', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                  const SizedBox(height: 12),
                  Text(surat.catatanAdmin!),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoSection(String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 14, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
