// Mengimpor paket bawaan Flutter untuk desain antarmuka Material Design.
import 'package:flutter/material.dart';
// Mengimpor paket Firebase Auth untuk manajemen otentikasi dan sesi pengguna.
import 'package:firebase_auth/firebase_auth.dart';
// Mengimpor paket Cloud Firestore untuk interaksi dengan database Firestore.
import 'package:cloud_firestore/cloud_firestore.dart';
// Mendefinisikan konstanta warna emas (wonkaGold) dengan kode Hex 0xFFFFD700.
const Color wonkaGold = Color(0xFFFFD700);
// Mendefinisikan konstanta warna cokelat (wonkaBrown) dengan kode Hex 0xFF3E2723.
const Color wonkaBrown = Color(0xFF3E2723);
// Mendefinisikan konstanta warna krem (wonkaCream) dengan kode Hex 0xFFFFF8E7.
const Color wonkaCream = Color(0xFFFFF8E7);

// =======================================================
// HALAMAN PROFIL
// =======================================================

// Declaring class ProfilePage yang merupakan StatelessWidget untuk tampilan profil.
class ProfilePage extends StatelessWidget {
  // Konstruktor untuk ProfilePage dengan opsional key parameter.
  const ProfilePage({super.key});

  // Getter untuk mengambil UID dari pengguna yang saat ini sedang login.
  String get userId => FirebaseAuth.instance.currentUser!.uid;

  // Getter query untuk mengambil dokumen pesanan dari koleksi 'orders' berdasarkan userId.
  Query<Map<String, dynamic>> get userOrders =>
      // Mengakses instance Firestore.
  FirebaseFirestore.instance
  // Mengakses koleksi 'orders'.
      .collection('orders')
  // Menyaring dokumen di mana field 'userId' sama dengan UID pengguna.
      .where('userId', isEqualTo: userId);

  // Getter koleksi untuk mengakses sub-koleksi 'favorites' di dalam dokumen pengguna.
  CollectionReference<Map<String, dynamic>> get userFavorites =>
      // Mengakses instance Firestore.
  FirebaseFirestore.instance
  // Mengakses koleksi 'users'.
      .collection('users')
  // Mengambil dokumen spesifik berdasarkan userId.
      .doc(userId)
  // Mengakses sub-koleksi 'favorites' dari dokumen user tersebut.
      .collection('favorites');

  // Metode build untuk membangun struktur UI halaman profil.
  @override
  Widget build(BuildContext context) {
    // Mengambil objek User dari FirebaseAuth untuk mengecek status login.
    final user = FirebaseAuth.instance.currentUser;

    // Pengecekan kondisi jika pengguna belum terotentikasi (null).
    if (user == null) {
      // Mengembalikan widget Center jika pengguna belum login.
      return const Center(
        // Menampilkan teks pemberitahuan login.
        child: Text('Silakan login terlebih dahulu'),
      );
    }

    // Mendapatkan referensi dokumen pengguna dari koleksi 'users' Firestore.
    final userDoc = FirebaseFirestore.instance
    // Menunjuk ke koleksi 'users'.
        .collection('users')
    // Menunjuk ke dokumen dengan ID pengguna saat ini.
        .doc(user.uid);

    // Mengembalikan SafeArea untuk memastikan UI tidak tertutup notch atau bar status.
    return SafeArea(
      // Menggunakan StreamBuilder untuk mendengarkan perubahan dokumen profil secara real-time.
      child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        // Menghubungkan aliran data dari snapshot dokumen pengguna.
        stream: userDoc.snapshots(),
        // Fungsi pembangun UI berdasarkan snapshot data pengguna.
        builder: (context, userSnapshot) {
          // Mengambil data map dari snapshot, atau map kosong jika null.
          final data = userSnapshot.data?.data() ?? {};

          // Mengambil nilai 'name' dari Firestore, dikonversi ke String dan dihapus spasi di ujungnya.
          final storedName = data['name']?.toString().trim() ?? '';
          // Mengambil nilai displayName dari FirebaseAuth dan menghapus spasi di ujungnya.
          final displayName = user.displayName?.trim() ?? '';

          // Menentukan nama tampilan akhir berdasarkan prioritas ketersediaan data.
          final name = storedName.isNotEmpty
              ? storedName
              : displayName.isNotEmpty
              ? displayName
              : 'Pengguna WonkaStore';

          // Mengembalikan layar yang dapat digulir jika konten melebihi tinggi layar.
          return SingleChildScrollView(
            // Memberikan jarak dalam (padding) simetris pada area gulir.
            padding: const EdgeInsets.symmetric(
              // Jarak horizontal sebesar 24 piksel.
              horizontal: 24,
              // Jarak vertikal sebesar 32 piksel.
              vertical: 32,
            ),
            // Mengatur tata letak elemen secara vertikal.
            child: Column(
              // Daftar widget anak yang ada di dalam kolom.
              children: [
                // Container luar untuk lingkaran bingkai foto profil.
                Container(
                  // Jarak dalam sebesar 4 piksel untuk memberi efek batas bingkai.
                  padding: const EdgeInsets.all(4),
                  // Mengatur dekorasi bentuk dan batas lingkaran.
                  decoration: BoxDecoration(
                    // Mengubah bentuk dekorasi menjadi lingkaran.
                    shape: BoxShape.circle,
                    // Menambahkan garis batas (border) melingkar.
                    border: Border.all(
                      // Menggunakan warna emas wonkaGold.
                      color: wonkaGold,
                      // Ketebalan garis batas sebesar 2 piksel.
                      width: 2,
                    ),
                  ),
                  // Widget lingkaran avatar pengguna.
                  child: const CircleAvatar(
                    // Radius lingkaran sebesar 40 piksel.
                    radius: 40,
                    // Warna latar belakang lingkaran menggunakan wonkaBrown.
                    backgroundColor: wonkaBrown,
                    // Widget icon di dalam avatar.
                    child: Icon(
                      // Menggunakan icon profil bawaan.
                      Icons.person_outline,
                      // Ukuran icon sebesar 40 piksel.
                      size: 40,
                      // Warna icon putih.
                      color: Colors.white,
                    ),
                  ),
                ),

                // Memberi jarak vertikal sebesar 16 piksel.
                const SizedBox(height: 16),

                // Widget teks untuk menampilkan nama pengguna.
                Text(
                  // Menampilkan variabel name yang sudah ditentukan.
                  name,
                  // Mengatur posisi teks agar di tengah.
                  textAlign: TextAlign.center,
                  // Mengatur gaya penulisan teks.
                  style: const TextStyle(
                    // Ukuran font 22 piksel.
                    fontSize: 22,
                    // Ketebalan font tebal (bold).
                    fontWeight: FontWeight.bold,
                    // Warna font emas.
                    color: wonkaGold,
                    // Jenis font Serif.
                    fontFamily: 'Serif',
                  ),
                ),

                // Memberi jarak vertikal sebesar 4 piksel.
                const SizedBox(height: 4),

                // Widget teks untuk menampilkan email pengguna.
                Text(
                  // Menampilkan email pengguna atau teks fallback jika null.
                  user.email ?? 'Email tidak tersedia',
                  // Gaya penulisan teks email.
                  style: const TextStyle(
                    // Ukuran font 14 piksel.
                    fontSize: 14,
                    // Warna font putih transparan 70%.
                    color: Colors.white70,
                  ),
                ),

                // Memberi jarak vertikal sebesar 24 piksel.
                const SizedBox(height: 24),

                // StreamBuilder untuk mengambil jumlah pesanan secara real-time.
                StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  // Menggunakan stream dari userOrders.
                  stream: userOrders.snapshots(),
                  // Fungsi pembangun UI untuk statistik pesanan.
                  builder: (context, orderSnapshot) {
                    // Menghitung jumlah dokumen pesanan, default 0 jika null.
                    final orderCount =
                        orderSnapshot.data?.docs.length ?? 0;

                    // StreamBuilder bertingkat untuk mengambil jumlah favorit secara real-time.
                    return StreamBuilder<
                        QuerySnapshot<Map<String, dynamic>>>(
                      // Menggunakan stream dari userFavorites.
                      stream: userFavorites.snapshots(),
                      // Fungsi pembangun UI untuk statistik favorit dan poin.
                      builder: (context, favoriteSnapshot) {
                        // Menghitung jumlah dokumen favorit, default 0 jika null.
                        final favoriteCount =
                            favoriteSnapshot.data?.docs.length ?? 0;

                        // Konversi data poin ke integer secara aman dari Firestore.
                        final points = data['points'] is num
                            ? (data['points'] as num).toInt()
                            : 0;

                        // Container untuk membungkus kotak statistik.
                        return Container(
                          // Padding vertikal sebesar 16 piksel.
                          padding: const EdgeInsets.symmetric(
                            vertical: 16,
                          ),
                          // Mengatur tampilan visual kotak statistik.
                          decoration: BoxDecoration(
                            // Warna latar belakang menggunakan wonkaCream.
                            color: wonkaCream,
                            // Lengkungan sudut kotak sebesar 16 piksel.
                            borderRadius: BorderRadius.circular(16),
                          ),
                          // Menyusun statistik secara horizontal.
                          child: Row(
                            // Mengatur jarak antar elemen rata di seluruh baris.
                            mainAxisAlignment:
                            MainAxisAlignment.spaceEvenly,
                            // Elemen-elemen statistik.
                            children: [
                              // Memanggil helper _buildStatItem untuk pesanan.
                              _buildStatItem(
                                '$orderCount',
                                'Pesanan',
                              ),
                              // Memanggil helper _buildStatItem untuk favorit.
                              _buildStatItem(
                                '$favoriteCount',
                                'Favorit',
                              ),
                              // Memanggil helper _buildStatItem untuk poin.
                              _buildStatItem(
                                '$points',
                                'Poin',
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),

                // Memberi jarak vertikal sebesar 32 piksel.
                const SizedBox(height: 32),

                // Menampilkan item menu 'Pesanan Saya'.
                _buildMenuItem(
                  // Mempassing context.
                  context,
                  // Icon kotak inventaris.
                  Icons.inventory_2_outlined,
                  // Judul menu.
                  'Pesanan Saya',
                  // Fungsi aksi ketika menu ditekan.
                      () {
                    // Navigasi pindah ke halaman MyOrdersPage.
                    Navigator.push(
                      context,
                      // Membuat rute transisi material.
                      MaterialPageRoute(
                        // Mengarahkan ke widget MyOrdersPage.
                        builder: (_) => const MyOrdersPage(),
                      ),
                    );
                  },
                ),

                // Menampilkan item menu 'Cokelat Favorit'.
                _buildMenuItem(
                  // Mempassing context.
                  context,
                  // Icon hati/favorit.
                  Icons.favorite_border,
                  // Judul menu.
                  'Cokelat Favorit',
                  // Fungsi aksi ketika menu ditekan.
                      () {
                    // Navigasi pindah ke halaman FavoriteChocolatesPage.
                    Navigator.push(
                      context,
                      // Membuat rute transisi material.
                      MaterialPageRoute(
                        // Mengarahkan ke widget FavoriteChocolatesPage.
                        builder: (_) =>
                        const FavoriteChocolatesPage(),
                      ),
                    );
                  },
                ),

                // Menampilkan item menu 'Bantuan'.
                _buildMenuItem(
                  // Mempassing context.
                  context,
                  // Icon tanda tanya/bantuan.
                  Icons.help_outline,
                  // Judul menu.
                  'Bantuan',
                  // Fungsi aksi ketika menu ditekan.
                      () {
                    // Navigasi pindah ke halaman WonkaHelpPage.
                    Navigator.push(
                      context,
                      // Membuat rute transisi material.
                      MaterialPageRoute(
                        // Mengarahkan ke widget WonkaHelpPage.
                        builder: (_) => const WonkaHelpPage(),
                      ),
                    );
                  },
                ),

                // Memberi jarak vertikal sebesar 32 piksel.
                const SizedBox(height: 32),

                // Membungkus tombol keluar dengan SizedBox untuk mengatur ukuran.
                SizedBox(
                  // Mengatur lebar tombol memenuhi layar secara penuh.
                  width: double.infinity,
                  // Mengatur tinggi tombol sebesar 50 piksel.
                  height: 50,
                  // Menggunakan OutlinedButton dengan garis tepi.
                  child: OutlinedButton(
                    // Fungsi asinkronus yang dipanggil saat tombol ditekan.
                    onPressed: () async {
                      // Menjalankan proses sign out pengguna dari Firebase Auth.
                      await FirebaseAuth.instance.signOut();
                    },
                    // Kustomisasi gaya tombol OutlinedButton.
                    style: OutlinedButton.styleFrom(
                      // Mengatur warna garis tepi menjadi emas (wonkaGold).
                      side: const BorderSide(color: wonkaGold),
                      // Mengatur sudut tombol menjadi oval/rounded.
                      shape: RoundedRectangleBorder(
                        // Radius kelengkungan sudut 25 piksel.
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    // Teks di dalam tombol keluar.
                    child: const Text(
                      'Keluar',
                      // Gaya penulisan teks tombol.
                      style: TextStyle(
                        // Warna teks emas.
                        color: wonkaGold,
                        // Ukuran teks 16 piksel.
                        fontSize: 16,
                        // Ketebalan teks bold.
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // Fungsi helper privat untuk membangun item statistik secara seragam.
  Widget _buildStatItem(String value, String label) {
    // Menyusun angka statistik dan label secara vertikal.
    return Column(
      // Anak-anak widget dalam kolom.
      children: [
        // Menampilkan nilai angka statistik.
        Text(
          value,
          // Gaya penulisan nilai angka.
          style: const TextStyle(
            // Ukuran angka 20 piksel.
            fontSize: 20,
            // Cetak tebal.
            fontWeight: FontWeight.bold,
            // Warna cokelat wonkaBrown.
            color: wonkaBrown,
            // Jenis font Serif.
            fontFamily: 'Serif',
          ),
        ),
        // Memberi jarak vertikal 4 piksel antara angka dan label.
        const SizedBox(height: 4),
        // Menampilkan label deskripsi statistik.
        Text(
          label,
          // Gaya penulisan label deskripsi.
          style: const TextStyle(
            // Ukuran teks label 12 piksel.
            fontSize: 12,
            // Warna teks cokelat tua.
            color: Color(0xFF5D4037),
          ),
        ),
      ],
    );
  }

  // Fungsi helper privat untuk membangun daftar baris menu navigasi.
  Widget _buildMenuItem(
      BuildContext context,
      IconData icon,
      String title,
      VoidCallback onTap,
      ) {
    // Menggunakan ListTile untuk susunan menu standar bawaan Flutter.
    return ListTile(
      // Menghilangkan padding bawaan pada konten ListTile.
      contentPadding: EdgeInsets.zero,
      // Icon di sebelah kiri teks menu.
      leading: Icon(icon, color: wonkaGold),
      // Teks judul menu.
      title: Text(
        title,
        // Gaya teks judul menu.
        style: const TextStyle(
          // Warna teks putih.
          color: Colors.white,
          // Ukuran font 16 piksel.
          fontSize: 16,
        ),
      ),
      // Icon panah di sebelah kanan sebagai petunjuk opsi navigasi.
      trailing: const Icon(
        Icons.chevron_right,
        color: Colors.white54,
      ),
      // Mengaitkan event onTap ke fungsi callback yang diterima parameter.
      onTap: onTap,
    );
  }
}

// =======================================================
// HALAMAN RIWAYAT PESANAN
// =======================================================

// Declaring class MyOrdersPage yang merupakan StatelessWidget untuk riwayat pesanan.
class MyOrdersPage extends StatelessWidget {
  // Konstruktor untuk MyOrdersPage dengan opsional key parameter.
  const MyOrdersPage({super.key});

  // Fungsi privat untuk mengonversi data dinamis menjadi teks String dengan nilai cadangan (fallback).
  String _readText(dynamic value, [String fallback = '-']) {
    // Jika value null, langsung kembalikan string fallback.
    if (value == null) return fallback;

    // Konversi value ke string dan hapus spasi berlebih.
    final text = value.toString().trim();
    // Jika string setelah di-trim kosong, kembalikan fallback, jika tidak kembalikan text.
    return text.isEmpty ? fallback : text;
  }

  // Fungsi privat untuk mencari nama produk dari berbagai kemungkinan nama field di database.
  String _productName(Map<String, dynamic> product) {
    // Daftar variasi nama kunci (key) nama produk yang mungkin digunakan pada Firestore.
    final candidates = [
      product['name'],
      product['productName'],
      product['product_name'],
      product['title'],
      product['nama'],
      product['namaProduk'],
    ];

    // Melakukan perulangan untuk memeriksa setiap kemungkinan key.
    for (final candidate in candidates) {
      // Jika kandidat ada dan tidak kosong setelah di-trim.
      if (candidate != null &&
          candidate.toString().trim().isNotEmpty) {
        // Kembalikan nama produk yang valid.
        return candidate.toString().trim();
      }
    }

    // Kembalikan teks default jika semua kandidat key kosong/null.
    return 'Nama produk tidak tersedia';
  }

  // Fungsi privat untuk mendapatkan nilai kuantitas produk secara aman.
  int _productQuantity(Map<String, dynamic> product) {
    // Mencari nilai kuantitas dari field 'quantity', 'qty', atau 'jumlah'.
    final value = product['quantity'] ??
        product['qty'] ??
        product['jumlah'];

    // Jika tipe data sudah dalam angka (num), ubah ke integer dan kembalikan.
    if (value is num) return value.toInt();

    // Jika nilai tidak null tetapi bukan tipe num, coba parsing dari String.
    if (value != null) {
      // Parsing string ke int, jika gagal fallback ke angka 1.
      return int.tryParse(value.toString()) ?? 1;
    }

    // Default kuantitas adalah 1 jika tidak ada data sama sekali.
    return 1;
  }

  // Fungsi privat untuk menguraikan dan memformat objek tanggal/waktu ke format teks terstruktur.
  String _formatDate(dynamic value) {
    // Deklarasi variabel penampung tanggal bertipe DateTime yang nullable.
    DateTime? date;

    // Memeriksa jika nilai berupa Timestamp bawaan Firestore.
    if (value is Timestamp) {
      // Mengonversi Timestamp ke objek DateTime lokal.
      date = value.toDate().toLocal();
    } else if (value is DateTime) {
      // Mengonversi DateTime ke waktu lokal jika sudah bertipe DateTime.
      date = value.toLocal();
    } else if (value is String) {
      // Mencoba parsing dari tipe String ke DateTime lokal jika memungkinkan.
      date = DateTime.tryParse(value)?.toLocal();
    }

    // Jika gagal dikonversi (date tetap null), kembalikan karakter '-'.
    if (date == null) return '-';

    // Mengembalikan string tanggal terformat DD/MM/YYYY HH:mm.
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year} '
        '${date.hour.toString().padLeft(2, '0')}:'
        '${date.minute.toString().padLeft(2, '0')}';
  }

  // Metode build untuk membangun struktur antarmuka MyOrdersPage.
  @override
  Widget build(BuildContext context) {
    // Mengambil informasi pengguna aktif dari FirebaseAuth.
    final user = FirebaseAuth.instance.currentUser;

    // Memeriksa jika pengguna belum terotentikasi.
    if (user == null) {
      // Mengembalikan Scaffold lengkap dengan AppBar dan pesan error/peringatan.
      return Scaffold(
        // Mengatur warna latar belakang halaman.
        backgroundColor: wonkaBrown,
        // Menampilkan bilah aplikasi atas.
        appBar: AppBar(
          // Judul bilah aplikasi.
          title: const Text('Pesanan Saya'),
          // Warna latar belakang AppBar.
          backgroundColor: wonkaBrown,
          // Warna teks dan icon AppBar.
          foregroundColor: wonkaGold,
        ),
        // Tampilan badan utama saat pengguna null.
        body: const Center(
          // Pesan teks pemberitahuan login.
          child: Text(
            'Silakan login terlebih dahulu.',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }

    // Mengambil referensi koleksi pesanan yang terfilter berdasarkan userId.
    final orders = FirebaseFirestore.instance
        .collection('orders')
        .where('userId', isEqualTo: user.uid);

    // Mengembalikan Scaffold utama halaman riwayat pesanan.
    return Scaffold(
      // Warna background scaffold menggunakan wonkaBrown.
      backgroundColor: wonkaBrown,
      // AppBar di bagian atas halaman.
      appBar: AppBar(
        // Judul halaman pada AppBar.
        title: const Text('Pesanan Saya'),
        // Warna background AppBar.
        backgroundColor: wonkaBrown,
        // Warna icon & font AppBar.
        foregroundColor: wonkaGold,
      ),
      // Membangun body dengan StreamBuilder untuk pembaruan data real-time.
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        // Mengubungkan stream query pesanan Firestore.
        stream: orders.snapshots(),
        // Fungsi pembangun widget antarmuka berdasarkan snapshot stream.
        builder: (context, snapshot) {
          // Menangani kondisi jika stream mengalami error.
          if (snapshot.hasError) {
            return const Center(
              // Teks pesan error.
              child: Text(
                'Gagal memuat pesanan.',
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          // Menangani kondisi saat data sedang dimuat (waiting state).
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              // Menampilkan indikator pemuatan memutar berwarna emas.
              child: CircularProgressIndicator(
                color: wonkaGold,
              ),
            );
          }

          // Mengambil daftar dokumen dari snapshot, atau list kosong jika null.
          final docs = snapshot.data?.docs.toList() ?? [];

          // Memeriksa jika dokumen pesanan kosong.
          if (docs.isEmpty) {
            return const Center(
              // Memberikan padding untuk teks pemberitahuan riwayat kosong.
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'Belum ada riwayat pesanan. '
                      'setelah kamu berhasil melakukan checkout.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white70),
                ),
              ),
            );
          }

          // Mengurutkan dokumen pesanan secara terbalik berdasarkan tanggal (terbaru di atas).
          docs.sort((a, b) {
            // Mengambil nilai field 'date' dokumen A.
            final dateA = a.data()['date'];
            // Mengambil nilai field 'date' dokumen B.
            final dateB = b.data()['date'];

            // Deklarasi variabel waktu sementara untuk dokumen A.
            DateTime? aDate;
            // Deklarasi variabel waktu sementara untuk dokumen B.
            DateTime? bDate;

            // Jika dateA bertipe Timestamp, konversi ke DateTime.
            if (dateA is Timestamp) aDate = dateA.toDate();
            // Jika dateA bertipe DateTime, simpan langsung.
            if (dateA is DateTime) aDate = dateA;

            // Jika dateB bertipe Timestamp, konversi ke DateTime.
            if (dateB is Timestamp) bDate = dateB.toDate();
            // Jika dateB bertipe DateTime, simpan langsung.
            if (dateB is DateTime) bDate = dateB;

            // Logika pembandingan jika salah satu atau kedua tanggal null.
            if (aDate == null && bDate == null) return 0;
            if (aDate == null) return 1;
            if (bDate == null) return -1;

            // Membandingkan bDate dengan aDate agar urut secara descending (terbaru ke terlama).
            return bDate.compareTo(aDate);
          });

          // Membangun daftar elemen pesanan menggunakan ListView.builder.
          return ListView.builder(
            // Padding luar di sekeliling daftar item.
            padding: const EdgeInsets.all(16),
            // Jumlah total item dalam ListView setara dengan jumlah dokumen pesanan.
            itemCount: docs.length,
            // Fungsi pembangun setiap elemen item daftar.
            itemBuilder: (context, index) {
              // Mengambil data Map dari dokumen pesanan saat ini.
              final order = docs[index].data();

              // Mengambil nilai totalPrice dari map order.
              final totalValue = order['totalPrice'];
              // Validasi tipe data total harga, default 0 jika bukan angka.
              final num total =
              totalValue is num ? totalValue : 0;

              // Membaca alamat pengiriman menggunakan fungsi utilitas _readText.
              final address =
              _readText(order['address']);

              // Membaca status pesanan, dengan nilai default 'Berhasil'.
              final status = _readText(
                order['status'],
                'Berhasil',
              );

              // Memformat tanggal checkout dari data order.
              final dateText = _formatDate(order['date']);

              // Mengambil daftar item produk yang dipesan.
              final rawItems = order['items'];

              // Memastikan rawItems bertipe List, jika bukan maka buat List kosong.
              final List<dynamic> items = rawItems is List
                  ? rawItems
                  : <dynamic>[];

              // Mengembalikan Card untuk setiap item pesanan.
              return Card(
                // Warna kartu krem.
                color: wonkaCream,
                // Jarak antar kartu ke bawah sebesar 16 piksel.
                margin: const EdgeInsets.only(bottom: 16),
                // Mengatur kelengkungan sudut kartu sebesar 14 piksel.
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                // Padding bagian dalam kartu.
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  // Menyusun informasi pesanan secara vertikal di dalam kartu.
                  child: Column(
                    // Perataan anak-anak widget ke sisi kiri.
                    crossAxisAlignment: CrossAxisAlignment.start,
                    // Anak-anak widget dalam kartu pesanan.
                    children: [
                      // Baris header kartu pesanan.
                      Row(
                        children: [
                          // Icon struk/resi transaksi.
                          const Icon(
                            Icons.receipt_long,
                            color: wonkaBrown,
                          ),
                          // Jarak horizontal 8 piksel.
                          const SizedBox(width: 8),
                          // Menampilkan nomor urut pesanan dengan sifat memanjang.
                          Expanded(
                            child: Text(
                              'Pesanan ${index + 1}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 17,
                                color: wonkaBrown,
                              ),
                            ),
                          ),
                          // Menampilkan total harga yang sudah diformat angka bulat.
                          Text(
                            'Rp ${total.toStringAsFixed(0)}',
                            style: const TextStyle(
                              color: wonkaBrown,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),

                      // Jarak vertikal 12 piksel.
                      const SizedBox(height: 12),

                      // Memeriksa jika daftar item produk di dalam order kosong.
                      if (items.isEmpty)
                      // Teks pemberitahuan jika detail produk tidak ditemukan.
                        const Text(
                          'Detail produk tidak tersedia.',
                          style: TextStyle(
                            color: Color(0xFF795548),
                          ),
                        )
                      else
                      // Melakukan pemetaan item produk ke dalam widget daftar.
                        ...items.map((item) {
                          // Memastikan elemen item berupa Map.
                          if (item is! Map) {
                            // Kembalikan widget kosong jika item bukan Map.
                            return const SizedBox.shrink();
                          }

                          // Mengonversi tipe item ke Map<String, dynamic>.
                          final product =
                          Map<String, dynamic>.from(item);

                          // Mengambil nama produk melalui fungsi helper.
                          final name = _productName(product);
                          // Mengambil kuantitas produk melalui fungsi helper.
                          final quantity =
                          _productQuantity(product);

                          // Mengembalikan tampilan setiap baris detail item produk.
                          return Padding(
                            padding: const EdgeInsets.only(
                              bottom: 8,
                            ),
                            // Menyusun bullet icon dan teks produk secara horizontal.
                            child: Row(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                // Bullet titik menggunakan icon lingkaran kecil.
                                const Padding(
                                  padding: EdgeInsets.only(top: 6),
                                  child: Icon(
                                    Icons.circle,
                                    size: 7,
                                    color: wonkaBrown,
                                  ),
                                ),
                                // Jarak horizontal 10 piksel.
                                const SizedBox(width: 10),
                                // Teks rincian nama dan jumlah produk dipesan.
                                Expanded(
                                  child: Text(
                                    '$name x$quantity',
                                    style: const TextStyle(
                                      color: wonkaBrown,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),

                      // Garis pembatas horizontal antar bagian dalam kartu.
                      const Divider(height: 24),

                      // Baris informasi alamat.
                      Row(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          // Icon penanda lokasi/alamat.
                          const Icon(
                            Icons.location_on_outlined,
                            color: wonkaBrown,
                            size: 19,
                          ),
                          // Jarak horizontal 8 piksel.
                          const SizedBox(width: 8),
                          // Teks alamat pengiriman.
                          Expanded(
                            child: Text(
                              'Alamat: $address',
                              style: const TextStyle(
                                color: wonkaBrown,
                              ),
                            ),
                          ),
                        ],
                      ),

                      // Jarak vertikal 10 piksel.
                      const SizedBox(height: 10),

                      // Baris informasi tanggal transaksi.
                      Row(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          // Icon kalender.
                          const Icon(
                            Icons.calendar_today_outlined,
                            color: wonkaBrown,
                            size: 17,
                          ),
                          // Jarak horizontal 8 piksel.
                          const SizedBox(width: 8),
                          // Teks tanggal transaksi yang sudah diformat.
                          Expanded(
                            child: Text(
                              'Tanggal: $dateText',
                              style: const TextStyle(
                                color: wonkaBrown,
                              ),
                            ),
                          ),
                        ],
                      ),

                      // Jarak vertikal 10 piksel.
                      const SizedBox(height: 10),

                      // Teks menampilkan status pesanan.
                      Text(
                        'Status: $status',
                        style: const TextStyle(
                          color: wonkaBrown,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// =======================================================
// HALAMAN COKELAT FAVORIT
// =======================================================

// Declaring class FavoriteChocolatesPage yang merupakan StatelessWidget untuk daftar favorit.
class FavoriteChocolatesPage extends StatelessWidget {
  // Konstruktor untuk FavoriteChocolatesPage dengan opsional key parameter.
  const FavoriteChocolatesPage({super.key});

  // Metode build untuk membangun struktur antarmuka halaman favorit.
  @override
  Widget build(BuildContext context) {
    // Mengambil status pengguna aktif dari FirebaseAuth.
    final user = FirebaseAuth.instance.currentUser;

    // Pengecekan kondisi jika pengguna belum login.
    if (user == null) {
      // Mengembalikan Scaffold sederhana dengan teks peringatan.
      return const Scaffold(
        backgroundColor: wonkaBrown,
        body: Center(
          child: Text(
            'Silakan login terlebih dahulu',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }

    // Menunjuk ke sub-koleksi 'favorites' di Firestore milik pengguna saat ini.
    final favorites = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('favorites');

    // Mengembalikan Scaffold utama halaman favorit.
    return Scaffold(
      // Warna background scaffold.
      backgroundColor: wonkaBrown,
      // AppBar bagian atas.
      appBar: AppBar(
        // Judul halaman.
        title: const Text('Cokelat Favorit'),
        // Warna background AppBar.
        backgroundColor: wonkaBrown,
        // Warna icon dan font AppBar.
        foregroundColor: wonkaGold,
      ),
      // Membangun body dengan StreamBuilder untuk mendengarkan sub-koleksi favorit.
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        // Menghubungkan stream dari sub-koleksi favorites.
        stream: favorites.snapshots(),
        // Pembangun widget berbasis snapshot data favorit.
        builder: (context, snapshot) {
          // Menangani kondisi error.
          if (snapshot.hasError) {
            return const Center(
              child: Text(
                'Gagal memuat favorit.',
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          // Menangani kondisi loading saat menunggu data.
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: wonkaGold,
              ),
            );
          }

          // Mengambil dokumen favorit, atau list kosong jika null.
          final docs = snapshot.data?.docs ?? [];

          // Memeriksa jika belum ada produk favorit yang disimpan.
          if (docs.isEmpty) {
            return const Center(
              child: Text(
                'Belum ada cokelat favorit.',
                style: TextStyle(color: Colors.white70),
              ),
            );
          }

          // Membangun daftar item cokelat favorit dengan ListView.builder.
          return ListView.builder(
            // Padding sekeliling ListView.
            padding: const EdgeInsets.all(16),
            // Jumlah total item terdaftar pada favorit.
            itemCount: docs.length,
            // Pembangun untuk setiap elemen daftar item favorit.
            itemBuilder: (context, index) {
              // Mengambil dokumen saat ini.
              final doc = docs[index];
              // Mengambil map data produk dari dokumen.
              final product = doc.data();

              // Card penampung item favorit.
              return Card(
                // Warna kartu krem.
                color: wonkaCream,
                // Jarak luar bawah antar kartu.
                margin: const EdgeInsets.only(bottom: 12),
                // Menggunakan ListTile untuk item berformat standar (avatar, judul, subjudul, trailing icon).
                child: ListTile(
                  // Icon avatar kue/cokelat di sebelah kiri.
                  leading: const CircleAvatar(
                    backgroundColor: wonkaBrown,
                    child: Icon(
                      Icons.cake_outlined,
                      color: wonkaGold,
                    ),
                  ),
                  // Judul produk favorit.
                  title: Text(
                    product['name']?.toString() ?? 'Cokelat',
                    style: const TextStyle(
                      color: wonkaBrown,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  // Subjudul menampilkan harga produk.
                  subtitle: Text(
                    'Harga: Rp ${product['price'] ?? 0}',
                    style: const TextStyle(color: wonkaBrown),
                  ),
                  // Tombol di ujung kanan untuk menghapus dari daftar favorit.
                  trailing: IconButton(
                    // Petunjuk tooltip pada tombol.
                    tooltip: 'Hapus dari favorit',
                    // Icon hati berwarna merah.
                    icon: const Icon(
                      Icons.favorite,
                      color: Colors.red,
                    ),
                    // Fungsi asinkronus yang dijalankan saat tombol hapus diklik.
                    onPressed: () async {
                      try {
                        // Menghapus dokumen favorit ini langsung dari Firestore.
                        await doc.reference.delete();
                      } catch (_) {
                        // Memastikan konteks widget masih terpasang pada pohon UI sebelum menampilkan SnackBar.
                        if (!context.mounted) return;

                        // Menampilkan notifikasi pesan kegagalan menghapus jika terjadi error.
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Gagal menghapus favorit.',
                            ),
                          ),
                        );
                      }
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// =======================================================
// HALAMAN BANTUAN
// =======================================================

// Declaring class WonkaHelpPage yang merupakan StatelessWidget untuk tampilan FAQ/Bantuan.
class WonkaHelpPage extends StatelessWidget {
  // Konstruktor untuk WonkaHelpPage dengan opsional key parameter.
  const WonkaHelpPage({super.key});

  // Metode build untuk membangun UI halaman bantuan.
  @override
  Widget build(BuildContext context) {
    // Mengembalikan Scaffold halaman bantuan.
    return Scaffold(
      // Warna latar belakang halaman.
      backgroundColor: wonkaBrown,
      // AppBar halaman bantuan.
      appBar: AppBar(
        // Judul pada AppBar bantuan.
        title: const Text('Bantuan WonkaStore'),
        // Warna latar belakang AppBar.
        backgroundColor: wonkaBrown,
        // Warna teks dan icon AppBar.
        foregroundColor: wonkaGold,
      ),
      // Menggunakan ListView sederhana untuk daftar item pertanyaan bantuan statis.
      body: ListView(
        // Padding sekeliling ListView.
        padding: const EdgeInsets.all(16),
        // Daftar widget ubin bantuan kustom (_HelpTile).
        children: const [
          // Item bantuan 1 tentang cara memilih cokelat.
          _HelpTile(
            title: 'Bagaimana cara memilih cokelat?',
            content:
            'Buka Homepage, pilih cokelat yang diinginkan, '
                'lalu lihat informasi dan harga produk.',
          ),
          // Item bantuan 2 tentang cara menyimpan favorit.
          _HelpTile(
            title: 'Bagaimana cara menyimpan favorit?',
            content:
            'Tekan ikon hati pada produk. Produk akan muncul '
                'di menu Cokelat Favorit setelah berhasil disimpan.',
          ),
          // Item bantuan 3 tentang proses checkout.
          _HelpTile(
            title: 'Bagaimana cara checkout?',
            content:
            'Tambahkan produk ke keranjang, periksa jumlah dan '
                'total harga, kemudian tekan tombol Checkout.',
          ),
          // Item bantuan 4 tentang letak riwayat pesanan.
          _HelpTile(
            title: 'Di mana melihat riwayat pesanan?',
            content:
            'Buka Profil, lalu pilih Pesanan Saya. '
                'Pesanan yang berhasil disimpan akan muncul di sana.',
          ),
          // Item bantuan 5 tentang cara keluar dari akun.
          _HelpTile(
            title: 'Bagaimana cara keluar?',
            content:
            'Buka Profil dan tekan tombol Keluar untuk '
                'mengakhiri sesi akun.',
          ),
        ],
      ),
    );
  }
}

// Widget kustom privat untuk komponen collapsible (bisa di-expand) pada tiap pertanyaan bantuan.
class _HelpTile extends StatelessWidget {
  // Variabel judul pertanyaan.
  final String title;
  // Variabel isi jawaban/konten bantuan.
  final String content;

  // Konstruktor _HelpTile dengan parameter wajib title dan content.
  const _HelpTile({
    required this.title,
    required this.content,
  });

  // Metode build untuk membangun struktur visual item pertanyaan bantuan.
  @override
  Widget build(BuildContext context) {
    // Kartu pembungkus ExpansionTile.
    return Card(
      // Warna latar belakang kartu krem.
      color: wonkaCream,
      // Jarak luar bawah sebesar 12 piksel.
      margin: const EdgeInsets.only(bottom: 12),
      // Widget bawaan Flutter yang dapat mekar/membuka untuk memperlihatkan konten tambahan.
      child: ExpansionTile(
        // Warna icon panah saat posisi terbuka.
        iconColor: wonkaBrown,
        // Warna icon panah saat posisi tertutup.
        collapsedIconColor: wonkaBrown,
        // Teks judul pertanyaan pada ubin.
        title: Text(
          title,
          style: const TextStyle(
            color: wonkaBrown,
            fontWeight: FontWeight.bold,
          ),
        ),
        // Widget anak (jawaban) yang muncul saat ubin ditekan/dimekarkan.
        children: [
          // Padding di sekitar teks jawaban.
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            // Meratakan posisi teks ke sebelah kiri.
            child: Align(
              alignment: Alignment.centerLeft,
              // Teks isi penjelasan dari pertanyaan bantuan.
              child: Text(
                content,
                style: const TextStyle(color: wonkaBrown),
              ),
            ),
          ),
        ],
      ),
    );
  }
}