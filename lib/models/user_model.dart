class UserModel {
  final String uid;
  final String email;
  final String name;
  final String role; // 'user' atau 'admin'
  final String? nik;
  final String? noKK;
  final String? alamat;
  final String? noTelp;

  UserModel({
    required this.uid,
    required this.email,
    required this.name,
    required this.role,
    this.nik,
    this.noKK,
    this.alamat,
    this.noTelp,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'role': role,
      'nik': nik,
      'noKK': noKK,
      'alamat': alamat,
      'noTelp': noTelp,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      role: map['role'] ?? 'user',
      nik: map['nik'],
      noKK: map['noKK'],
      alamat: map['alamat'],
      noTelp: map['noTelp'],
    );
  }
}