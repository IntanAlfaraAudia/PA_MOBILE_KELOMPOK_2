import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/product.dart';

class CartProvider extends ChangeNotifier {
  // ============================================
  // KATALOG PRODUK COKELAT WONKA
  // ============================================

  final List<Product> _products = [
    Product(
      id: 'p1',
      name: 'The Wonka Bar',
      desc: 'Cokelat klasik berbalut kertas buatan tangan. Peninggalan ibu.',
      price: 150000,
      image: 'assets/wonka_bar.jpeg',
    ),
    Product(
      id: 'p2',
      name: 'Silver Lining',
      desc: 'Awan badai dan sinar matahari cair. Memberi secercah harapan.',
      price: 65000,
      image: 'assets/silver_lining.jpeg',
    ),
    Product(
      id: 'p3',
      name: 'Hair Repair Éclair',
      desc: 'Campuran keringat Yeti untuk menumbuhkan rambut lebat.',
      price: 120000,
      image: 'assets/hair_repair.jpeg',
    ),
    Product(
      id: 'p4',
      name: 'Big Night Out',
      desc: 'Sensasi malam di perkotaan dalam satu gigitan truffle mewah.',
      price: 85000,
      image: 'assets/big_night_out.jpeg',
    ),
    Product(
      id: 'p5',
      name: 'Acacia Mint',
      desc: 'Permen mint khusus kesukaan Abigail sang jerapah.',
      price: 35000,
      image: 'assets/acacia_mint.jpeg',
    ),
    Product(
      id: 'p6',
      name: 'Giraffe Milk Macaroon',
      desc:
          'Susu jerapah distilasi. Rasakan sensasi menjadi yang paling tinggi.',
      price: 70000,
      image: 'assets/giraffe_milk.jpeg',
    ),
    Product(
      id: 'p7',
      name: 'Forty Second Sweet',
      desc: 'Seketika membuatmu bernyanyi dan menari ala Broadway.',
      price: 45000,
      image: 'assets/forty_second.jpeg',
    ),
    Product(
      id: 'p8',
      name: 'Hoverchoc',
      desc: 'Karamel asin dengan hover-fly yang membuatmu bisa melayang.',
      price: 55000,
      image: 'assets/hoverchoc.jpeg',
    ),
  ];

  // ============================================
  // DATA KERANJANG DAN STATUS DISKON
  // ============================================

  // Menyimpan jumlah setiap produk berdasarkan ID.
  final Map<String, int> _cartQuantities = {};

  // Status Golden Ticket.
  // Default false berarti diskon belum digunakan.
  bool _isDiscountClaimed = false;

  // Besaran diskon dan ongkos kirim.
  static const int discountAmount = 15000;
  static const int shippingAmount = 10000;

  // ============================================
  // GETTER
  // ============================================

  // Mengambil daftar produk.
  List<Product> get products => _products;

  // Mengambil jumlah produk di keranjang.
  Map<String, int> get cartQuantities => _cartQuantities;

  // Memeriksa apakah diskon sudah diklaim.
  bool get isDiscountClaimed => _isDiscountClaimed;

  // Menghitung total kuantitas produk di keranjang.
  int get totalItems {
    return _cartQuantities.values.fold(
      0,
      (total, quantity) => total + quantity,
    );
  }

  // Menghitung subtotal sebelum ongkir dan diskon.
  int get grandTotal {
    return _products.fold(0, (total, product) {
      final quantity = _cartQuantities[product.id] ?? 0;
      return total + (product.price * quantity);
    });
  }

  // Ongkos kirim hanya berlaku jika keranjang tidak kosong.
  int get shippingCost {
    return grandTotal > 0 ? shippingAmount : 0;
  }

  // Diskon hanya berlaku jika:
  // 1. Golden Ticket sudah diklaim dari halaman Home.
  // 2. Keranjang memiliki produk.
  int get discount {
    if (_isDiscountClaimed && grandTotal > 0) {
      return discountAmount;
    }

    return 0;
  }

  // Menghitung total akhir setelah ongkir dan diskon.
  int get finalTotal {
    final total = grandTotal + shippingCost - discount;
    return total > 0 ? total : 0;
  }

  // ============================================
  // GOLDEN TICKET
  // ============================================

  // Dipanggil ketika pengguna menekan tombol Klaim
  // pada halaman Home.
  void claimDiscount() {
    // Tidak melakukan apa-apa jika sudah diklaim.
    if (_isDiscountClaimed) return;

    // Aktifkan diskon.
    _isDiscountClaimed = true;

    // Perbarui tampilan semua halaman yang memakai Provider.
    notifyListeners();
  }

  // Membatalkan klaim jika diperlukan.
  void cancelDiscount() {
    if (!_isDiscountClaimed) return;

    _isDiscountClaimed = false;
    notifyListeners();
  }

  // ============================================
  // MENGELOLA KERANJANG
  // ============================================

  // Menambahkan produk ke keranjang jika stok tersedia.
  void addToCart(Product product) {
    if (product.stock <= 0) return;

    product.stock--;

    _cartQuantities[product.id] = (_cartQuantities[product.id] ?? 0) + 1;

    notifyListeners();
  }

  // Mengubah jumlah produk di keranjang.
  void updateQuantity(Product product, int newQty) {
    final currentQty = _cartQuantities[product.id] ?? 0;

    // Jumlah produk tidak boleh negatif.
    if (newQty < 0) {
      newQty = 0;
    }

    final difference = newQty - currentQty;

    // Pastikan stok cukup jika jumlah ditambah.
    if (difference > 0 && product.stock < difference) {
      return;
    }

    // Mengembalikan atau mengurangi stok sesuai perubahan.
    product.stock -= difference;

    // Menghapus produk jika jumlahnya nol.
    if (newQty == 0) {
      _cartQuantities.remove(product.id);
    } else {
      _cartQuantities[product.id] = newQty;
    }

    notifyListeners();
  }

  // ============================================
  // CHECKOUT DAN FIREBASE
  // ============================================

  Future<void> checkoutOrder(String userId, String address) async {
    // Validasi keranjang.
    if (_cartQuantities.isEmpty) {
      throw Exception('Keranjang masih kosong.');
    }

    // Validasi alamat.
    if (address.trim().isEmpty) {
      throw Exception('Alamat pengiriman belum diisi.');
    }

    // Simpan perhitungan sebelum keranjang dikosongkan.
    final int subtotal = grandTotal;
    final int ongkir = shippingCost;
    final int appliedDiscount = discount;
    final int total = finalTotal;

    // Menyimpan detail produk yang dipesan.
    final List<Map<String, dynamic>> items = _cartQuantities.entries.map((
      entry,
    ) {
      final product = _products.firstWhere((item) => item.id == entry.key);

      return {
        'productId': product.id,
        'productName': product.name,
        'price': product.price,
        'qty': entry.value,
      };
    }).toList();

    // Menyusun data pesanan untuk Firestore.
    final Map<String, dynamic> orderData = {
      'userId': userId,
      'address': address.trim(),
      'date': FieldValue.serverTimestamp(),
      'items': items,
      'subtotal': subtotal,
      'shippingCost': ongkir,
      'discount': appliedDiscount,
      'discountUsed': appliedDiscount > 0,
      'totalPrice': total,
      'status': 'Menunggu Konfirmasi',
    };

    // Simpan pesanan ke Firestore.
    // Jika penyimpanan gagal, keranjang dan klaim diskon
    // tetap dipertahankan.
    await FirebaseFirestore.instance.collection('orders').add(orderData);

    // Kosongkan keranjang setelah checkout berhasil.
    _cartQuantities.clear();

    // Nonaktifkan diskon setelah checkout berhasil.
    // Pengguna harus mengklaim kembali dari Home
    // untuk menggunakan diskon pada pesanan berikutnya.
    _isDiscountClaimed = false;

    // Perbarui tampilan aplikasi.
    notifyListeners();
  }
}
