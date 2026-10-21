import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'login_page.dart';
import 'main_screen.dart'; // Wajib diimpor agar bisa memanggil MainScreen

// Deklarasi kelas AuthGate sebagai StatelessWidget pengatur alur autentikasi (router gate).
class AuthGate extends StatelessWidget {
  // Konstruktor untuk AuthGate dengan opsional parameter key.
  const AuthGate({super.key});

  // Metode build untuk membangun struktur tampilan berdasarkan status autentikasi.
  @override
  Widget build(BuildContext context) {
    // Menggunakan StreamBuilder untuk mendengarkan perubahan status login (auth state) secara real-time.
    return StreamBuilder<User?>(
      // Menghubungkan stream dari Firebase Auth instance authStateChanges.
      stream: FirebaseAuth.instance.authStateChanges(),
      // Fungsi pembangun UI berdasarkan snapshot data status autentikasi.
      builder: (context, snapshot) {
        // Jika status sedang memuat saat mengecek sesi ke server.
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Mengembalikan Scaffold dengan tampilan latar belakang ungu tua.
          return const Scaffold(
            backgroundColor: Color(0xFF2B0A42),
            // Menampilkan indikator loading melingkar berwarna emas di tengah layar.
            body: Center(
              child: CircularProgressIndicator(color: Color(0xFFFFD700)),
            ),
          );
        }

        // Jika user belum login / tidak ada sesi data pengguna.
        if (!snapshot.hasData) {
          // Mengarahkan tampilan ke halaman login (LoginPage).
          return const LoginPage();
        }

        // JIKA USER SUDAH LOGIN: Arahkan langsung ke MainScreen (halaman utama aplikasi).
        return const MainScreen();
      },
    );
  }
}
