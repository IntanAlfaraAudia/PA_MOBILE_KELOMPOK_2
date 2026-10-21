// Mengimpor Firebase Authentication untuk login dan registrasi pengguna.
import 'package:firebase_auth/firebase_auth.dart';

// Mengimpor widget Flutter untuk membuat tampilan aplikasi.
import 'package:flutter/material.dart';

// Membuat halaman LoginPage dengan fitur perubahan state.
class LoginPage extends StatefulWidget {
  // Konstruktor halaman LoginPage.
  const LoginPage({super.key});

  @override
  // Membuat state untuk mengelola tampilan dan proses login.
  State<LoginPage> createState() => _LoginPageState();
}

// Mengelola data dan interaksi pada halaman login.
class _LoginPageState extends State<LoginPage> {
  // Mengontrol input email pengguna.
  final TextEditingController emailController = TextEditingController();

  // Mengontrol input password pengguna.
  final TextEditingController passwordController = TextEditingController();

  // Menentukan apakah halaman berada dalam mode login atau registrasi.
  bool isLoginMode = true;

  // Menandakan apakah proses login atau registrasi sedang berlangsung.
  bool isLoading = false;

  // Menjalankan proses login atau registrasi menggunakan Firebase.
  Future<void> submit() async {
    // Mengaktifkan indikator loading.
    setState(() => isLoading = true);

    try {
      // Memeriksa apakah pengguna memilih mode login.
      if (isLoginMode) {
        // Login menggunakan email dan password yang dimasukkan.
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
        );
      } else {
        // Membuat akun baru menggunakan email dan password.
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
        );
      }

      // AuthGate dapat mendeteksi perubahan status autentikasi
      // dan mengarahkan pengguna ke halaman yang sesuai.
    } on FirebaseAuthException catch (e) {
      // Menampilkan pesan jika terjadi kesalahan autentikasi.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          // Menampilkan pesan error dari Firebase.
          content: Text(e.message ?? 'Terjadi kesalahan'),

          // Memberikan warna merah pada pesan error.
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      // Menghentikan indikator loading setelah proses selesai.
      setState(() => isLoading = false);
    }
  }

  @override
  void dispose() {
    // Membersihkan controller saat halaman ditutup.
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  // Membangun tampilan halaman login dan registrasi.
  Widget build(BuildContext context) {
    return Scaffold(
      // Menjaga konten agar tidak tertutup area sistem.
      body: SafeArea(
        // Menempatkan konten di tengah layar.
        child: Center(
          // Memungkinkan halaman digulir pada layar kecil.
          child: SingleChildScrollView(
            // Memberikan jarak di sekeliling konten.
            padding: const EdgeInsets.all(24.0),

            // Menyusun seluruh elemen secara vertikal.
            child: Column(
              // Memusatkan elemen pada sumbu utama.
              mainAxisAlignment: MainAxisAlignment.center,

              // Daftar widget yang ditampilkan pada halaman.
              children: [
                // Menampilkan nama aplikasi Wonka.
                const Text(
                  'Wonka',
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFFFD700),
                    fontStyle: FontStyle.italic,
                  ),
                ),

                // Memberikan jarak setelah judul.
                const SizedBox(height: 8),

                // Menampilkan slogan halaman login.
                const Text(
                  'PINTU GERBANG PABRIK',
                  style: TextStyle(
                    fontSize: 14,
                    letterSpacing: 2,
                    color: Colors.white70,
                  ),
                ),

                // Memberikan jarak sebelum formulir.
                const SizedBox(height: 48),

                // Form untuk memasukkan email pengguna.
                TextFormField(
                  // Menghubungkan input dengan pengontrol email.
                  controller: emailController,

                  // Mengatur warna teks email.
                  style: const TextStyle(color: Colors.white),

                  // Mengatur label dan tampilan kolom email.
                  decoration: InputDecoration(
                    labelText: 'Email',
                    labelStyle: const TextStyle(color: Colors.white54),
                    filled: true,
                    fillColor: Colors.white.withValues(alpha: 0.1),
                    border: OutlineInputBorder(
                      // Membuat sudut kolom membulat.
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),

                // Memberikan jarak antara kolom email dan password.
                const SizedBox(height: 16),

                // Form untuk memasukkan password pengguna.
                TextFormField(
                  // Menghubungkan input dengan pengontrol password.
                  controller: passwordController,

                  // Menyembunyikan karakter password.
                  obscureText: true,

                  // Mengatur warna teks password.
                  style: const TextStyle(color: Colors.white),

                  // Mengatur label dan tampilan kolom password.
                  decoration: InputDecoration(
                    labelText: 'Password',
                    labelStyle: const TextStyle(color: Colors.white54),
                    filled: true,
                    fillColor: Colors.white.withValues(alpha: 0.1),
                    border: OutlineInputBorder(
                      // Membuat sudut kolom membulat.
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),

                // Memberikan jarak sebelum tombol utama.
                const SizedBox(height: 32),

                // Mengatur ukuran tombol submit.
                SizedBox(
                  width: double.infinity,
                  height: 50,

                  // Tombol untuk menjalankan login atau registrasi.
                  child: ElevatedButton(
                    // Menonaktifkan tombol ketika proses sedang berjalan.
                    onPressed: isLoading ? null : submit,

                    // Mengatur warna dan bentuk tombol.
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFD700),
                      foregroundColor: const Color(0xFF2B0A42),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),

                    // Menampilkan loading atau teks tombol.
                    child: isLoading
                        // Menampilkan indikator ketika proses berlangsung.
                        ? const CircularProgressIndicator(
                            color: Color(0xFF2B0A42),
                          )
                        // Mengubah teks tombol sesuai mode yang dipilih.
                        : Text(
                            isLoginMode
                                ? 'MASUK PABRIK'
                                : 'DAFTAR TIKET EMAS',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                  ),
                ),

                // Memberikan jarak sebelum tombol pergantian mode.
                const SizedBox(height: 16),

                // Tombol untuk berpindah antara login dan registrasi.
                TextButton(
                  // Mengubah mode saat tombol ditekan.
                  onPressed: () => setState(
                    () => isLoginMode = !isLoginMode,
                  ),

                  // Menampilkan teks sesuai mode aktif.
                  child: Text(
                    isLoginMode
                        ? 'Belum punya tiket? Daftar di sini'
                        : 'Sudah punya tiket? Masuk di sini',
                    style: const TextStyle(
                      color: Color(0xFFFFD700),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}