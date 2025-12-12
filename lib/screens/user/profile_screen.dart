// lib/screens/user/profile_screen.dart - Fixed logout implementation
import 'package:flutter/material.dart';
import 'package:skt_desa/widgets/custom_button_widget.dart';
import '../../models/user_model.dart';
import '../../services/auth_service.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';
import '../../widgets/custom_card_widget.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  UserModel? _currentUser;
  bool _isLoading = true;
  bool _isEditing = false;
  
  final _nameController = TextEditingController();
  final _nikController = TextEditingController();
  final _noKKController = TextEditingController();
  final _alamatController = TextEditingController();
  final _noTelpController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
  }

  Future<void> _getCurrentUser() async {
    try {
      UserModel? user = await AuthService().getUserData(
        AuthService().currentUser!.uid,
      );
      setState(() {
        _currentUser = user;
        _isLoading = false;
        
        // Initialize controllers
        _nameController.text = user?.name ?? '';
        _nikController.text = user?.nik ?? '';
        _noKKController.text = user?.noKK ?? '';
        _alamatController.text = user?.alamat ?? '';
        _noTelpController.text = user?.noTelp ?? '';
      });
    } catch (e) {
      Helpers.showSnackBar(context, 'Gagal memuat data profil: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _updateProfile() async {
    if (_currentUser == null) return;
    
    try {
      UserModel updatedUser = UserModel(
        uid: _currentUser!.uid,
        email: _currentUser!.email,
        name: _nameController.text,
        role: _currentUser!.role,
        nik: _nikController.text,
        noKK: _noKKController.text,
        alamat: _alamatController.text,
        noTelp: _noTelpController.text,
      );

      bool success = await AuthService().updateUserData(updatedUser);
      
      if (success) {
        setState(() {
          _currentUser = updatedUser;
          _isEditing = false;
        });
        Helpers.showSnackBar(
          context,
          'Profil berhasil diperbarui',
          color: Colors.green,
        );
      } else {
        Helpers.showSnackBar(
          context,
          'Gagal memperbarui profil',
        );
      }
    } catch (e) {
      Helpers.showSnackBar(
        context,
        'Gagal memperbarui profil: $e',
      );
    }
  }

  Future<void> _logout() async {
    try {
      await AuthService().signOut();
      // Navigate to login screen after successful logout
      Navigator.pushReplacementNamed(context, AppRoutes.login);
    } catch (e) {
      Helpers.showSnackBar(
        context,
        'Gagal logout: $e',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
        backgroundColor: AppColors.primaryColor,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile Header with enhanced design
                  _buildProfileHeader(),
                  const SizedBox(height: 24),
                  
                  // Profile Information with card design
                  _buildProfileInformation(),
                  const SizedBox(height: 24),
                  
                  // Action Buttons
                  _buildActionButtons(),
                ],
              ),
            ),
    );
  }

  Widget _buildProfileHeader() {
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
        children: [
          Row(
            children: [
              // Profile Avatar
              Stack(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: AppColors.primaryColor,
                    child: Text(
                      _currentUser?.name.substring(0, 1).toUpperCase() ?? 'U',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white,
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        _isEditing ? Icons.check : Icons.edit,
                        size: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              
              // Profile Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _currentUser?.name ?? 'User',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      _currentUser?.email ?? 'user@example.com',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: _currentUser?.role == 'admin' ? Colors.orange : Colors.blue,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _currentUser?.role == 'admin' ? 'Admin' : 'Masyarakat',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProfileInformation() {
    return Container(
      padding: const EdgeInsets.all(20),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Informasi Pribadi',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          
          _buildProfileField(
            'Nama Lengkap',
            _nameController,
            _isEditing,
          ),
          _buildProfileField(
            'NIK',
            _nikController,
            _isEditing,
            keyboardType: TextInputType.number,
          ),
          _buildProfileField(
            'Nomor KK',
            _noKKController,
            _isEditing,
            keyboardType: TextInputType.number,
          ),
          _buildProfileField(
            'Alamat',
            _alamatController,
            _isEditing,
            maxLines: 3,
          ),
          _buildProfileField(
            'Nomor Telepon/WhatsApp',
            _noTelpController,
            _isEditing,
            keyboardType: TextInputType.phone,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        if (_isEditing) ...[
          Row(
            children: [
              Expanded(
                child: CustomButtonWidget(
                  text: 'Simpan',
                  onPressed: _updateProfile,
                  color: Colors.green,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: CustomButtonWidget(
                  text: 'Batal',
                  onPressed: () {
                    setState(() {
                      _isEditing = false;
                      // Reset controllers to original values
                      _nameController.text = _currentUser?.name ?? '';
                      _nikController.text = _currentUser?.nik ?? '';
                      _noKKController.text = _currentUser?.noKK ?? '';
                      _alamatController.text = _currentUser?.alamat ?? '';
                      _noTelpController.text = _currentUser?.noTelp ?? '';
                    });
                  },
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
        CustomButtonWidget(
          text: 'Keluar',
          onPressed: _logout,
          color: Colors.red,
        ),
      ],
    );
  }

  Widget _buildProfileField(
    String label,
    TextEditingController controller,
    bool isEditing, {
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        enabled: isEditing,
        maxLines: maxLines,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.primaryColor),
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          filled: true,
          fillColor: isEditing ? Colors.grey[50] : Colors.transparent,
        ),
      ),
    );
  }
}