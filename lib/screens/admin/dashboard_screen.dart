// lib/screens/admin/dashboard_screen.dart - Refactored with Providers
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skt_desa/widgets/error_message.dart';
import 'package:skt_desa/widgets/loading_indicator.dart';
import '../../providers/surat_provider.dart';
import '../../models/user_model.dart';
import '../../models/surat_model.dart';
import '../../providers/auth_provider.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';
import 'kelola_berita_screen.dart';
import 'kelola_surat_screen.dart';
import '../../widgets/custom_card_widget.dart';
import '../../widgets/surat_card.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    // Load data when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<SuratProvider>(context, listen: false).loadSurat();
    });
  }

  @override
  Widget build(BuildContext context) {
    final suratProvider = Provider.of<SuratProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Admin'),
        backgroundColor: AppColors.primaryColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              Provider.of<SuratProvider>(context, listen: false).loadSurat();
            },
          ),
        ],
      ),
      body: suratProvider.isLoading
          ? const LoadingIndicator()
          : suratProvider.error != null
              ? ErrorMessage(
                  message: suratProvider.error!,
                  onRetry: () {
                    Provider.of<SuratProvider>(context, listen: false).loadSurat();
                  },
                )
              : RefreshIndicator(
                  onRefresh: () async {
                    Provider.of<SuratProvider>(context, listen: false).loadSurat();
                  },
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Welcome Message with gradient background
                        _buildWelcomeMessage(authProvider.currentUser),
                        const SizedBox(height: 24),
                        
                        // Stats Cards with animation
                        _buildStatsSection(suratProvider.suratList),
                        const SizedBox(height: 24),
                        
                        // Quick Actions with better design
                        _buildQuickActions(),
                        const SizedBox(height: 24),
                        
                        // Recent Applications with improved UI
                        _buildRecentApplications(suratProvider.suratList),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildWelcomeMessage(UserModel? user) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryColor.withOpacity(0.1),
            AppColors.secondaryColor.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Selamat Datang, ${user?.name ?? 'Admin'}!',
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Kelola layanan surat online untuk masyarakat',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection(List<SuratModel> suratList) {
    return Column(
      children: [
        // Top row stats
        Row(
          children: [
            Expanded(
              child: CustomCardWidget(
                title: 'Total Permohonan',
                value: suratList.length.toString(),
                icon: Icons.description,
                iconColor: Colors.blue,
                valueColor: Colors.blue,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: CustomCardWidget(
                title: 'Menunggu Verifikasi',
                value: suratList.where((s) => s.status == 'pending').length.toString(),
                icon: Icons.hourglass_empty,
                iconColor: Colors.orange,
                valueColor: Colors.orange,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Bottom row stats
        Row(
          children: [
            Expanded(
              child: CustomCardWidget(
                title: 'Disetujui',
                value: suratList.where((s) => s.status == 'approved').length.toString(),
                icon: Icons.check_circle,
                iconColor: Colors.green,
                valueColor: Colors.green,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: CustomCardWidget(
                title: 'Ditolak',
                value: suratList.where((s) => s.status == 'rejected').length.toString(),
                icon: Icons.cancel,
                iconColor: Colors.red,
                valueColor: Colors.red,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Aksi Cepat',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                'Kelola Surat',
                Icons.description,
                Colors.blue,
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const KelolaSuratScreen(),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildActionCard(
                'Kelola Berita',
                Icons.article,
                Colors.green,
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const KelolaBeritaScreen(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRecentApplications(List<SuratModel> suratList) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Permohonan Terbaru',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        suratList.isEmpty
            ? _buildEmptyState()
            : Column(
                children: suratList.take(5).map((surat) {
                  return SuratCard(
                    surat: surat,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => KelolaSuratScreen(
                            initialSuratId: surat.id,
                          ),
                        ),
                      );
                    },
                  );
                }).toList(),
              ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            Icons.inbox,
            size: 48,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: 16),
          Text(
            'Belum ada permohonan',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.cardColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: color,
                size: 28,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}