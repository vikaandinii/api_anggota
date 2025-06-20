import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '/api_service.dart';

class AddTransaksiPage extends StatefulWidget {
  final ApiService apiService;
  final int anggotaId;

  const AddTransaksiPage({
    Key? key,
    required this.apiService,
    required this.anggotaId,
  }) : super(key: key);

  @override
  _AddTransaksiPageState createState() => _AddTransaksiPageState();
}

class _AddTransaksiPageState extends State<AddTransaksiPage> {
  final _formKey = GlobalKey<FormState>();
  final _tanggalController = TextEditingController();
  final _nominalController = TextEditingController();
  final _storage = const FlutterSecureStorage();

  List<dynamic> _jenisTransaksi = [];
  dynamic _selectedJenisTransaksi;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tanggalController.text = DateTime.now().toIso8601String().split('T').first;
    _loadJenisTransaksi();
  }

  Future<void> _loadJenisTransaksi() async {
    final token = await _storage.read(key: 'token');
    if (token == null) {
      _showMessage('Token tidak ditemukan, silakan login ulang');
      return;
    }
    try {
      final list = await widget.apiService.getJenisTransaksi(token);
      setState(() {
        _jenisTransaksi = list;
        if (list.isNotEmpty) _selectedJenisTransaksi = list[0];
      });
    } catch (e) {
      _showMessage('Gagal ambil jenis transaksi: $e');
    }
  }

  void _showMessage(String msg) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final token = await _storage.read(key: 'token');
    if (token == null) {
      _showMessage('Token tidak ditemukan, silakan login ulang');
      return;
    }

    if (_selectedJenisTransaksi == null) {
      _showMessage('Pilih jenis transaksi');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final nominal = int.parse(_nominalController.text);
      if (nominal <= 0) throw Exception('Nominal harus > 0');

      final data = {
        'anggota_id': widget.anggotaId.toString(),
        'trx_tanggal': _tanggalController.text,
        'trx_id': _selectedJenisTransaksi['id'].toString(),
        'trx_nominal': nominal.toString(),
      };

      await widget.apiService.tambahTransaksiTabungan(token, data);

      if (!mounted) return;
      _showMessage('Transaksi berhasil disimpan');
      Navigator.pop(context, true);
    } catch (e) {
      _showMessage('Gagal simpan transaksi: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _tanggalController.dispose();
    _nominalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Transaksi Tabungan'),
        backgroundColor: Colors.brown[200],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Form(
                key: _formKey,
                child: ListView(
                  children: [
                    TextFormField(
                      controller: _tanggalController,
                      readOnly: true,
                      enabled: false, // Supaya tidak bisa diubah
                      decoration: InputDecoration(
                        labelText: 'Tanggal Transaksi',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.grey[200], // Visual bahwa non-editable
                      ),
                      validator: (val) =>
                          (val == null || val.isEmpty) ? 'Tanggal harus diisi' : null,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<dynamic>(
                      value: _selectedJenisTransaksi,
                      items: _jenisTransaksi.map((e) {
                        return DropdownMenuItem(
                          value: e,
                          child: Text(e['trx_name'] ?? 'Jenis tidak diketahui'),
                        );
                      }).toList(),
                      onChanged: (val) {
                        setState(() => _selectedJenisTransaksi = val);
                      },
                      decoration: InputDecoration(
                        labelText: 'Jenis Transaksi',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      validator: (val) =>
                          val == null ? 'Pilih jenis transaksi' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _nominalController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Nominal',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      validator: (val) {
                        if (val == null || val.isEmpty) {
                          return 'Nominal harus diisi';
                        }
                        final n = int.tryParse(val);
                        if (n == null || n <= 0) {
                          return 'Nominal harus angka > 0';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.brown[200],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: _submit,
                      child: const Text('Simpan'),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
