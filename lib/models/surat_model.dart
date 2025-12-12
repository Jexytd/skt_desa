class SuratModel {
  final String id;
  final String userId;
  final String jenisSurat;
  final Map<String, dynamic> dataPemohon;
  final String keperluan;
  final List<String> dokumenUrls;
  final String metodePenerimaan;
  final String status; // 'pending', 'approved', 'rejected'
  final DateTime tanggalPengajuan;
  final DateTime? tanggalSelesai;
  final String? catatanAdmin;
  final Map<String, dynamic>? dataTambahan; // Tambahkan ini

  SuratModel({
    required this.id,
    required this.userId,
    required this.jenisSurat,
    required this.dataPemohon,
    required this.keperluan,
    required this.dokumenUrls,
    required this.metodePenerimaan,
    this.status = 'pending',
    required this.tanggalPengajuan,
    this.tanggalSelesai,
    this.catatanAdmin,
    this.dataTambahan, // Tambahkan ini
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'jenisSurat': jenisSurat,
      'dataPemohon': dataPemohon,
      'keperluan': keperluan,
      'dokumenUrls': dokumenUrls,
      'metodePenerimaan': metodePenerimaan,
      'status': status,
      'tanggalPengajuan': tanggalPengajuan.toIso8601String(),
      'tanggalSelesai': tanggalSelesai?.toIso8601String(),
      'catatanAdmin': catatanAdmin,
      'dataTambahan': dataTambahan, // Tambahkan ini
    };
  }

  factory SuratModel.fromMap(Map<String, dynamic> map) {
    return SuratModel(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      jenisSurat: map['jenisSurat'] ?? '',
      dataPemohon: Map<String, dynamic>.from(map['dataPemohon'] ?? {}),
      keperluan: map['keperluan'] ?? '',
      dokumenUrls: List<String>.from(map['dokumenUrls'] ?? []),
      metodePenerimaan: map['metodePenerimaan'] ?? '',
      status: map['status'] ?? 'pending',
      tanggalPengajuan: DateTime.parse(map['tanggalPengajuan']),
      tanggalSelesai: map['tanggalSelesai'] != null 
          ? DateTime.parse(map['tanggalSelesai']) 
          : null,
      catatanAdmin: map['catatanAdmin'],
      dataTambahan: map['dataTambahan'] != null 
          ? Map<String, dynamic>.from(map['dataTambahan']) 
          : null, // Tambahkan ini
    );
  }
}