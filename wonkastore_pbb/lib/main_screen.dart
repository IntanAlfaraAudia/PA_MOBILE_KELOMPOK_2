// Mengimpor paket bawaan Flutter untuk komponen dan tata letak antarmuka Material Design.
import 'package:flutter/material.dart';
// Mengimpor halaman HomePage dari folder pages.
import 'pages/home_page.dart';
// Mengimpor halaman CartPage dari folder pages.
import 'pages/cart_page.dart';
// Mengimpor halaman ProfilePage dari folder pages.
import 'pages/profile_page.dart';
// Deklarasi StatefulWidget MainScreen sebagai wadah layar utama dengan navigasi bawah.
class MainScreen extends StatefulWidget {
  // Konstruktor untuk MainScreen dengan parameter key opsional.
  const MainScreen({super.key});
  // Membuat State untuk mengelola status interaktif pada MainScreen.
  @override
  State<MainScreen> createState() => _MainScreenState();
}
// Kelas State untuk mengelola status dan logika tampilan MainScreen.
class _MainScreenState extends State<MainScreen> {
  // Variabel penanda indeks menu navigasi yang sedang dipilih (dimulai dari indeks 0).
  int _selectedIndex = 0;

  // Daftar (List) widget halaman yang akan ditampilkan sesuai menu yang dipilih.
  final List<Widget> _pages = [
    // Halaman indeks 0: Beranda.
    const HomePage(),
    // Halaman indeks 1: Keranjang.
    const CartPage(),
    // Halaman indeks 2: Profil.
    const ProfilePage(),
  ];

  // Metode build untuk membangun struktur visual komponen MainScreen.
  @override
  Widget build(BuildContext context) {
    // Mengembalikan Scaffold sebagai struktur dasar halaman antarmuka.
    return Scaffold(
      // Menggunakan Stack untuk menumpuk elemen-elemen UI secara bertingkat (berlapis).
      body: Stack(
        // Daftar widget anak yang ditumpuk dari lapisan paling bawah ke paling atas.
        children: [
          // LAPISAN 1: Container warna dasar latar belakang aplikasi (Ungu Tua).
          Container(color: const Color(0xFF2B0A42)),

          // LAPISAN 2: Container dekorasi gambar latar belakang pola/pattern.
          Container(
            // Menambahkan dekorasi latar belakang berupa gambar.
            decoration: const BoxDecoration(
              // Menentukan gambar latar belakang yang diambil dari aset lokal.
              image: DecorationImage(
                // Menunjuk ke jalur aset file gambar pola latar belakang.
                image: AssetImage('assets/bg_wonka.png'),
                // Mengatur ukuran gambar agar memenuhi seluruh area container.
                fit: BoxFit.cover,
              ),
            ),
          ),

          // LAPISAN 4: Menempatkan gambar hiasan lelehan cokelat di bagian paling atas layar.
          Positioned(
            // Menempelkan posisi ke sisi atas layar.
            top: 0,
            // Menempelkan posisi ke sisi kiri layar.
            left: 0,
            // Menempelkan posisi ke sisi kanan layar.
            right: 0,
            // Mengabaikan deteksi sentuhan/klik agar tidak menghalangi tombol di bawahnya.
            child: IgnorePointer(
              // Menampilkan gambar dari folder aset lokal.
              child: Image.asset(
                // Jalur file aset hiasan lelehan cokelat.
                'assets/header_cokelat.png',
                // Mengatur lebar gambar agar pas menyesuaikan lebar layar.
                fit: BoxFit.fitWidth,
              ),
            ),
          ),

          // LAPISAN 3: Menampilkan halaman aktif berdasarkan indeks yang sedang dipilih.
          _pages[_selectedIndex],

        ],
      ),
      // Komponen bilah navigasi bawah (Bottom Navigation Bar).
      bottomNavigationBar: Container(
        // Menambahkan dekorasi batas garis (border) di sisi atas bilah navigasi.
        decoration: const BoxDecoration(
          // Mengatur garis batas atas dengan warna putih transparan.
          border: Border(top: BorderSide(color: Colors.white12, width: 1)),
        ),
        // Menggunakan komponen NavigationBar standar bawaan Material 3.
        child: NavigationBar(
          // Mengatur warna latar belakang bilah navigasi (Ungu Gelap).
          backgroundColor: const Color(0xFF1E0533),
          // Mengubah warna indikator seleksi menjadi transparan.
          indicatorColor: Colors.transparent,
          // Mengatur indeks item yang aktif saat ini dari variabel _selectedIndex.
          selectedIndex: _selectedIndex,
          // Fungsi callback ketika salah satu item menu navigasi diklik.
          onDestinationSelected: (index) => setState(() => _selectedIndex = index),
          // Daftar item tujuan navigasi bawah.
          destinations: [
            // Item navigasi 1: Beranda.
            NavigationDestination(
              // Menampilkan ikon beranda (berwarna emas jika aktif, putih transparan jika tidak).
              icon: Icon(Icons.home_outlined, color: _selectedIndex == 0 ? const Color(0xFFFFD700) : Colors.white54),
              // Teks label menu.
              label: 'Beranda',
            ),
            // Item navigasi 2: Keranjang.
            NavigationDestination(
              // Menampilkan ikon keranjang (berwarna emas jika aktif, putih transparan jika tidak).
              icon: Icon(Icons.shopping_cart_outlined, color: _selectedIndex == 1 ? const Color(0xFFFFD700) : Colors.white54),
              // Teks label menu.
              label: 'Keranjang',
            ),
            // Item navigasi 3: Profil.
            NavigationDestination(
              // Menampilkan ikon profil (berwarna emas jika aktif, putih transparan jika tidak).
              icon: Icon(Icons.person_outline, color: _selectedIndex == 2 ? const Color(0xFFFFD700) : Colors.white54),
              // Teks label menu.
              label: 'Profil',
            ),
          ],
        ),
      ),
    );
  }
}