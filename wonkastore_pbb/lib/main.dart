import 'package:flutter/material.dart'; // Widget Flutter
import 'package:firebase_core/firebase_core.dart'; // Inisialisasi Firebase
import 'package:provider/provider.dart'; // State management
import 'firebase_options.dart'; // Konfigurasi Firebase
import 'auth_gate.dart'; // Halaman pengecekan login
import 'providers/cart_provider.dart'; // Provider keranjang

// Fungsi utama aplikasi
void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Persiapan Flutter

  // Menghubungkan aplikasi ke Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Menyediakan Provider ke seluruh aplikasi
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => CartProvider(), // Mengelola keranjang
        ),
      ],
      child: const WonkaStoreApp(), // Menjalankan aplikasi
    ),
  );
}

// Widget utama WonkaStore
class WonkaStoreApp extends StatelessWidget {
  const WonkaStoreApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WonkaStore PA', // Nama aplikasi
      debugShowCheckedModeBanner: false, // Menyembunyikan banner debug

      // Mengatur tema aplikasi
      theme: ThemeData(
        fontFamily: 'Inter', // Jenis huruf
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2B0A42), // Warna utama
        ),
        scaffoldBackgroundColor: const Color(0xFF2B0A42), // Warna latar
      ),

      home: const AuthGate(), // Menentukan halaman awal
    );
  }
}