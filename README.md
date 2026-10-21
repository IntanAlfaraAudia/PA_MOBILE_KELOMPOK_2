# PA_Mobile_Kelompok2
# 🍫 WonkaStore — Aplikasi Toko Cokelat

## 📖 Deskripsi Aplikasi

**WonkaStore** adalah aplikasi toko cokelat berbasis mobile yang dikembangkan menggunakan Flutter dan Dart. Aplikasi ini dirancang untuk memudahkan pengguna melihat katalog produk cokelat, memilih produk favorit, memasukkan produk ke keranjang, dan melakukan checkout.

Aplikasi ini menggunakan Firebase sebagai layanan autentikasi dan database untuk menyimpan serta mengelola data pengguna, produk favorit, dan riwayat pesanan.

### ✨ Fitur Aplikasi

- **Login dan Registrasi:** Pengguna dapat membuat akun dan masuk ke aplikasi.
- **Katalog Produk:** Menampilkan berbagai produk cokelat beserta informasi produknya.
- **Pencarian Produk:** Memudahkan pengguna menemukan produk yang diinginkan.
- **Favorit:** Menyimpan produk favorit pengguna.
- **Keranjang Belanja:** Menambahkan produk dan mengatur jumlah pembelian.
- **Checkout:** Menghitung subtotal, ongkos kirim, diskon, dan total pembayaran.
- **Metode Pembayaran:** Menyediakan pilihan QRIS dan tunai.
- **Profil Pengguna:** Menampilkan informasi akun pengguna.
- **Riwayat Pesanan:** Menampilkan data pesanan yang tersimpan.
- **Bantuan:** Menyediakan informasi bantuan dan FAQ.

## ⚙️ Cara Kerja Aplikasi

1. Pengguna membuka aplikasi WonkaStore.
2. Pengguna melakukan registrasi atau login menggunakan akun yang terdaftar.
3. Setelah berhasil masuk, pengguna dapat melihat katalog dan mencari produk cokelat.
4. Pengguna dapat memilih produk favorit dan menambahkan produk ke keranjang.
5. Pada halaman keranjang, aplikasi menghitung subtotal, ongkos kirim, diskon jika tersedia, dan total pembayaran.
6. Pengguna memilih metode pembayaran, yaitu QRIS atau tunai, kemudian melakukan checkout.
7. Data pesanan disimpan ke Cloud Firestore agar dapat digunakan untuk menampilkan riwayat pesanan.
8. Pengguna dapat membuka halaman profil untuk melihat informasi akun dan riwayat pesanan.

Pengelolaan state keranjang menggunakan **Provider**, sehingga perubahan jumlah produk dan total belanja dapat diperbarui pada tampilan aplikasi.

## 🔥 Teknologi yang Digunakan

| Teknologi | Kegunaan |
|---|---|
| Flutter | Framework untuk membangun aplikasi mobile |
| Dart | Bahasa pemrograman aplikasi |
| Firebase Authentication | Mengelola login dan registrasi pengguna |
| Cloud Firestore | Menyimpan data pengguna, favorit, dan pesanan |
| Provider | Mengelola state aplikasi, terutama keranjang belanja |

## 🗄️ Cara Menghubungkan Aplikasi dengan Firebase

### 1. Membuat Proyek Firebase

1. Buka [Firebase Console](https://console.firebase.google.com/).
2. Buat proyek baru atau gunakan proyek Firebase yang sudah tersedia.
3. Tambahkan aplikasi Android ke proyek Firebase.
4. Masukkan **package name/application ID** yang sesuai dengan konfigurasi proyek Flutter.
5. Unduh file `google-services.json` dan letakkan di folder:

   ```text
   android/app/google-services.json
   ```

### 2. Mengaktifkan Firebase Authentication

1. Buka menu **Authentication** di Firebase Console.
2. Pilih **Get started**.
3. Buka bagian **Sign-in method**.
4. Aktifkan metode **Email/Password**.

Fitur ini digunakan untuk proses registrasi dan login pengguna.

### 3. Membuat Cloud Firestore

1. Buka menu **Firestore Database** di Firebase Console.
2. Pilih **Create database**.
3. Tentukan lokasi database.
4. Atur **Security Rules** agar pengguna hanya dapat mengakses data yang menjadi haknya.

Jangan menggunakan aturan database terbuka seperti `allow read, write: if true` untuk aplikasi yang digunakan secara nyata.

### 4. Mengatur Konfigurasi Firebase pada Flutter

Proyek ini menggunakan file `lib/firebase_options.dart` untuk konfigurasi Firebase. Jika konfigurasi belum sesuai dengan proyek Firebase milikmu, jalankan perintah berikut dari terminal di folder utama proyek:

```bash
dart pub global activate flutterfire_cli
flutterfire configure
```

Pilih proyek Firebase yang sesuai. Pastikan konfigurasi Android dan platform lain yang digunakan sudah benar.

### 5. Menginstal Dependensi dan Menjalankan Aplikasi

Jalankan perintah berikut di terminal:

```bash
flutter pub get
flutter run
```

Pastikan perangkat Android atau emulator sudah terhubung sebelum menjalankan aplikasi.

## 📂 Struktur Proyek

```text
lib/
├── main.dart
├── firebase_options.dart
├── auth_gate.dart
├── login_page.dart
├── main_screen.dart
├── models/
│   └── product.dart
├── pages/
│   ├── home_page.dart
│   ├── cart_page.dart
│   └── profile_page.dart
└── providers/
    └── cart_provider.dart

android/
└── app/
    └── google-services.json
```

*Catatan: Struktur di atas merupakan gambaran file utama proyek. File atau folder tambahan dapat tersedia sesuai implementasi aplikasi.*

## 📊 Struktur Data Cloud Firestore

### 1. Collection `users`

Menyimpan informasi pengguna.

Contoh struktur:

```text
users/
└── {uid}
    ├── name
    └── points
```

- `name`: nama pengguna.
- `points`: jumlah poin pengguna.

### 2. Subcollection `favorites`

Menyimpan produk favorit milik pengguna.

```text
users/
└── {uid}/
    └── favorites/
        └── {productId}
            ├── productId
            ├── name
            ├── price
            ├── description
            ├── image
            └── createdAt
```

### 3. Collection `orders`

Menyimpan data transaksi atau pesanan.

```text
orders/
└── {orderId}
    ├── userId
    ├── address
    ├── date
    ├── items
    ├── subtotal
    ├── shippingCost
    ├── discount
    ├── discountUsed
    ├── totalPrice
    ├── paymentMethod
    └── status
```

Keterangan:

- `userId`: ID pengguna yang melakukan pesanan.
- `address`: alamat pengiriman.
- `date`: tanggal pesanan.
- `items`: daftar produk dan jumlah yang dipesan.
- `subtotal`: total harga produk sebelum biaya tambahan dan diskon.
- `shippingCost`: biaya pengiriman.
- `discount`: jumlah diskon.
- `discountUsed`: informasi penggunaan diskon.
- `totalPrice`: total pembayaran.
- `paymentMethod`: metode pembayaran yang dipilih.
- `status`: status pesanan.

Nama field dan struktur data perlu disesuaikan apabila implementasi kode atau database mengalami perubahan.

## 🚀 Cara Menjalankan Aplikasi

1. Clone atau unduh repository proyek WonkaStore.
2. Buka folder proyek di Visual Studio Code atau IDE yang mendukung Flutter.
3. Pastikan Flutter SDK telah terpasang.
4. Periksa konfigurasi Firebase dan file `google-services.json`.
5. Pastikan Firebase Authentication dan Cloud Firestore telah diaktifkan.
6. Jalankan perintah:

   ```bash
   flutter pub get
   flutter run
   ```

7. Registrasi akun baru atau login menggunakan akun yang sudah tersedia.
8. Uji fitur katalog produk, favorit, keranjang, checkout, dan riwayat pesanan.

## 📝 Catatan Pengembangan

- Firebase Authentication digunakan untuk autentikasi pengguna.
- Cloud Firestore digunakan untuk menyimpan data favorit dan riwayat pesanan.
- Provider digunakan untuk mengelola state keranjang belanja.
- Data katalog dan stok produk yang masih disimpan dalam memori aplikasi belum otomatis menjadi data permanen di Firestore.
- Pilihan QRIS pada aplikasi belum tentu terhubung ke penyedia pembayaran atau melakukan verifikasi pembayaran otomatis.
- Untuk penggunaan produksi, validasi harga, stok, diskon, total transaksi, dan status pembayaran sebaiknya dilakukan melalui backend tepercaya.
- Security Rules Firestore harus dikonfigurasi untuk membatasi akses data berdasarkan identitas pengguna.

---

**WonkaStore — Temukan Cokelat Favoritmu! 🍫**
