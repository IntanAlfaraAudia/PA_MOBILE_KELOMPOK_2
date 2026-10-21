// Class Product digunakan untuk menyimpan data produk
class Product {
  // ID unik untuk setiap produk
  final String id;
  // Nama produk
  final String name;
  // Deskripsi produk
  final String desc;
  // Harga produk dalam bentuk bilangan bulat
  final int price;
  // Lokasi atau URL gambar produk
  final String image;
  // Jumlah stok produk yang dapat berubah
  int stock;

  // Constructor untuk membuat objek Product
  Product({
    // ID wajib diisi saat membuat produk
    required this.id,
    // Nama produk wajib diisi
    required this.name,
    // Deskripsi produk wajib diisi
    required this.desc,
    // Harga produk wajib diisi
    required this.price,
    // Gambar produk wajib diisi
    required this.image,
    // Stok produk secara default bernilai 10
    this.stock = 10,
  });
}