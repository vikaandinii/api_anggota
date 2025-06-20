import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'models/anggota.dart';
import 'models/transaksi_tabungan.dart';

class ApiService {
  final Dio dio;
  final Logger logger = Logger();

  ApiService()
      : dio = Dio(
          BaseOptions(
            baseUrl: 'https://mobileapis.manpits.xyz/api',
            headers: {'Content-Type': 'application/x-www-form-urlencoded'},
          ),
        );

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await dio.post(
        '/login',
        data: {'email': email, 'password': password},
        options: Options(contentType: Headers.formUrlEncodedContentType),
      );
      return response.data;
    } catch (e) {
      logger.e('Error login: $e');
      return {'status': 'error', 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> register(
    String name,
    String email,
    String password,
  ) async {
    try {
      final response = await dio.post(
        '/register',
        data: {'name': name, 'email': email, 'password': password},
        options: Options(contentType: Headers.formUrlEncodedContentType),
      );
      return response.data;
    } catch (e) {
      logger.e('Error register: $e');
      return {'status': 'error', 'message': e.toString()};
    }
  }

  Future<List<Anggota>> getAnggota(String token) async {
    try {
      final response = await dio.get(
        '/anggota',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      logger.i("RESPONSE ANGGOTA: ${response.data}");

      if (response.data['success'] == true ||
          response.data['status'] == 'success') {
        final dynamic data = response.data['data']['anggotas'];
        if (data is List) {
          return data
              .map((json) => Anggota.fromJson(Map<String, dynamic>.from(json)))
              .toList();
        } else if (data is Map) {
          return [Anggota.fromJson(Map<String, dynamic>.from(data))];
        } else {
          throw Exception('Format data tidak dikenali');
        }
      } else {
        throw Exception('Gagal mengambil data anggota');
      }
    } catch (e) {
      logger.e('Error get anggota: $e');
      throw Exception("Error fetching anggota: $e");
    }
  }

  Future<Anggota> getAnggotaById(String token, int id) async {
    try {
      final response = await dio.get(
        '/anggota/$id',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.data != null && response.data['data'] != null) {
        final anggotaData = response.data['data'];
        return Anggota.fromJson(anggotaData);
      } else {
        return Anggota(
          id: 0,
          nomorInduk: 'Nomor Induk Tidak Tersedia',
          nama: 'Nama Tidak Tersedia',
          alamat: 'Alamat Tidak Tersedia',
          tglLahir: 'Tanggal Lahir Tidak Tersedia',
          telepon: 'Telepon Tidak Tersedia',
        );
      }
    } catch (e) {
      logger.e('Error get anggota by ID: $e');
      if (e is DioException) {
        logger.e('Dio error: ${e.message}');
      }
      return Anggota(
        id: 0,
        nomorInduk: 'Nomor Induk Tidak Tersedia',
        nama: 'Nama Tidak Tersedia',
        alamat: 'Alamat Tidak Tersedia',
        tglLahir: 'Tanggal Lahir Tidak Tersedia',
        telepon: 'Telepon Tidak Tersedia',
      );
    }
  }

  Future<Map<String, dynamic>> addAnggota(
    String token,
    Map<String, dynamic> anggotaData,
  ) async {
    try {
      final formData = FormData.fromMap(anggotaData);
      final response = await dio.post(
        '/anggota',
        data: formData,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return response.data;
    } catch (e) {
      logger.e('Error add anggota: $e');
      return {'status': 'error', 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> updateAnggota(
    String token,
    int id,
    Map<String, dynamic> updatedData,
  ) async {
    try {
      final response = await dio.put(
        '/anggota/$id',
        data: updatedData,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return response.data;
    } catch (e) {
      throw Exception("Error updating anggota: $e");
    }
  }

  Future<void> deleteAnggota(String token, int id) async {
    try {
      final response = await dio.delete(
        '/anggota/$id',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      logger.i("Delete anggota response: ${response.data}");
    } catch (e) {
      logger.e("Error deleting anggota: $e");
      throw Exception("Gagal menghapus anggota");
    }
  }

  Future<Map<String, dynamic>> logout(String token) async {
    try {
      final response = await dio.get(
        '/logout',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return response.data;
    } catch (e) {
      logger.e('Error logout: $e');
      return {'status': 'error', 'message': e.toString()};
    }
  }

  Future<double> getSaldoTabungan(String token, int anggotaId) async {
    try {
      final response = await dio.get(
        '/saldo/$anggotaId',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      logger.i('Status Code saldo: ${response.statusCode}');
      logger.i('Response saldo: ${response.data}');

      if (response.statusCode == 200) {
        final saldoRaw = response.data['data']?['saldo'];
        if (saldoRaw != null) {
          return double.tryParse(saldoRaw.toString()) ?? 0.0;
        } else {
          return 0.0;
        }
      } else if (response.statusCode == 204) {
        return 0.0;
      } else {
        throw Exception('Gagal mengambil saldo: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error get saldo: $e');
    }
  }

  Future<void> tambahTransaksiTabungan(
    String token,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await dio.post(
        '/tabungan',
        data: data,
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
          contentType: Headers.formUrlEncodedContentType,
        ),
      );

      if (response.statusCode != 200 &&
          response.statusCode != 201 &&
          response.statusCode != 204) {
        throw Exception('Gagal tambah transaksi: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error tambah transaksi: $e');
    }
  }

  Future<List<TransaksiTabungan>> getTransaksiTabungan(
    String token,
    int anggotaId,
  ) async {
    try {
      final response = await dio.get(
        '/tabungan/$anggotaId',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      logger.i('Status Code: ${response.statusCode}');
      logger.i('Response: ${response.data}');

      if (response.statusCode == 200) {
        final resultData = response.data['data'];
        if (resultData != null && resultData['tabungan'] is List) {
          final List tabunganList = resultData['tabungan'];
          return tabunganList
              .map((json) => TransaksiTabungan.fromJson(json))
              .toList();
        } else {
          return [];
        }
      } else if (response.statusCode == 204) {
        return [];
      } else {
        throw Exception(
          'Gagal mengambil data transaksi: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error get transaksi: $e');
    }
  }

  Future<List<dynamic>> getJenisTransaksi(String token) async {
    try {
      final response = await dio.get(
        '/jenistransaksi',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        ),
      );

      logger.i('Status Code Jenis Transaksi: ${response.statusCode}');
      logger.i('Response Jenis Transaksi: ${response.data}');

      if (response.statusCode == 200) {
        final data = response.data['data'];
        if (data == null || data['jenistransaksi'] == null) {
          logger.w('Data atau jenistransaksi kosong');
          return [];
        }

        final List<dynamic> listData = data['jenistransaksi'];
        final processedList = listData.map((item) {
          if (item is Map<String, dynamic>) {
            return {
              ...item,
              'id': int.tryParse(item['id'].toString()) ?? 0,
            };
          }
          return item;
        }).toList();

        return processedList;
      } else if (response.statusCode == 204) {
        logger.w('Tidak ada data (204 No Content)');
        return [];
      } else {
        throw Exception(
          'Gagal mengambil jenis transaksi, status: ${response.statusCode}',
        );
      }
    } catch (e) {
      logger.e('Error getJenisTransaksi: $e');
      throw Exception('Error mengambil jenis transaksi: $e');
    }
  }
}