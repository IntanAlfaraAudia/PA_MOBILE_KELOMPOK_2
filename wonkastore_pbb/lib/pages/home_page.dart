import 'package:flutter/material.dart'; // Menggunakan widget Material Design.
import 'package:provider/provider.dart'; // Mengambil data dari Provider.
import 'package:firebase_auth/firebase_auth.dart'; // Mengakses akun pengguna.
import 'package:cloud_firestore/cloud_firestore.dart'; // Menghubungkan aplikasi ke Firestore.

import '../providers/cart_provider.dart'; // Mengambil fungsi keranjang dan data produk.
import '../models/product.dart'; // Menggunakan model Product.

// Halaman utama untuk menampilkan produk cokelat Wonka.
class HomePage extends StatefulWidget {
  // Konstruktor halaman utama.
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState(); // Membuat state halaman.
}

class _HomePageState extends State<HomePage> {
  // Menyimpan teks yang dimasukkan pada kolom pencarian.
  String searchQuery = '';

  // Mengambil koleksi favorit berdasarkan akun yang sedang login.
  CollectionReference<Map<String, dynamic>> get favoritesCollection {
    // Mengecek akun pengguna saat ini.
    final user = FirebaseAuth.instance.currentUser;

    // Koleksi favorit hanya bisa diakses jika pengguna sudah login.
    if (user == null) {
      throw Exception('Pengguna belum login.');
    }

    // Menyimpan favorit di dalam dokumen masing-masing pengguna.
    return FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('favorites');
  }

  // Menambah atau menghapus produk dari daftar favorit.
  Future<void> toggleFavorite(Product product) async {
    // Mengambil akun yang sedang digunakan.
    final user = FirebaseAuth.instance.currentUser;

    // Memastikan pengguna sudah login sebelum menyimpan favorit.
    if (user == null) {
      if (!mounted) return; // Memastikan halaman masih aktif.

      // Memberi tahu pengguna bahwa mereka perlu login.
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Silakan login untuk menyimpan favorit.'),
        ),
      );
      return;
    }

    // Menggunakan ID produk agar setiap favorit memiliki dokumen sendiri.
    final favoriteRef = favoritesCollection.doc(product.id);

    try {
      // Mengecek apakah produk sudah ada di daftar favorit.
      final existing = await favoriteRef.get();

      if (existing.exists) {
        // Menghapus produk jika sebelumnya sudah menjadi favorit.
        await favoriteRef.delete();

        if (!mounted) return; // Mengecek apakah halaman masih terbuka.

        // Menampilkan pesan setelah favorit dihapus.
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${product.name} dihapus dari favorit.'),
            duration: const Duration(seconds: 1),
          ),
        );
      } else {
        // Menyimpan informasi produk ke Firestore.
        await favoriteRef.set({
          'productId': product.id, // ID produk.
          'name': product.name, // Nama produk.
          'price': product.price, // Harga produk.
          'description': product.desc, // Deskripsi produk.
          'image': product.image, // Lokasi gambar produk.
          'createdAt': FieldValue.serverTimestamp(), // Waktu penyimpanan.
        });

        if (!mounted) return; // Mengecek apakah halaman masih terbuka.

        // Memberi tahu pengguna bahwa produk berhasil disimpan.
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${product.name} ditambahkan ke favorit!'),
            duration: const Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      // Menangani kesalahan ketika proses favorit gagal.
      if (!mounted) return;

      // Menampilkan pesan jika penyimpanan mengalami masalah.
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Gagal menyimpan favorit. Periksa koneksi dan Firebase.',
          ),
        ),
      );
    }
  }

  // Menyusun tampilan utama aplikasi.
  @override
  Widget build(BuildContext context) {
    // Mengambil data produk dan keranjang dari CartProvider.
    final cart = context.watch<CartProvider>();

    // Menampilkan produk yang namanya sesuai dengan pencarian.
    final visibleProducts = cart.products.where((product) {
      return product.name.toLowerCase().contains(
        searchQuery.toLowerCase(),
      );
    }).toList();

    // Scaffold menjadi kerangka utama halaman.
    return Scaffold(
      // Membuat latar halaman transparan.
      backgroundColor: Colors.transparent,

      // SafeArea menjaga konten agar tidak tertutup status bar.
      body: SafeArea(
        // CustomScrollView memungkinkan halaman digulir.
        child: CustomScrollView(
          // Sliver digunakan untuk menyusun bagian halaman yang bisa digulir.
          slivers: [
            // Bagian pertama berisi logo, pencarian, dan promosi.
            SliverToBoxAdapter(
              // Memberi jarak pada bagian atas dan samping halaman.
              child: Padding(
                padding: const EdgeInsets.only(
                  top: 25,
                  left: 20,
                  right: 20,
                ),

                // Menyusun isi header dari atas ke bawah.
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Menampilkan logo toko dan tombol notifikasi.
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Nama toko dan tulisan pendukung.
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Nama utama toko cokelat.
                            Text(
                              'Wonka',
                              style: TextStyle(
                                fontSize: 36, // Ukuran tulisan logo.
                                fontWeight: FontWeight.bold, // Tulisan tebal.
                                color: Color(0xFFFFD700), // Warna emas.
                                fontFamily: 'Serif', // Jenis huruf logo.
                                fontStyle: FontStyle.italic, // Tulisan miring.
                              ),
                            ),

                            // Tulisan kecil di bawah logo.
                            Text(
                              'TOKO COKELAT AJAIB',
                              style: TextStyle(
                                fontSize: 10,
                                letterSpacing: 2, // Jarak antarhuruf.
                                color: Color(0xFFFFD700),
                              ),
                            ),
                          ],
                        ),

                        // Membuat lingkaran sebagai bingkai notifikasi.
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFFFFD700),
                            ),
                          ),

                          // Tombol untuk menampilkan informasi notifikasi.
                          child: IconButton(
                            tooltip: 'Notifikasi',
                            icon: const Icon(
                              Icons.notifications_none,
                              color: Color(0xFFFFD700),
                            ),
                            onPressed: () {
                              // Menampilkan pesan ketika tombol ditekan.
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Belum ada notifikasi baru.',
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),

                    // Memberi jarak antara logo dan pencarian.
                    const SizedBox(height: 24),

                    // Membuat latar untuk kolom pencarian.
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF8E7)
                            .withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(25),
                      ),

                      // Kolom untuk mencari produk berdasarkan nama.
                      child: TextField(
                        onChanged: (value) {
                          // Memperbarui hasil pencarian saat teks berubah.
                          setState(() {
                            searchQuery = value;
                          });
                        },

                        // Mengatur warna teks yang diketik.
                        style: const TextStyle(
                          color: Color(0xFF3E2723),
                        ),

                        // Mengatur ikon, petunjuk, dan batas kolom pencarian.
                        decoration: const InputDecoration(
                          hintText: 'Cari cokelat ajaib...',
                          hintStyle: TextStyle(color: Colors.black38),
                          prefixIcon: Icon(
                            Icons.search,
                            color: Colors.black54,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            vertical: 14,
                          ),
                        ),
                      ),
                    ),

                    // Memberi jarak sebelum banner promosi.
                    const SizedBox(height: 24),

                    // Banner promosi Golden Ticket.
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),

                      // Memberi warna gradasi dan sudut melengkung pada banner.
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFFFFDF73),
                            Color(0xFFD4AF37),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),

                      // Menyusun informasi diskon dan tombol klaim.
                      child: Row(
                        children: [
                          // Bagian informasi promosi.
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Nama promosi.
                                Text(
                                  'GOLDEN TICKET',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF3E2723),
                                    letterSpacing: 1,
                                  ),
                                ),

                                // Besarnya diskon yang ditawarkan.
                                Text(
                                  'Diskon Rp 15.000',
                                  style: TextStyle(
                                    fontSize: 23,
                                    fontWeight: FontWeight.w900,
                                    color: Color(0xFF3E2723),
                                    fontFamily: 'Serif',
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),

                                // Keterangan penggunaan diskon.
                                Text(
                                  'Untuk pesanan cokelat ajaibmu',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF5D4037),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Memberi jarak antara informasi dan tombol.
                          const SizedBox(width: 8),

                          // Tombol klaim diskon yang terhubung ke CartProvider.
                          ElevatedButton(
                            // Tombol dinonaktifkan jika diskon sudah diklaim.
                            onPressed: cart.isDiscountClaimed
                                ? null
                                : () {
                              // Menandai diskon sebagai sudah diklaim.
                              cart.claimDiscount();

                              // Menampilkan pesan klaim berhasil.
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Golden Ticket berhasil diklaim!',
                                  ),
                                  backgroundColor: Colors.green,
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            },

                            // Mengatur tampilan tombol klaim.
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF3E2723),
                              disabledBackgroundColor: Colors.grey.shade700,
                              foregroundColor: const Color(0xFFFFD700),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),

                            // Tulisan tombol berubah setelah diskon diklaim.
                            child: Text(
                              cart.isDiscountClaimed ? 'Terklaim' : 'Klaim',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Jarak antara banner dan judul daftar produk.
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            // Judul produk tetap terlihat ketika halaman digulir.
            SliverPersistentHeader(
              pinned: true,

              // Mengatur ukuran dan isi header yang menempel.
              delegate: _StickyHeaderDelegate(
                minHeight: 50,
                maxHeight: 50,

                // Latar dan judul bagian produk.
                child: Container(
                  color: const Color(0xFF2B0A42)
                      .withValues(alpha: 0.95),
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.symmetric(horizontal: 20),

                  // Judul daftar produk terlaris.
                  child: const Text(
                    'Cokelat Ajaib Terlaris',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFFFD700),
                      fontFamily: 'Serif',
                    ),
                  ),
                ),
              ),
            ),

            // Menampilkan pesan jika tidak ada produk yang cocok.
            if (visibleProducts.isEmpty)
              const SliverFillRemaining(
                hasScrollBody: false,

                // Pesan ditampilkan di tengah halaman.
                child: Center(
                  child: Text(
                    'Produk tidak ditemukan.',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ),
              )
            else
            // Memberi jarak di sekitar daftar produk.
              SliverPadding(
                padding: const EdgeInsets.only(
                  left: 20,
                  right: 20,
                  top: 16,
                  bottom: 20,
                ),

                // Menampilkan produk dalam bentuk grid dua kolom.
                sliver: SliverGrid(
                  // Mengatur jumlah kolom dan jarak antarproduk.
                  gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.75,
                  ),

                  // Membuat kartu berdasarkan data produk yang tersedia.
                  delegate: SliverChildBuilderDelegate(
                        (context, index) {
                      // Mengambil produk sesuai posisi pada daftar.
                      final product = visibleProducts[index];

                      // Menampilkan kartu produk.
                      return _buildProductCard(context, product, cart);
                    },
                    childCount: visibleProducts.length,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // Membuat kartu yang berisi gambar, nama, harga, favorit, dan keranjang.
  Widget _buildProductCard(
      BuildContext context,
      Product product,
      CartProvider cart,
      ) {
    // Container menjadi bingkai utama kartu produk.
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E7).withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(16),
      ),

      // Menyusun gambar dan informasi produk secara vertikal.
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Bagian atas kartu untuk gambar dan tombol favorit.
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Latar gambar produk.
                Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFFF0E6D2),
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                  ),

                  // Memotong gambar agar mengikuti sudut kartu.
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),

                    // Mengambil gambar produk dari folder assets.
                    child: Image.asset(
                      product.image,
                      fit: BoxFit.cover,

                      // Menampilkan ikon jika gambar gagal dimuat.
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(
                          Icons.image,
                          size: 50,
                          color: Colors.black26,
                        );
                      },
                    ),
                  ),
                ),

                // Meletakkan tombol favorit di pojok kanan atas.
                Positioned(
                  top: 4,
                  right: 4,

                  // Memberi latar berbentuk lingkaran pada tombol favorit.
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF8E7)
                          .withValues(alpha: 0.95),
                      shape: BoxShape.circle,
                    ),

                    // Tombol untuk menyimpan atau menghapus favorit.
                    child: IconButton(
                      tooltip: 'Tambah atau hapus favorit',
                      icon: const Icon(
                        Icons.favorite_border,
                        color: Color(0xFF8B0000),
                      ),
                      onPressed: () => toggleFavorite(product),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Bagian bawah kartu untuk informasi produk.
          Padding(
            padding: const EdgeInsets.all(12),

            // Menyusun nama, deskripsi, harga, dan tombol keranjang.
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Menampilkan nama produk.
                Text(
                  product.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF3E2723),
                    fontSize: 14,
                  ),
                ),

                // Memberi jarak kecil setelah nama produk.
                const SizedBox(height: 2),

                // Menampilkan deskripsi singkat produk.
                Text(
                  product.desc,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF8D6E63),
                    fontSize: 11,
                  ),
                ),

                // Memberi jarak sebelum bagian harga.
                const SizedBox(height: 8),

                // Menampilkan harga dan tombol tambah ke keranjang.
                Row(
                  children: [
                    // Harga memakai ruang yang tersedia pada baris.
                    Expanded(
                      child: Text(
                        'Rp ${product.price}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF3E2723),
                          fontSize: 14,
                        ),
                      ),
                    ),

                    // Tombol untuk memasukkan produk ke keranjang.
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        // Membuat area tekan berbentuk lingkaran.
                        customBorder: const CircleBorder(),

                        onTap: () {
                          // Memeriksa stok sebelum produk ditambahkan.
                          if (product.stock <= 0) {
                            // Memberi tahu pengguna jika stok habis.
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Stok produk habis.'),
                              ),
                            );
                            return;
                          }

                          // Menambahkan produk ke keranjang belanja.
                          cart.addToCart(product);

                          // Menampilkan konfirmasi setelah produk ditambahkan.
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                '${product.name} masuk keranjang!',
                              ),
                              duration: const Duration(seconds: 1),
                            ),
                          );
                        },

                        // Membuat tombol tambah dengan gradasi warna emas.
                        child: Container(
                          padding: const EdgeInsets.all(5),
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [
                                Color(0xFFFFDF73),
                                Color(0xFFD4AF37),
                              ],
                            ),
                          ),

                          // Ikon tambah pada tombol keranjang.
                          child: const Icon(
                            Icons.add,
                            size: 20,
                            color: Color(0xFF3E2723),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Mengatur tampilan judul yang tetap berada di atas saat halaman digulir.
class _StickyHeaderDelegate extends SliverPersistentHeaderDelegate {
  // Tinggi minimum header.
  final double minHeight;

  // Tinggi maksimum header.
  final double maxHeight;

  // Widget yang akan ditampilkan pada header.
  final Widget child;

  // Menerima ukuran dan isi header dari halaman utama.
  _StickyHeaderDelegate({
    required this.minHeight,
    required this.maxHeight,
    required this.child,
  });

  // Menentukan tinggi minimum header.
  @override
  double get minExtent => minHeight;

  // Menentukan tinggi maksimum header.
  @override
  double get maxExtent => maxHeight;

  // Menampilkan isi header sesuai ukuran yang ditentukan.
  @override
  Widget build(
      BuildContext context,
      double shrinkOffset,
      bool overlapsContent,
      ) {
    // Membuat widget memenuhi seluruh ruang header.
    return SizedBox.expand(child: child);
  }

  // Mengecek apakah ukuran atau isi header berubah.
  @override
  bool shouldRebuild(_StickyHeaderDelegate oldDelegate) {
    return maxHeight != oldDelegate.maxHeight ||
        minHeight != oldDelegate.minHeight ||
        child != oldDelegate.child;
  }
}