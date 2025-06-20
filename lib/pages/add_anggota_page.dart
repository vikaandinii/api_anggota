import 'package:flutter/material.dart';
import '/api_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AddAnggotaPage extends StatefulWidget {
  final ApiService apiService;

  const AddAnggotaPage({Key? key, required this.apiService}) : super(key: key);

  @override
  _AddAnggotaPageState createState() => _AddAnggotaPageState();
}

class _AddAnggotaPageState extends State<AddAnggotaPage> {
  final _nomorIndukController = TextEditingController();
  final _namaController = TextEditingController();
  final _alamatController = TextEditingController();
  final _tglLahirController = TextEditingController();
  final _teleponController = TextEditingController();

  DateTime? _selectedDate;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      helpText: 'Pilih Tanggal Lahir',
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _tglLahirController.text =
            "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }

  Future<void> _addAnggota() async {
    final storage = FlutterSecureStorage();
    final token = await storage.read(key: 'token');

    if (token != null &&
        _nomorIndukController.text.isNotEmpty &&
        _namaController.text.isNotEmpty) {
      final anggotaData = {
        'nomor_induk': _nomorIndukController.text,
        'nama': _namaController.text,
        'alamat': _alamatController.text,
        'tgl_lahir': _tglLahirController.text,
        'telepon': _teleponController.text,
      };

      try {
        await widget.apiService.addAnggota(token, anggotaData);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Anggota berhasil ditambahkan')));
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menambahkan anggota: $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Mohon isi minimal Nomor Induk dan Nama')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tambah Anggota'),
        backgroundColor: Colors.brown[200],
      ),
      backgroundColor: Colors.brown[50],
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildTextField(_nomorIndukController, 'Nomor Induk'),
            SizedBox(height: 12),
            _buildTextField(_namaController, 'Nama'),
            SizedBox(height: 12),
            _buildTextField(_alamatController, 'Alamat'),
            SizedBox(height: 12),
            GestureDetector(
              onTap: () => _selectDate(context),
              child: AbsorbPointer(
                child: TextField(
                  controller: _tglLahirController,
                  decoration: InputDecoration(
                    labelText: 'Tanggal Lahir',
                    hintText: 'YYYY-MM-DD',
                    labelStyle: TextStyle(color: Colors.brown[600]),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    suffixIcon: Icon(
                      Icons.calendar_today,
                      color: Colors.brown[300],
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 12),
            _buildTextField(_teleponController, 'Telepon', TextInputType.phone),
            SizedBox(height: 20),
            GestureDetector(
              onTap: _addAnggota,
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.brown[200],
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.brown.withOpacity(0.4),
                      offset: Offset(0, 4),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    'Tambah Anggota',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label, [
    TextInputType keyboardType = TextInputType.text,
  ]) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.brown[600]),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
