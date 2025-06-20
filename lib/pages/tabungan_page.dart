import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';

import '/api_service.dart';
import '/models/anggota.dart';
import '/models/transaksi_tabungan.dart';
import 'add_transaksi_page.dart';

class TabunganPage extends StatefulWidget {
  final ApiService apiService;
  final Anggota anggota;

  const TabunganPage({
    super.key,
    required this.apiService,
    required this.anggota,
  });

  @override
  State<TabunganPage> createState() => _TabunganPageState();
}

class _TabunganPageState extends State<TabunganPage> {
  late Future<List<TransaksiTabungan>> _transaksiFuture;
  double _saldo = 0.0;
  final _storage = const FlutterSecureStorage();

  Map<int, String> _jenisTransaksiMap = {};

  @override
  void initState() {
    super.initState();
    _transaksiFuture = _loadData();
  }

  Future<List<TransaksiTabungan>> _loadData() async {
    final token = await _storage.read(key: 'token');
    if (token == null) {
      debugPrint('[DEBUG] Token tidak ditemukan saat loadData');
      return [];
    }

    try {
      debugPrint('[DEBUG] Memuat jenis transaksi, saldo, dan data transaksi');
      final jenisList = await widget.apiService.getJenisTransaksi(token);
      final jenisMap = {
        for (var j in jenisList) j['id'] as int: j['trx_name'] as String,
      };

      final transaksiList = await widget.apiService.getTransaksiTabungan(
        token,
        widget.anggota.id,
      );

      await _getSaldo(token);

      if (!mounted) return [];

      setState(() {
        _jenisTransaksiMap = jenisMap;
      });

      return transaksiList;
    } catch (e) {
      debugPrint('[ERROR] Gagal memuat data: $e');
      return [];
    }
  }

  Future<void> _getSaldo(String token) async {
    try {
      final saldo = await widget.apiService.getSaldoTabungan(
        token,
        widget.anggota.id,
      );
      if (!mounted) return;
      setState(() {
        _saldo = saldo.toDouble();
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal memuat saldo: $e')));
    }
  }

  Future<void> _refreshData() async {
    final transaksiList = await _loadData();
    if (!mounted) return;
    setState(() {
      _transaksiFuture = Future.value(transaksiList);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.brown[50],
      appBar: AppBar(
        title: Text('Tabungan ${widget.anggota.nama}'),
        backgroundColor: Colors.brown[200],
      ),
      body: FutureBuilder<List<TransaksiTabungan>>(
        future: _transaksiFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Terjadi kesalahan: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text(
                'Belum ada transaksi.',
                style: TextStyle(color: Colors.brown[400]),
              ),
            );
          } else {
            final transaksi = snapshot.data!;
            return RefreshIndicator(
              onRefresh: _refreshData,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'Saldo: Rp ${_saldo.toStringAsFixed(0)}',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.brown[800],
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: transaksi.length,
                      itemBuilder: (context, index) {
                        final t = transaksi[index];
                        final date =
                            DateTime.tryParse(t.trxTanggal ?? '') ??
                            DateTime.now();

                        final jenisName =
                            _jenisTransaksiMap[t.trxId] ??
                            'Jenis Tidak Diketahui';

                        IconData iconData;
                        Color iconColor;
                        Color textColor;

                        switch (jenisName.toLowerCase()) {
                          case 'saldo awal':
                            iconData = Icons.flag;
                            iconColor = Colors.blue;
                            textColor = Colors.blue[800]!;
                            break;
                          case 'simpanan':
                            iconData = Icons.arrow_downward;
                            iconColor = Colors.green;
                            textColor = Colors.green[800]!;
                            break;
                          case 'penarikan':
                            iconData = Icons.arrow_upward;
                            iconColor = Colors.red;
                            textColor = Colors.red[800]!;
                            break;
                          case 'bunga simpanan':
                            iconData = Icons.percent;
                            iconColor = Colors.purple;
                            textColor = Colors.purple[800]!;
                            break;
                          case 'koreksi penambahan':
                            iconData = Icons.add_circle_outline;
                            iconColor = Colors.amber;
                            textColor = Colors.amber[800]!;
                            break;
                          case 'koreksi pengurangan':
                            iconData = Icons.remove_circle_outline;
                            iconColor = Colors.orange;
                            textColor = Colors.orange[800]!;
                            break;
                          default:
                            iconData = Icons.account_balance_wallet;
                            iconColor = Colors.grey;
                            textColor = Colors.grey[700]!;
                            break;
                        }

                        return Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            leading: Icon(iconData, color: iconColor),
                            title: Text(
                              '$jenisName: Rp ${t.trxNominal}',
                              style: TextStyle(
                                color: textColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: Text(
                              'Tanggal: ${DateFormat('yyyy-MM-dd').format(date)}',
                              style: TextStyle(color: Colors.brown[600]),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.brown[200],
        child: const Icon(Icons.add, color: Colors.brown),
        onPressed: () async {
          final token = await _storage.read(key: 'token');
          if (token == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Token tidak ditemukan, silakan login ulang'),
                backgroundColor: Colors.red,
              ),
            );
            return;
          }

          final result = await Navigator.push<bool>(
            context,
            MaterialPageRoute(
              builder:
                  (_) => AddTransaksiPage(
                    apiService: widget.apiService,
                    anggotaId: widget.anggota.id,
                  ),
            ),
          );

          if (result == true) {
            await _refreshData();
          }
        },
      ),
    );
  }
}
