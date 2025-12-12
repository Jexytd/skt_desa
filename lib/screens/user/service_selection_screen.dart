// lib/screens/user/service_selection_screen.dart - New Service Selection Screen
import 'package:flutter/material.dart';
import 'package:skt_desa/screens/user/layanan_screen.dart';
import '../../models/surat_model.dart';
import '../../utils/constants.dart';
import '../../widgets/custom_card_widget.dart';

class ServiceSelectionScreen extends StatefulWidget {
  const ServiceSelectionScreen({Key? key}) : super(key: key);

  @override
  _ServiceSelectionScreenState createState() => _ServiceSelectionScreenState();
}

class _ServiceSelectionScreenState extends State<ServiceSelectionScreen> {
  String? _selectedService;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pilih Layanan Surat'),
        backgroundColor: AppColors.primaryColor,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Pilih jenis surat yang Anda butuhkan',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  Expanded(
                    child: GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 3/2,
                      ),
                      itemCount: AppStrings.jenisSuratList.length,
                      itemBuilder: (context, index) {
                        final service = AppStrings.jenisSuratList[index];
                        final isSelected = _selectedService == service;
                        
                        return _buildServiceCard(service, isSelected);
                      },
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  _buildActionButton(),
                ],
              ),
            ),
    );
  }

  Widget _buildServiceCard(String service, bool isSelected) {
    return InkWell(
      onTap: () {
        setState(() {
          _selectedService = service;
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected 
              ? AppColors.primaryColor.withOpacity(0.1)
              : AppColors.cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primaryColor : Colors.grey[300]!,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Text(
            service,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isSelected ? AppColors.primaryColor : AppColors.textPrimary,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _selectedService != null 
            ? () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LayananScreen(
                      selectedService: _selectedService!,
                    ),
                  ),
                );
              }
            : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryColor,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text(
          'Lanjutkan Pengajuan',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}