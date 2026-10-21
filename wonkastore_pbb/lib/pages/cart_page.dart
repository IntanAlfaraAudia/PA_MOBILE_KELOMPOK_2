import 'package:flutter/material.dart'; // Menyediakan widget untuk membuat tampilan aplikasi.
import 'package:provider/provider.dart'; // Mengambil dan memantau data dari CartProvider.
import 'package:firebase_auth/firebase_auth.dart'; // Mengambil informasi pengguna yang sedang login.
import 'package:cloud_firestore/cloud_firestore.dart'; // Menyimpan data pesanan ke Firestore.

import '../providers/cart_provider.dart'; // Mengakses data dan fungsi keranjang belanja.
import '../models/product.dart'; // Menggunakan model untuk menyimpan data produk.

// StatefulWidget digunakan karena isi keranjang dan pilihan pembayaran dapat berubah.
class CartPage extends StatefulWidget {
  // Konstruktor halaman keranjang.
  const CartPage({super.key});

  @override
  // Membuat state untuk mengatur perubahan pada halaman keranjang.
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  // Menandai apakah checkout sedang berlangsung.
  bool isCheckingOut = false;

  // Menyimpan metode pembayaran yang dipilih pengguna.
  String metodePembayaran = 'QRIS';

  // Controller untuk membaca dan menghapus alamat pengiriman.
  final TextEditingController addressController = TextEditingController();

  @override
  // Membersihkan controller ketika halaman sudah tidak digunakan.
  void dispose() {
    addressController.dispose();
    super.dispose();
  }

  // Mengubah angka menjadi format mata uang rupiah.
  String _formatRupiah(int amount) {
    // Menambahkan titik sebagai pemisah ribuan.
    final formatted = amount.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
          (match) => '${match[1]}.',
    );

    // Mengembalikan angka dengan awalan Rp.
    return 'Rp $formatted';
  }

  // Memeriksa data, meminta konfirmasi, dan menyimpan pesanan.
  Future<void> _handleCheckout(CartProvider cart) async {
    // Mencegah checkout dijalankan berulang kali.
    if (isCheckingOut) return;

    // Mengambil informasi pengguna yang sedang login.
    final user = FirebaseAuth.instance.currentUser;

    // Memastikan pengguna sudah login.
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Silakan login terlebih dahulu.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Memastikan keranjang berisi produk.
    if (cart.cartQuantities.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Keranjang masih kosong.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Mengambil alamat dan menghapus spasi di awal serta akhir.
    final alamat = addressController.text.trim();

    // Memastikan alamat pengiriman sudah diisi.
    if (alamat.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Alamat pengiriman tidak boleh kosong!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Memastikan total pembayaran lebih dari nol.
    if (cart.finalTotal <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Total pesanan tidak valid.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Menampilkan dialog sebelum pesanan benar-benar disimpan.
    final konfirmasi = await showDialog<bool>(
      context: context, // Menentukan konteks untuk menampilkan dialog.
      barrierDismissible: false, // Dialog tidak bisa ditutup dengan mengetuk luar.
      builder: (dialogContext) {
        // AlertDialog menampilkan ringkasan sebelum checkout.
        return AlertDialog(
          // Memberikan warna latar krem pada dialog.
          backgroundColor: const Color(0xFFFFF8E7),

          // Membuat sudut dialog melengkung.
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),

          // Judul dialog konfirmasi.
          title: const Text(
            'Konfirmasi Checkout',
            style: TextStyle(
              color: Color(0xFF3E2723),
              fontWeight: FontWeight.bold,
            ),
          ),

          // SingleChildScrollView mencegah isi dialog terpotong.
          content: SingleChildScrollView(
            // Column menyusun informasi dari atas ke bawah.
            child: Column(
              mainAxisSize: MainAxisSize.min, // Tinggi mengikuti isi.
              crossAxisAlignment: CrossAxisAlignment.start, // Rata kiri.
              children: [
                // Memberikan petunjuk sebelum pesanan dikonfirmasi.
                const Text(
                  'Periksa kembali pesanan kamu sebelum melanjutkan.',
                  style: TextStyle(
                    color: Color(0xFF5D4037),
                  ),
                ),

                // Memberikan jarak antarbagian.
                const SizedBox(height: 18),

                // Label alamat pengiriman.
                const Text(
                  'Alamat Pengiriman',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF3E2723),
                  ),
                ),

                // Memberikan jarak sebelum alamat.
                const SizedBox(height: 5),

                // Menampilkan alamat yang telah dimasukkan.
                Text(
                  alamat,
                  style: const TextStyle(
                    color: Color(0xFF5D4037),
                  ),
                ),

                // Memberikan jarak sebelum metode pembayaran.
                const SizedBox(height: 16),

                // Label metode pembayaran.
                const Text(
                  'Metode Pembayaran',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF3E2723),
                  ),
                ),

                // Memberikan jarak sebelum detail pembayaran.
                const SizedBox(height: 5),

                // Row menyusun ikon dan nama pembayaran secara mendatar.
                Row(
                  children: [
                    // Ikon berubah sesuai metode yang dipilih.
                    Icon(
                      metodePembayaran == 'QRIS'
                          ? Icons.qr_code_2
                          : Icons.payments_outlined,
                      color: const Color(0xFF8D6E63),
                    ),

                    // Memberikan jarak antara ikon dan teks.
                    const SizedBox(width: 8),

                    // Menampilkan metode pembayaran yang dipilih.
                    Text(
                      metodePembayaran,
                      style: const TextStyle(
                        color: Color(0xFF5D4037),
                      ),
                    ),
                  ],
                ),

                // Memberikan jarak sebelum garis pemisah.
                const SizedBox(height: 16),

                // Divider memisahkan detail pembayaran dan total.
                const Divider(
                  color: Color(0xFFD7C6AE),
                ),

                // Memberikan jarak setelah garis pemisah.
                const SizedBox(height: 8),

                // Label total pembayaran.
                const Text(
                  'Total Pembayaran',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF3E2723),
                  ),
                ),

                // Memberikan jarak sebelum nominal total.
                const SizedBox(height: 5),

                // Menampilkan total akhir dalam format rupiah.
                Text(
                  _formatRupiah(cart.finalTotal),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF8D6E63),
                  ),
                ),
              ],
            ),
          ),

          // Actions berisi tombol yang tersedia pada dialog.
          actions: [
            // TextButton digunakan untuk kembali memeriksa pesanan.
            TextButton(
              onPressed: () {
                // Mengirim nilai false untuk membatalkan checkout.
                Navigator.of(dialogContext).pop(false);
              },
              child: const Text(
                'Periksa Lagi',
                style: TextStyle(
                  color: Color(0xFF8D6E63),
                ),
              ),
            ),

            // ElevatedButton digunakan untuk mengonfirmasi checkout.
            ElevatedButton(
              // Mengatur warna tombol konfirmasi.
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFD700),
                foregroundColor: const Color(0xFF3E2723),
              ),
              onPressed: () {
                // Mengirim nilai true jika pengguna menyetujui checkout.
                Navigator.of(dialogContext).pop(true);
              },
              child: const Text('Ya, Checkout'),
            ),
          ],
        );
      },
    );

    // Menghentikan proses jika pengguna membatalkan dialog.
    if (konfirmasi != true || !mounted) return;

    // Memperbarui tampilan saat checkout mulai berjalan.
    setState(() {
      isCheckingOut = true;
    });

    try {
      // Mengambil subtotal sebelum keranjang dikosongkan.
      final int subtotal = cart.grandTotal;

      // Mengambil biaya pengiriman.
      final int ongkir = cart.shippingCost;

      // Mengambil jumlah diskon yang digunakan.
      final int diskon = cart.discount;

      // Mengambil total akhir pembayaran.
      final int total = cart.finalTotal;

      // Menyalin detail produk untuk disimpan sebagai riwayat pesanan.
      final List<Map<String, dynamic>> items =
      cart.cartQuantities.entries.map((entry) {
        // Mencari produk berdasarkan ID pada keranjang.
        final product = cart.products.firstWhere(
              (item) => item.id == entry.key,
        );

        // Mengembalikan data produk dan jumlah yang dipesan.
        return {
          'productId': product.id, // Menyimpan ID produk.
          'productName': product.name, // Menyimpan nama produk.
          'price': product.price, // Menyimpan harga satuan.
          'qty': entry.value, // Menyimpan jumlah produk.
        };
      }).toList();

      // Menambahkan pesanan baru ke koleksi Firestore.
      await FirebaseFirestore.instance
          .collection('orders')
          .add({
        'userId': user.uid, // Menyimpan ID pengguna.
        'address': alamat, // Menyimpan alamat pengiriman.
        'paymentMethod': metodePembayaran, // Menyimpan metode pembayaran.
        'date': FieldValue.serverTimestamp(), // Menyimpan waktu dari server.
        'items': items, // Menyimpan daftar produk yang dibeli.
        'subtotal': subtotal, // Menyimpan subtotal.
        'shippingCost': ongkir, // Menyimpan ongkos kirim.
        'discount': diskon, // Menyimpan nilai diskon.
        'discountUsed': diskon > 0, // Menandai apakah diskon digunakan.
        'totalPrice': total, // Menyimpan total pembayaran.
        'status': 'Menunggu Konfirmasi', // Status awal pesanan.
      });

      // Memastikan halaman masih aktif sebelum memperbarui tampilan.
      if (!mounted) return;

      // Menghapus setiap produk dari keranjang setelah pesanan tersimpan.
      for (final entry in cart.cartQuantities.entries.toList()) {
        // Mencari produk berdasarkan ID.
        final product = cart.products.firstWhere(
              (item) => item.id == entry.key,
        );

        // Mengatur jumlah produk menjadi nol.
        cart.updateQuantity(product, 0);
      }

      // Membatalkan status Golden Ticket setelah checkout.
      cart.cancelDiscount();

      // Mengosongkan kolom alamat setelah checkout berhasil.
      addressController.clear();

      // Menampilkan pesan keberhasilan checkout.
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Checkout berhasil! Pesanan tersimpan.'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      // Memastikan halaman masih aktif sebelum menampilkan pesan.
      if (!mounted) return;

      // Menampilkan pesan jika proses checkout mengalami kesalahan.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal checkout: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      // Mengembalikan status checkout setelah proses selesai.
      if (mounted) {
        setState(() {
          isCheckingOut = false;
        });
      }
    }
  }

  @override
  // Menyusun seluruh tampilan halaman keranjang.
  Widget build(BuildContext context) {
    // Scaffold menjadi kerangka utama halaman.
    return Scaffold(
      // Latar transparan mengikuti tema aplikasi.
      backgroundColor: Colors.transparent,

      // SafeArea menjaga konten agar tidak tertutup status bar.
      body: SafeArea(
        // Consumer memperbarui tampilan saat data CartProvider berubah.
        child: Consumer<CartProvider>(
          builder: (context, cart, child) {
            // Mengambil produk yang jumlahnya lebih dari nol.
            final List<Product> cartItems = cart.products
                .where(
                  (product) =>
              (cart.cartQuantities[product.id] ?? 0) > 0,
            )
                .toList();

            // Mengambil jumlah seluruh produk di keranjang.
            final int totalItems = cart.totalItems;

            // Mengambil subtotal produk.
            final int subtotal = cart.grandTotal;

            // Mengambil biaya pengiriman.
            final int ongkir = cart.shippingCost;

            // Mengambil jumlah diskon.
            final int diskon = cart.discount;

            // Mengambil total akhir pembayaran.
            final int totalAkhir = cart.finalTotal;

            // SingleChildScrollView membuat seluruh isi bisa digulir.
            return SingleChildScrollView(
              // Memberikan jarak di sekitar konten.
              padding: const EdgeInsets.only(
                top: 40,
                left: 20,
                right: 20,
                bottom: 32,
              ),

              // Column menyusun seluruh bagian halaman dari atas ke bawah.
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Row berisi judul keranjang dan jumlah produk.
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Expanded menyediakan ruang untuk judul.
                      const Expanded(
                        // Menampilkan judul halaman keranjang.
                        child: Text(
                          'Keranjang Ajaib',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFFFD700),
                            fontFamily: 'Serif',
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),

                      // Menampilkan jumlah produk dalam keranjang.
                      Text(
                        '$totalItems produk',
                        style: const TextStyle(
                          color: Color(0xFFFFD700),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),

                  // Memberikan jarak setelah judul.
                  const SizedBox(height: 20),

                  // Memeriksa apakah keranjang kosong.
                  if (cartItems.isEmpty)
                  // Container menjadi latar informasi keranjang kosong.
                    Container(
                      width: double.infinity, // Mengisi lebar yang tersedia.
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF8E7),
                        borderRadius: BorderRadius.circular(16),
                      ),

                      // Column menyusun ikon dan pesan secara vertikal.
                      child: const Column(
                        children: [
                          // Ikon yang menunjukkan keranjang kosong.
                          Icon(
                            Icons.shopping_cart_outlined,
                            size: 48,
                            color: Color(0xFF8D6E63),
                          ),

                          // Memberikan jarak antara ikon dan pesan.
                          SizedBox(height: 12),

                          // Pesan ketika belum ada produk.
                          Text(
                            'Keranjang masih kosong.',
                            style: TextStyle(
                              color: Color(0xFF5D4037),
                              fontSize: 16,
                            ),
                          ),

                          // Memberikan jarak sebelum petunjuk.
                          SizedBox(height: 4),

                          // Mengarahkan pengguna untuk memilih produk.
                          Text(
                            'Pilih cokelat favoritmu di halaman Home.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Color(0xFF8D6E63),
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                  // ListView menampilkan produk yang ada di keranjang.
                    ListView.builder(
                      shrinkWrap: true, // Menyesuaikan tinggi dengan isi.
                      physics: const NeverScrollableScrollPhysics(),
                      // Scroll mengikuti SingleChildScrollView di luar.
                      itemCount: cartItems.length, // Jumlah kartu produk.
                      itemBuilder: (context, index) {
                        // Mengambil produk sesuai urutan daftar.
                        final product = cartItems[index];

                        // Mengambil jumlah produk yang dipilih.
                        final qty = cart.cartQuantities[product.id] ?? 0;

                        // Membuat tampilan untuk produk tersebut.
                        return _buildCartItem(product, qty, cart);
                      },
                    ),

                  // Memberikan jarak setelah daftar produk.
                  const SizedBox(height: 20),

                  // Container menampilkan informasi Golden Ticket.
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF8E7),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: const Color(0xFFFFD700),
                      ),
                    ),

                    // Row menyusun ikon, keterangan, dan status diskon.
                    child: Row(
                      children: [
                        // Ikon tiket Golden Ticket.
                        const Icon(
                          Icons.confirmation_number,
                          color: Color(0xFF8D6E63),
                          size: 30,
                        ),

                        // Memberikan jarak antara ikon dan keterangan.
                        const SizedBox(width: 12),

                        // Expanded menyediakan ruang untuk informasi diskon.
                        Expanded(
                          // Column menyusun judul dan status diskon.
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Nama program diskon.
                              const Text(
                                'Golden Ticket',
                                style: TextStyle(
                                  color: Color(0xFF3E2723),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),

                              // Memberikan jarak setelah judul.
                              const SizedBox(height: 4),

                              // Pesan berubah sesuai status klaim diskon.
                              Text(
                                cart.isDiscountClaimed
                                    ? 'Diskon Rp 15.000 berhasil diklaim!'
                                    : 'Klaim Golden Ticket di Home untuk mendapat diskon.',
                                style: const TextStyle(
                                  color: Color(0xFF795548),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Ikon berubah sesuai status Golden Ticket.
                        Icon(
                          cart.isDiscountClaimed
                              ? Icons.check_circle
                              : Icons.card_giftcard,
                          color: cart.isDiscountClaimed
                              ? Colors.green
                              : const Color(0xFF8D6E63),
                        ),
                      ],
                    ),
                  ),

                  // Memberikan jarak sebelum ringkasan pembayaran.
                  const SizedBox(height: 20),

                  // Container membungkus rincian biaya pesanan.
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF8E7)
                          .withValues(alpha: 0.98),
                      borderRadius: BorderRadius.circular(18),
                    ),

                    // Column menyusun rincian pembayaran.
                    child: Column(
                      children: [
                        // Menampilkan jumlah harga seluruh produk.
                        _buildSummaryRow(
                          'Subtotal',
                          _formatRupiah(subtotal),
                          const Color(0xFF5D4037),
                        ),

                        // Memberikan jarak antarbaris.
                        const SizedBox(height: 12),

                        // Menampilkan ongkos pengiriman.
                        _buildSummaryRow(
                          'Ongkos kirim',
                          _formatRupiah(ongkir),
                          const Color(0xFF5D4037),
                        ),

                        // Memberikan jarak sebelum informasi diskon.
                        const SizedBox(height: 12),

                        // Menampilkan nilai diskon yang digunakan.
                        _buildSummaryRow(
                          'Diskon',
                          diskon > 0
                              ? '- ${_formatRupiah(diskon)}'
                              : _formatRupiah(0),
                          diskon > 0
                              ? Colors.green
                              : const Color(0xFF8D6E63),
                        ),

                        // Divider memisahkan rincian dan total akhir.
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 14),
                          child: Divider(
                            color: Color(0xFFD7C6AE),
                          ),
                        ),

                        // Row menampilkan label dan total akhir.
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Label total pembayaran.
                            const Text(
                              'Total',
                              style: TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF3E2723),
                              ),
                            ),

                            // Flexible mencegah nominal terlalu lebar.
                            Flexible(
                              // Menampilkan total yang harus dibayar.
                              child: Text(
                                _formatRupiah(totalAkhir),
                                textAlign: TextAlign.end,
                                style: const TextStyle(
                                  fontSize: 19,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF3E2723),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Memberikan jarak sebelum bagian alamat.
                  const SizedBox(height: 28),

                  // Judul untuk kolom alamat pengiriman.
                  const Text(
                    'Alamat Pengiriman',
                    style: TextStyle(
                      color: Color(0xFFFFD700),
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                    ),
                  ),

                  // Memberikan jarak sebelum input alamat.
                  const SizedBox(height: 10),

                  // TextField digunakan untuk memasukkan alamat lengkap.
                  TextField(
                    controller: addressController, // Mengelola isi alamat.
                    maxLines: 3, // Menyediakan tiga baris teks.
                    style: const TextStyle(color: Colors.white),

                    // Mengatur tampilan kolom alamat.
                    decoration: InputDecoration(
                      hintText: 'Masukkan alamat lengkap...',
                      hintStyle: const TextStyle(color: Colors.white70),
                      filled: true, // Mengaktifkan warna latar.
                      fillColor: Colors.white.withValues(alpha: 0.10),
                      contentPadding: const EdgeInsets.all(16),

                      // Border normal ketika kolom belum dipilih.
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Colors.white38,
                        ),
                      ),

                      // Border ketika kolom tidak sedang aktif.
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Colors.white38,
                        ),
                      ),

                      // Border ketika pengguna mengetik alamat.
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Color(0xFFFFD700),
                          width: 2,
                        ),
                      ),
                    ),
                  ),

                  // Memberikan jarak sebelum metode pembayaran.
                  const SizedBox(height: 24),

                  // Judul bagian pilihan pembayaran.
                  const Text(
                    'Metode Pembayaran',
                    style: TextStyle(
                      color: Color(0xFFFFD700),
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                    ),
                  ),

                  // Memberikan jarak sebelum pilihan QRIS.
                  const SizedBox(height: 10),

                  // Container membungkus pilihan pembayaran QRIS.
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(12),

                      // Warna garis mengikuti pilihan pembayaran.
                      border: Border.all(
                        color: metodePembayaran == 'QRIS'
                            ? const Color(0xFFFFD700)
                            : Colors.white24,
                      ),
                    ),

                    // RadioListTile menampilkan opsi QRIS yang bisa dipilih.
                    child: RadioListTile<String>(
                      value: 'QRIS', // Nilai untuk metode QRIS.
                      groupValue: metodePembayaran, // Pilihan saat ini.
                      activeColor: const Color(0xFFFFD700),

                      // Nama metode pembayaran.
                      title: const Text(
                        'QRIS',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      // Penjelasan singkat metode QRIS.
                      subtitle: const Text(
                        'Pembayaran melalui scan QR',
                        style: TextStyle(color: Colors.white70),
                      ),

                      // Ikon untuk pembayaran QRIS.
                      secondary: const Icon(
                        Icons.qr_code_2,
                        color: Color(0xFFFFD700),
                        size: 32,
                      ),

                      // Pilihan dinonaktifkan selama checkout.
                      onChanged: isCheckingOut
                          ? null
                          : (value) {
                        // Memastikan nilai pilihan tidak kosong.
                        if (value != null) {
                          // Memperbarui metode pembayaran yang dipilih.
                          setState(() {
                            metodePembayaran = value;
                          });
                        }
                      },
                    ),
                  ),

                  // Memberikan jarak antara opsi pembayaran.
                  const SizedBox(height: 10),

                  // Container membungkus pilihan pembayaran tunai.
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(12),

                      // Memberi tanda pada opsi tunai yang dipilih.
                      border: Border.all(
                        color: metodePembayaran == 'Tunai'
                            ? const Color(0xFFFFD700)
                            : Colors.white24,
                      ),
                    ),

                    // RadioListTile menampilkan opsi pembayaran tunai.
                    child: RadioListTile<String>(
                      value: 'Tunai', // Nilai untuk pembayaran tunai.
                      groupValue: metodePembayaran, // Pilihan saat ini.
                      activeColor: const Color(0xFFFFD700),

                      // Nama metode pembayaran.
                      title: const Text(
                        'Tunai',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      // Penjelasan pembayaran secara tunai.
                      subtitle: const Text(
                        'Bayar tunai saat pesanan diterima',
                        style: TextStyle(color: Colors.white70),
                      ),

                      // Ikon untuk pembayaran tunai.
                      secondary: const Icon(
                        Icons.payments_outlined,
                        color: Color(0xFFFFD700),
                        size: 32,
                      ),

                      // Pilihan dinonaktifkan selama checkout.
                      onChanged: isCheckingOut
                          ? null
                          : (value) {
                        // Memastikan nilai pilihan tidak kosong.
                        if (value != null) {
                          // Menyimpan metode pembayaran yang dipilih.
                          setState(() {
                            metodePembayaran = value;
                          });
                        }
                      },
                    ),
                  ),

                  // Memberikan jarak sebelum tombol checkout.
                  const SizedBox(height: 24),

                  // SizedBox mengatur lebar dan tinggi tombol checkout.
                  SizedBox(
                    width: double.infinity, // Tombol memenuhi lebar halaman.
                    height: 55,

                    // ElevatedButton digunakan untuk memproses checkout.
                    child: ElevatedButton(
                      // Tombol tidak aktif jika keranjang kosong atau checkout berjalan.
                      onPressed: cartItems.isEmpty || isCheckingOut
                          ? null
                          : () => _handleCheckout(cart),

                      // Mengatur warna dan bentuk tombol checkout.
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFD700),
                        disabledBackgroundColor: Colors.grey.shade700,
                        foregroundColor: const Color(0xFF3E2723),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),

                      // Menampilkan loading atau tulisan checkout.
                      child: isCheckingOut
                          ? const SizedBox(
                        width: 24,
                        height: 24,

                        // CircularProgressIndicator menandakan proses berjalan.
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          color: Color(0xFF3E2723),
                        ),
                      )
                          : const Text(
                        'Checkout',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  // Memberikan jarak di bagian bawah halaman.
                  const SizedBox(height: 24),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // Membuat kartu untuk satu produk di keranjang.
  Widget _buildCartItem(Product product, int qty, CartProvider cart) {
    // Container menjadi latar kartu produk.
    return Container(
      margin: const EdgeInsets.only(bottom: 14), // Jarak antarproduk.
      padding: const EdgeInsets.all(12), // Jarak isi dari tepi kartu.
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E7).withValues(alpha: 0.98),
        borderRadius: BorderRadius.circular(16),
      ),

      // Row menyusun gambar dan informasi produk secara mendatar.
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ClipRRect membuat sudut gambar menjadi melengkung.
          ClipRRect(
            borderRadius: BorderRadius.circular(12),

            // Menampilkan gambar produk dari assets.
            child: Image.asset(
              product.image,
              width: 76,
              height: 90,
              fit: BoxFit.cover,

              // Menampilkan pengganti jika gambar tidak dapat dimuat.
              errorBuilder: (context, error, stackTrace) {
                // Container menjadi latar pengganti gambar.
                return Container(
                  width: 76,
                  height: 90,
                  color: const Color(0xFFEADCC8),

                  // Ikon menandakan gambar tidak tersedia.
                  child: const Icon(
                    Icons.image_not_supported_outlined,
                    color: Color(0xFF8D6E63),
                  ),
                );
              },
            ),
          ),

          // Memberikan jarak antara gambar dan informasi.
          const SizedBox(width: 12),

          // Expanded menyediakan ruang untuk informasi produk.
          Expanded(
            // Column menyusun nama, deskripsi, harga, dan jumlah.
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Row berisi nama produk dan tombol hapus.
                Row(
                  children: [
                    // Expanded memberi ruang pada nama produk.
                    Expanded(
                      child: Text(
                        product.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF3E2723),
                          fontSize: 15,
                        ),
                      ),
                    ),

                    // IconButton menghapus produk dari keranjang.
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      tooltip: 'Hapus produk',

                      // Tombol hapus dinonaktifkan selama checkout.
                      onPressed: isCheckingOut
                          ? null
                          : () {
                        // Mengatur jumlah produk menjadi nol.
                        cart.updateQuantity(product, 0);
                      },

                      // Ikon untuk menghapus produk.
                      icon: const Icon(
                        Icons.delete_outline,
                        color: Color(0xFF8D6E63),
                      ),
                    ),
                  ],
                ),

                // Menampilkan deskripsi singkat produk.
                Text(
                  product.desc,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF8D6E63),
                    fontSize: 12,
                  ),
                ),

                // Memberikan jarak sebelum harga dan jumlah.
                const SizedBox(height: 10),

                // Wrap menjaga isi tetap rapi jika ruang terbatas.
                Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    // Menampilkan harga satuan produk.
                    Text(
                      _formatRupiah(product.price),
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF3E2723),
                        fontSize: 14,
                      ),
                    ),

                    // Row menyusun tombol pengatur jumlah produk.
                    Row(
                      mainAxisSize: MainAxisSize.min,

                      children: [
                        // IconButton mengurangi jumlah produk.
                        IconButton(
                          visualDensity: VisualDensity.compact,
                          constraints: const BoxConstraints(
                            minWidth: 32,
                            minHeight: 32,
                          ),

                          // Tombol tidak aktif selama checkout.
                          onPressed: isCheckingOut
                              ? null
                              : () {
                            // Mengurangi jumlah produk sebanyak satu.
                            cart.updateQuantity(product, qty - 1);
                          },

                          // Ikon untuk mengurangi jumlah.
                          icon: const Icon(
                            Icons.remove_circle_outline,
                            color: Color(0xFF3E2723),
                          ),
                        ),

                        // Text menampilkan jumlah produk saat ini.
                        Text(
                          '$qty',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF3E2723),
                            fontSize: 15,
                          ),
                        ),

                        // IconButton menambah jumlah produk.
                        IconButton(
                          visualDensity: VisualDensity.compact,
                          constraints: const BoxConstraints(
                            minWidth: 32,
                            minHeight: 32,
                          ),

                          // Tombol tidak aktif selama checkout.
                          onPressed: isCheckingOut
                              ? null
                              : () {
                            // Menambah jumlah produk sebanyak satu.
                            cart.updateQuantity(product, qty + 1);
                          },

                          // Ikon untuk menambah jumlah.
                          icon: const Icon(
                            Icons.add_circle_outline,
                            color: Color(0xFF3E2723),
                          ),
                        ),
                      ],
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

  // Membuat satu baris informasi pada ringkasan pembayaran.
  Widget _buildSummaryRow(String label, String value, Color valueColor) {
    // Row menyusun label dan nilai secara mendatar.
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Menampilkan nama rincian pembayaran.
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF5D4037),
            fontSize: 15,
          ),
        ),

        // Memberikan jarak minimum antara label dan nilai.
        const SizedBox(width: 12),

        // Flexible memberi ruang agar nominal tidak meluap.
        Flexible(
          // Menampilkan nilai subtotal, ongkir, atau diskon.
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: TextStyle(
              color: valueColor, // Warna nilai sesuai jenis rincian.
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
        ),
      ],
    );
  }
}