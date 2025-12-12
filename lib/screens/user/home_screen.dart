// lib/screens/user/home_screen.dart - Modified to navigate to service selection
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:skt_desa/widgets/berita_card.dart';
import '../../models/user_model.dart';
import '../../models/berita_model.dart';
import '../../services/auth_service.dart';
import '../../services/database_service.dart';
import '../../utils/constants.dart';
import '../../widgets/navbar_widget.dart';
import '../admin/dashboard_screen.dart';
import 'service_selection_screen.dart'; // Import the new screen
import 'faq_screen.dart';
import 'profile_screen.dart';
import 'package:skt_desa/utils/helpers.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  UserModel? _currentUser;
  List<BeritaModel> _beritaList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
    _getBerita();
  }

  Future<void> _getCurrentUser() async {
    try {
      UserModel? user = await AuthService().getUserData(
        AuthService().currentUser!.uid,
      );
      setState(() {
        _currentUser = user;
      });
    } catch (e) {
      Helpers.showSnackBar(context, 'Gagal memuat data pengguna: $e');
    }
  }

  Future<void> _getBerita() async {
    try {
      List<BeritaModel> berita = await DatabaseService().getAllBerita();
      setState(() {
        _beritaList = berita;
        _isLoading = false;
      });
    } catch (e) {
      Helpers.showSnackBar(context, 'Gagal memuat berita: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Check if user is admin
    if (_currentUser?.role == 'admin') {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, AppRoutes.adminDashboard);
      });
      return const SizedBox(); // Return empty widget while navigating
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.appName),
        backgroundColor: AppColors.primaryColor,
        automaticallyImplyLeading: false,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image Slider
                  CarouselSlider(
                    options: CarouselOptions(
                      height: 200,
                      autoPlay: true,
                      enlargeCenterPage: true,
                      autoPlayInterval: const Duration(seconds: 3),
                      autoPlayAnimationDuration: const Duration(
                        milliseconds: 800,
                      ),
                    ),
                    items:
                        [
                          'https://picsum.photos/seed/nagari1/800/400.jpg',
                          'https://picsum.photos/seed/nagari2/800/400.jpg',
                          'https://picsum.photos/seed/nagari3/800/400.jpg',
                        ].map((url) {
                          return Builder(
                            builder: (BuildContext context) {
                              return Container(
                                width: MediaQuery.of(context).size.width,
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 5.0,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  image: DecorationImage(
                                    image: NetworkImage(url),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              );
                            },
                          );
                        }).toList(),
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Welcome Message
                        Text(
                          '${AppStrings.welcomeMessage}, ${_currentUser?.name ?? 'Pengguna'}!',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryColor,
                          ),
                        ),
                        const SizedBox(height: 16),
                        // App Description
                        Text(
                          AppStrings.appDescription,
                          style: TextStyle(
                            fontSize: 16,
                            color: AppColors.textSecondary,
                          ),
                          textAlign: TextAlign.justify,
                        ),
                        const SizedBox(height: 24),
                        // News Section
                        Text(
                          'Berita & Informasi Penting',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _beritaList.isEmpty
                            ? Container(
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
                                child: Center(
                                  child: Text(
                                    'Belum ada berita',
                                    style: TextStyle(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ),
                              )
                            : ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: _beritaList.length > 3
                                    ? 3
                                    : _beritaList.length,
                                itemBuilder: (context, index) {
                                  final berita = _beritaList[index];
                                  return BeritaCard(
                                    berita: berita,
                                  );
                                },
                              ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
      bottomNavigationBar: NavbarWidget(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });

          switch (index) {
            case 0:
              // Already on home
              break;
            case 1:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ServiceSelectionScreen()),
              );
              break;
            case 2:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const FAQScreen()),
              );
              break;
            case 3:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              );
              break;
          }
        },
      ),
    );
  }
}