// Definisi class model bernama Anggota
class Anggota {
  // Properti-properti yang dimiliki oleh Anggota
  final int id;
  final String nomorInduk;
  final String nama;
  final String alamat;
  final String tglLahir;
  final String telepon;

  // Constructor untuk membuat objek Anggota, semua properti wajib diisi (required)
  Anggota({
    required this.id,
    required this.nomorInduk,
    required this.nama,
    required this.alamat,
    required this.tglLahir,
    required this.telepon,
  });

  // Factory constructor untuk membuat objek Anggota dari JSON (Map)
  factory Anggota.fromJson(Map<String, dynamic> json) {
    return Anggota(
      id: json['id'] ?? 0, // Ambil nilai id dari json, jika null maka 0
      nomorInduk: json['nomor_induk']?.toString() ?? '', // Konversi ke String dan default ''
      nama: json['nama'] ?? '', // Ambil nama dari json, default ''
      alamat: json['alamat'] ?? '', // Ambil alamat dari json, default ''
      tglLahir: json['tgl_lahir'] ?? '', // Ambil tanggal lahir dari json, default ''
      telepon: json['telepon'] ?? '', // Ambil telepon dari json, default ''
    );
  }

  // Fungsi untuk mengubah objek Anggota menjadi Map JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nomor_induk': nomorInduk,
      'nama': nama,
      'alamat': alamat,
      'tgl_lahir': tglLahir,
      'telepon': telepon,
    };
  }
}