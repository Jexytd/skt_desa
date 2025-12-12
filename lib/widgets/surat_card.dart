// lib/widgets/surat_card.dart - Reusable Surat Card Widget
import 'package:flutter/material.dart';
import 'package:skt_desa/utils/constants.dart';
import '../models/surat_model.dart';
import '../utils/helpers.dart';

class SuratCard extends StatelessWidget {
  final SuratModel surat;
  final bool isSelected;
  final VoidCallback? onTap;

  const SuratCard({
    Key? key,
    required this.surat,
    this.isSelected = false,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isSelected 
            ? AppColors.primaryColor.withOpacity(0.1)
            : AppColors.cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: ListTile(
          contentPadding: const EdgeInsets.all(16),
          title: Text(
            surat.jenisSurat,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: isSelected ? AppColors.primaryColor : null,
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
              borderRadius: BorderRadius.circular(20),
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
        ),
      ),
    );
  }
}