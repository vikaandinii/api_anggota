import 'package:flutter/material.dart';
import '/models/anggota.dart';
import '/api_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class EditAnggotaPage extends StatefulWidget {
  final ApiService apiService;
  final Anggota anggota;

  const EditAnggotaPage({
    Key? key,
    required this.apiService,
    required this.anggota,
  }) : super(key: key);

  @override
  _EditAnggotaPageState createState() => _EditAnggotaPageState();
}

class _EditAnggotaPageState extends State<EditAnggotaPage> {
  late TextEditingController _nomorIndukController;
  late TextEditingController _namaController;
  late TextEditingController _alamatController;
  late TextEditingController _tglLahirController;
  late TextEditingController _teleponController;

  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _nomorIndukController = TextEditingController(
      text: widget.anggota.nomorInduk,
    );
    _namaController = TextEditingController(text: widget.anggota.nama);
    _alamatController = TextEditingController(text: widget.anggota.alamat);
    _tglLahirController = TextEditingController(text: widget.anggota.tglLahir);
    _teleponController = TextEditingController(text: widget.anggota.telepon);

    try {
      _selectedDate = DateTime.parse(widget.anggota.tglLahir);
    } catch (_) {}
  }

  @override
  void dispose() {
    _nomorIndukController.dispose();
    _namaController.dispose();
    _alamatController.dispose();
    _tglLahirController.dispose();
    _teleponController.dispose();
    super.dispose();
  }

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

  void _updateAnggota() async {
    final updatedAnggota = Anggota(
      id: widget.anggota.id,
      nomorInduk: _nomorIndukController.text,
      nama: _namaController.text,
      alamat: _alamatController.text,
      tglLahir: _tglLahirController.text,
      telepon: _teleponController.text,
    );

    try {
      final storage = FlutterSecureStorage();
      final token = await storage.read(key: 'token');

      if (token != null) {
        final response = await widget.apiService.updateAnggota(
          token,
          updatedAnggota.id,
          updatedAnggota.toJson(),
        );

        final status = response['status']?.toString().toLowerCase();
        final message = response['message']?.toString().toLowerCase();

        if (status == 'success' ||
            (message != null && message.contains('sukses'))) {
          Navigator.pop(context);
        } else {
          _showErrorDialog(
            'Gagal mengupdate anggota. Pesan dari server: ${response['message']}',
          );
        }
      } else {
        _showErrorDialog('Token hilang');
      }
    } catch (e) {
      _showErrorDialog('Terjadi kesalahan: $e');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              child: const Text('OK'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Anggota'),
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
              onTap: _updateAnggota,
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
                    'Update Anggota',
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
}
