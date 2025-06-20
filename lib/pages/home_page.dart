import 'package:flutter/material.dart';
import '/api_service.dart';
import 'add_anggota_page.dart';
import 'edit_anggota_page.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '/models/anggota.dart';
import 'tabungan_page.dart';

class HomePage extends StatefulWidget {
  final ApiService apiService;

  const HomePage({Key? key, required this.apiService}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List<Anggota>> _anggotaFuture;
  List<Anggota> _semuaAnggota = [];
  List<Anggota> _filteredAnggota = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _anggotaFuture = _getAnggota();
    _searchController.addListener(_filterAnggota);
  }

  Future<List<Anggota>> _getAnggota() async {
    final storage = FlutterSecureStorage();
    final token = await storage.read(key: 'token');
    if (token != null) {
      try {
        final data = await widget.apiService.getAnggota(token);
        setState(() {
          _semuaAnggota = data;
          _filteredAnggota = data;
        });
        return data;
      } catch (e) {
        throw Exception("Error fetching anggota: $e");
      }
    } else {
      throw Exception("Token is missing");
    }
  }

  void _filterAnggota() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredAnggota =
          _semuaAnggota
              .where((a) => a.nama.toLowerCase().contains(query))
              .toList();
    });
  }

  void _refreshData() {
    setState(() {
      _anggotaFuture = _getAnggota();
    });
  }

  void _logout() async {
    final storage = FlutterSecureStorage();
    final token = await storage.read(key: 'token');
    if (token != null) {
      try {
        await widget.apiService.logout(token);
        await storage.delete(key: 'token');
        if (!mounted) return;
        Navigator.pushReplacementNamed(context, '/login');
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal logout: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.brown[50],
      appBar: AppBar(
        title: const Text('Data Anggota'),
        backgroundColor: Colors.brown[200],
        actions: [
          IconButton(icon: const Icon(Icons.logout), onPressed: _logout),
        ],
      ),
      body: FutureBuilder<List<Anggota>>(
        future: _anggotaFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Terjadi kesalahan: ${snapshot.error}'));
          } else {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Cari nama anggota...',
                      prefixIcon: Icon(Icons.search),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: EdgeInsets.symmetric(vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child:
                      _filteredAnggota.isEmpty
                          ? const Center(
                            child: Text('Data anggota tidak ditemukan'),
                          )
                          : ListView.builder(
                            itemCount: _filteredAnggota.length,
                            itemBuilder: (context, index) {
                              final anggota = _filteredAnggota[index];
                              return Card(
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                elevation: 2,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        anggota.nama,
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.brown[800],
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        "Nomor Induk: ${anggota.nomorInduk}",
                                      ),
                                      Text(
                                        "Tanggal Lahir: ${anggota.tglLahir}",
                                      ),
                                      Text("Alamat: ${anggota.alamat}"),
                                      Text("Telepon: ${anggota.telepon}"),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          IconButton(
                                            icon: Icon(
                                              Icons.edit,
                                              color: Colors.brown[400],
                                            ),
                                            onPressed: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder:
                                                      (context) =>
                                                          EditAnggotaPage(
                                                            apiService:
                                                                widget
                                                                    .apiService,
                                                            anggota: anggota,
                                                          ),
                                                ),
                                              ).then((_) => _refreshData());
                                            },
                                          ),
                                          IconButton(
                                            icon: const Icon(
                                              Icons.delete,
                                              color: Colors.red,
                                            ),
                                            onPressed: () async {
                                              final storage =
                                                  FlutterSecureStorage();
                                              final token = await storage.read(
                                                key: 'token',
                                              );
                                              if (token != null) {
                                                await widget.apiService
                                                    .deleteAnggota(
                                                      token,
                                                      anggota.id,
                                                    );
                                                _refreshData();
                                              }
                                            },
                                          ),

                                          IconButton(
                                            icon: Icon(
                                              Icons.account_balance_wallet,
                                              color: Colors.green,
                                            ),
                                            onPressed: () async {
                                              final storage =
                                                  FlutterSecureStorage();
                                              final token = await storage.read(
                                                key: 'token',
                                              );
                                              if (token != null) {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder:
                                                        (_) => TabunganPage(
                                                          apiService:
                                                              widget.apiService,
                                                          anggota: anggota,
                                                        ),
                                                  ),
                                                );
                                              }
                                            },
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                ),
              ],
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.brown[200],
        child: const Icon(Icons.add),
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddAnggotaPage(apiService: widget.apiService),
            ),
          );
          _refreshData();
        },
      ),
    );
  }
}
