import 'package:flutter/material.dart';

class AppColors {
  static const primaryColor = Color(0xFF1976D2);
  static const secondaryColor = Color(0xFF2196F3);
  static const accentColor = Color(0xFFFF9800);
  static const backgroundColor = Color(0xFFF5F5F5);
  static const cardColor = Colors.white;
  static const textPrimary = Color(0xFF212121);
  static const textSecondary = Color(0xFF757575);
}

class AppStrings {
  static const appName = 'Layanan Surat Online Nagari';
  static const welcomeMessage = 'Selamat Datang';
  static const appDescription = 'Aplikasi layanan pembuatan surat secara online untuk mempermudah masyarakat dalam mengurus administrasi keperluan surat di kantor nagari/desa.';
  
  // Form labels
  static const namaLabel = 'Nama Lengkap';
  static const nikLabel = 'NIK';
  static const noKKLabel = 'Nomor KK';
  static const ttlLabel = 'Tempat, Tanggal Lahir';
  static const jenisKelaminLabel = 'Jenis Kelamin';
  static const pekerjaanLabel = 'Pekerjaan';
  static const agamaLabel = 'Agama';
  static const statusPerkawinanLabel = 'Status Perkawinan';
  static const alamatKTPLabel = 'Alamat KTP';
  static const alamatDomisiliLabel = 'Alamat Domisili (jika berbeda)';
  static const noTelpLabel = 'Nomor Telepon/WhatsApp';
  static const keperluanLabel = 'Keperluan Penggunaan Surat';
  static const metodePenerimaanLabel = 'Metode Penerimaan Surat';
  
  static const List<String> jenisSuratList = [
    'Surat Domisili',
    'Surat Keterangan Usaha',
    'Surat Keterangan Tidak Mampu',
    'Surat Pengantar SKCK',
    'Surat Keterangan Kelahiran',
    'Surat Keterangan Kematian',
    'Surat Keterangan Belum Menikah',
    'Surat Keterangan Pindah',
  ];
  
  // Metode Penerimaan
  static const List<String> metodePenerimaanList = [
    'Ambil langsung di kantor nagari',
    'Kirim file PDF via email',
    'Kirim file PDF via WhatsApp',
    'Unduh langsung melalui aplikasi',
  ];
}

class AppRoutes {
  static const login = '/login';
  static const register = '/register';
  static const home = '/home';
  static const serviceSelection = '/service-selection';
  static const layanan = '/layanan';
  static const faq = '/faq';
  static const profile = '/profile';
  static const adminDashboard = '/admin/dashboard';
  static const kelolaBerita = '/admin/kelola-berita';
  static const kelolaSurat = '/admin/kelola-surat';
  static const chat = '/chat';
  static const adminChat = '/admin/chat';
}