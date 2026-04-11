import 'package:flutter/material.dart';
import '../home/pages/home_page.dart';

import '../catalog/catalog_page.dart';
import '../report/report_page.dart';
import '../transaction/add_transaction_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}


class _MainPageState extends State<MainPage> {
  // 1. Variabel penanda indeks halaman yang sedang diakses (dimulai dari 0 yaitu "Beranda")
  int _currentIndex = 0;

  // 2. Daftar halaman (widget) penampung. Halaman-halaman disiapkan di sini.
  final List<Widget> _pages = [
    // Indeks 0: Beranda sesungguhnya yang kita buat di pertemuan sebelumnya
    const HomePage(),
    // Indeks 1: Halaman Katalog Produk
    const CatalogPage(),
    // Indeks 2: Halaman Dasbor Laporan Arus Kas
    const ReportPage(),
  ];

  // 3. Fungsi yang dijalankan ketika salah satu menu pada Navbar disentuh (Tap)
  void _onItemTapped(int index) {
    // Fungsi setState akan memberitahu Flutter bahwa ada data yang berubah (index),
    // Tolong bangun ulang (rebuild) tampilannya agar beranda berubah ke katalog dsb!
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Warna background standar aplikasi
      backgroundColor: const Color.fromARGB(255, 248, 250, 252),
      
      // 4. Body (badan) dari halaman ini berubah-ubah mengikuti index yang aktif.
      body: _pages[_currentIndex],

      // 5. Membuat tombol mengambang yang akan berguna untuk fitur "Tambah Transaksi"
      floatingActionButton: Container(
        height: 64,
        width: 64,
        margin: const EdgeInsets.only(bottom: 16), // Memberi sedikit jarak ke bawah
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20), // Bentuk melengkung (rounded)
          color: const Color.fromARGB(225, 0, 6, 102),
          boxShadow: [
            BoxShadow(
              color: const Color.fromARGB(225, 0, 6, 102).withValues(alpha: 0.3),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        // Kita menggunakan FloatingActionButton bawaan tapi backgroundColor dibuat transparan
        // agar gradient dari container pembungkusnya bisa terlihat.
        child: FloatingActionButton(
          onPressed: () {
            // Aksi memanggil rute untuk membuka form AddTransactionPage
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AddTransactionPage(),
              ),
            );
          },
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: const Icon(Icons.add, color: Colors.white, size: 32),
        ),
      ),
      // Posisi standar tombol mengambang: Kanan Bawah
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,

      // 6. Membuat Custom Bottom Navigation (Navigasi Bawah Khusus)
      bottomNavigationBar: Container(
        height: 85,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          // Lengkungan hanya di sudut atas saja seperti yang Anda minta
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        // Kita taruh row di dalamnya untuk membuat menu berjejer secara vertikal
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(
              // Mirip logo kotak-kotak beranda
              icon: Icons.dashboard_outlined, 
              label: "BERANDA",
              index: 0,
            ),
            _buildNavItem(
              // Mirip ikon botol parfum penyemprot
              icon: Icons.sanitizer_outlined, 
              label: "KATALOG",
              index: 1,
            ),
            _buildNavItem(
              icon: Icons.bar_chart_outlined,
              label: "LAPORAN",
              index: 2,
            ),
          ],
        ),
      ),
    );
  }

  // 7. Widget Helper: Fungsi untuk mencetak tombol navigasi secara seragam
  // Fungsi ini menerima icon, nama (label), dan nomor identitas urutan (index)
  Widget _buildNavItem({required IconData icon, required String label, required int index}) {
    // Mengecek apakah tombol ini yang saat ini sedang aktif dipilih
    final isSelected = _currentIndex == index;

    // GestureDetector untuk memonitor aksi "Sentuhan Jari" pada item kustom
    return GestureDetector(
      onTap: () => _onItemTapped(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200), // Sedikit efek animasi ketika berpindah tab
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          // Jika dipilih, latar berbentuk *Pill* berwarna biru transparan muncul
          color: isSelected ? const Color(0xFFE8EEFF) : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min, // Agar column membungkus sesuai isi
          children: [
            Icon(
              icon,
              size: 26,
              // Warna biru tua jika terpilih, warna keabu-abuan pucat jika tidak.
              color: isSelected ? const Color(0xFF1E2857) : const Color(0xFFA5B2BE),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Manrope',
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.bold,
                letterSpacing: 1,
                // Sama, ubah warnanya sesuai aktif atau tidak
                color: isSelected ? const Color(0xFF1E2857) : const Color(0xFFA5B2BE),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
