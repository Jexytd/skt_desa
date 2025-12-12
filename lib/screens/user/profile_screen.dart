import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import '../../services/auth_service.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';
import '../../widgets/custom_button_widget.dart';

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
  }

  Future<void> _updateProfile() async {
    if (_currentUser == null) return;
    
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
  }

  Future<void> _logout() async {
    await AuthService().signOut();
    // Navigation will be handled by the auth state stream in main.dart
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
        backgroundColor: AppColors.primaryColor,
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                setState(() {
                  _isEditing = true;
                });
              },
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile Header
                  Center(
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 60,
                          backgroundColor: AppColors.primaryColor,
                          child: Text(
                            _currentUser?.name.substring(0, 1).toUpperCase() ?? 'U',
                            style: const TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
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
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            _currentUser?.role == 'admin' ? 'Admin' : 'Masyarakat',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  // Profile Information
                  const Text(
                    'Informasi Pribadi',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
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
                  const SizedBox(height: 32),
                  
                  // Action Buttons
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
                  ],
                  const SizedBox(height: 16),
                  CustomButtonWidget(
                    text: 'Keluar',
                    onPressed: _logout,
                    color: Colors.red,
                  ),
                ],
              ),
            ),
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
          border: const OutlineInputBorder(),
          disabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey),
          ),
        ),
      ),
    );
  }
}