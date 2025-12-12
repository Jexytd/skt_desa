class BeritaModel {
  final String id;
  final String judul;
  final String isi;
  final String imageUrl;
  final DateTime tanggal;
  final String author;

  BeritaModel({
    required this.id,
    required this.judul,
    required this.isi,
    required this.imageUrl,
    required this.tanggal,
    required this.author,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'judul': judul,
      'isi': isi,
      'imageUrl': imageUrl,
      'tanggal': tanggal.toIso8601String(),
      'author': author,
    };
  }

  factory BeritaModel.fromMap(Map<String, dynamic> map) {
    return BeritaModel(
      id: map['id'] ?? '',
      judul: map['judul'] ?? '',
      isi: map['isi'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      tanggal: DateTime.parse(map['tanggal']),
      author: map['author'] ?? '',
    );
  }
}