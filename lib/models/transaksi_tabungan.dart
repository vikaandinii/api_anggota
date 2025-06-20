class TransaksiTabungan {
  // Properti/atribut dari class
  final int? id;               // ID transaksi (nullable)
  final int? trxId;            // ID jenis transaksi (nullable)
  final String? trxTanggal;    // Tanggal transaksi (nullable)
  final int trxNominal;        // Nominal uang (wajib diisi)

  // Constructor
  TransaksiTabungan({
    this.id,                   // Bisa null
    this.trxId,                // Bisa null
    this.trxTanggal,           // Bisa null
    required this.trxNominal,  // Harus diisi saat membuat objek
  });

  // Factory constructor untuk membuat objek dari JSON (Map)
  factory TransaksiTabungan.fromJson(Map<String, dynamic> json) {
    return TransaksiTabungan(
      // Ambil 'id' dari json, konversi ke int, jika gagal/null maka null
      id: json['id'] != null ? int.tryParse(json['id'].toString()) : null,
      
      // Ambil 'trx_id' dari json, konversi ke int, jika gagal/null maka null
      trxId: json['trx_id'] != null
          ? int.tryParse(json['trx_id'].toString())
          : null,

      // Ambil 'trx_tanggal' langsung dari JSON
      trxTanggal: json['trx_tanggal'],

      // Ambil 'trx_nominal', konversi ke int, jika gagal maka default 0
      trxNominal: json['trx_nominal'] != null
          ? int.tryParse(json['trx_nominal'].toString()) ?? 0
          : 0,
    );
  }

  // Method untuk mengubah objek menjadi JSON (Map)
  Map<String, dynamic> toJson() {
    return {
      'id': id,                   // Masukkan nilai id ke JSON
      'trx_id': trxId,           // Masukkan trxId ke JSON
      'trx_tanggal': trxTanggal, // Masukkan tanggal ke JSON
      'trx_nominal': trxNominal, // Masukkan nominal ke JSON
    };
  }
}