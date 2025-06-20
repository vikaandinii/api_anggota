import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'pages/login_page.dart';
import 'pages/home_page.dart';
import 'api_service.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final ApiService _apiService = ApiService();
  final FlutterSecureStorage _storage = FlutterSecureStorage();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aplikasi Manajemen Anggota',
      debugShowCheckedModeBanner: false,
      routes: {
        '/login': (context) => LoginPage(),
        '/home': (context) => HomePage(apiService: _apiService),
      },
      home: FutureBuilder<bool>(
        future: _checkLoginStatus(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          } else if (snapshot.hasData && snapshot.data == true) {
            print('Token ditemukan, langsung ke HomePage');
            return HomePage(apiService: _apiService);
          } else {
            print('Token tidak ada, ke LoginPage');
            return LoginPage();
          }
        },
      ),
    );
  }

  Future<bool> _checkLoginStatus() async {
    final token = await _storage.read(key: 'token');
    print('Token dari secure storage: $token');
    return token != null;
  }
}
