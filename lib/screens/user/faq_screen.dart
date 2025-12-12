import 'package:flutter/material.dart';
import '../../utils/constants.dart';

class FAQScreen extends StatelessWidget {
  const FAQScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FAQ'),
        backgroundColor: AppColors.primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _buildFAQItem(
              'Bagaimana cara mengajukan surat secara online?',
              'Anda dapat mengajukan surat secara online melalui aplikasi ini dengan mengisi form yang tersedia pada menu Layanan. Pastikan semua data yang diperlukan sudah diisi dengan benar dan lengkap, serta upload dokumen pendukung yang diperlukan.',
            ),
            _buildFAQItem(
              'Dokumen apa saja yang perlu disiapkan untuk pengajuan surat?',
              'Dokumen yang perlu disiapkan tergantung jenis surat yang diajukan. Namun secara umum, Anda perlu menyiapkan: fotokopi KTP, fotokopi KK, pas foto terbaru, dan dokumen pendukung lainnya sesuai kebutuhan.',
            ),
            _buildFAQItem(
              'Berapa lama proses verifikasi surat?',
              'Proses verifikasi surat biasanya memakan waktu 1-3 hari kerja tergantung dari kelengkapan dokumen dan antrian di kantor nagari. Anda dapat memantau status pengajuan melalui aplikasi.',
            ),
            _buildFAQItem(
              'Bagaimana cara mengambil surat yang sudah disetujui?',
              'Anda dapat mengambil surat yang sudah disetujui sesuai dengan metode penerimaan yang Anda pilih saat mengajukan. Jika memilih ambil langsung, Anda dapat datang ke kantor nagari pada jam kerja. Jika memilih pengiriman digital, surat akan dikirim melalui email/WhatsApp atau dapat diunduh melalui aplikasi.',
            ),
            _buildFAQItem(
              'Apakah ada biaya untuk pengajuan surat?',
              'Beberapa jenis surat mungkin dikenakan biaya administrasi sesuai dengan peraturan yang berlaku di nagari. Informasi mengenai biaya akan diinformasikan saat proses verifikasi.',
            ),
            _buildFAQItem(
              'Bagaimana jika ada kesalahan data pada surat yang sudah disetujui?',
              'Jika terdapat kesalahan data pada surat yang sudah disetujui, Anda dapat menghubungi admin melalui fitur yang tersedia atau datang langsung ke kantor nagari untuk perbaikan.',
            ),
            _buildFAQItem(
              'Apakah data saya aman di aplikasi ini?',
              'Ya, data Anda aman di aplikasi ini. Kami menggunakan sistem keamanan yang baik dan semua data disimpan dengan enkripsi. Data pribadi Anda hanya akan digunakan untuk keperluan administrasi surat.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFAQItem(String question, String answer) {
    return ExpansionTile(
      title: Text(
        question,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(answer),
        ),
      ],
    );
  }
}