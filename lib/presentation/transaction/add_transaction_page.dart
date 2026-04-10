import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../domain/entities/transaction_entity.dart';
import '../bloc/transaction/transaction_bloc.dart';
import '../bloc/transaction/transaction_event.dart';

class AddTransactionPage extends StatefulWidget {
  const AddTransactionPage({super.key});

  @override
  State<AddTransactionPage> createState() => _AddTransactionPageState();
}

class _AddTransactionPageState extends State<AddTransactionPage> {
  int _qty = 1;
  final TextEditingController _totalController = TextEditingController();
  final TextEditingController _catatanController = TextEditingController();

  // State untuk Toggle: True = Pemasukan (Uang Masuk), False = Pengeluaran (Uang Keluar)
  bool _isPemasukan = true;

  // Data Statis Sementara untuk Pilihan Item/Varian beserta Harga
  final List<Map<String, dynamic>> _variantsData = [
    {'name': 'Baccarat 30ml', 'price': 150000},
    {'name': 'Luxury Oud 50ml', 'price': 450000},
    {'name': 'Midnight Bloom 30ml', 'price': 450000},
    {'name': 'Sweet Vanilla 100ml', 'price': 1200000},
    {'name': 'Botol Kaca Premium', 'price': 21000},
  ];

  late Map<String, dynamic> _selectedVariantData;

  @override
  void initState() {
    super.initState();
    _selectedVariantData = _variantsData.first;
    _updateTotal();
  }

  void _updateTotal() {
    int price = _selectedVariantData['price'] as int;
    int total = price * _qty;
    _totalController.text = NumberFormat.decimalPattern('id').format(total);
  }

  @override
  void dispose() {
    _totalController.dispose();
    _catatanController.dispose();
    super.dispose();
  }

  // Helper untuk format tanggal ala "10 Okt 2026 14:00" tanpa package tambahan
  String _getTodayFormatted() {
    final now = DateTime.now();
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agt',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    final hour = now.hour.toString().padLeft(2, '0');
    final minute = now.minute.toString().padLeft(2, '0');
    return '${now.day} ${months[now.month - 1]} ${now.year} $hour:$minute';
  }

  void _submitData() {
    // Membaca isi TextField dan membersihkan teks jika perlu
    final String numText = _totalController.text.replaceAll(
      RegExp(r'[^0-9]'),
      '',
    );
    final int total = int.tryParse(numText) ?? 0;

    if (total <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tolong masukkan total harga yang benar')),
      );
      return;
    }

    // Menggabungkan Catatan ke Nama Varian sebagai info ekstra
    final String catatan = _catatanController.text.trim();
    final String variantName = _selectedVariantData['name'];
    final String finalNama = catatan.isNotEmpty
        ? '$variantName ($catatan)'
        : '$variantName ($_qty item)'; // Info qty diselipkan jika tidak ada catatan

    // Mempersiapkan Entitas Transaksi yang akan dikirim ke lapisan Domain
    final newTransaction = TransactionEntity(
      nama: finalNama,
      total: total,
      tanggal: _getTodayFormatted(),
      isPemasukan: _isPemasukan,
    );

    // Memicu (trigger) proses penyimpanan di BLoC
    context.read<TransactionBloc>().add(AddTransactionEvent(newTransaction));

    // Kembali ke Beranda setelah sukses mengirim event
    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Transaksi berhasil ditambahkan!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(
        0xFFF8FAFC,
      ), // Warna background putih keabuan ala Figma
      appBar: AppBar(
        title: const Text(
          'Tambah Transaksi',
          style: TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Color(0xFF1E2857),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: Color(0xFF1E2857)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- 1. TOGGLE TIPE TRANSAKSI ---
            const Text(
              "Catat aktivitas keuangan toko Anda hari ini.",
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF454652),
                fontFamily: 'Manrope',
              ),
            ),
            const SizedBox(height: 24),

            // --- 1. TOGGLE TIPE TRANSAKSI ---
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFFF2F4F7),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _isPemasukan = true),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: _isPemasukan
                              ? Colors.white
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: _isPemasukan
                              ? [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.05),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                              : [],
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          "Pemasukan\n(Penjualan)",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: _isPemasukan
                                ? const Color(0xFF000666)
                                : Colors.grey,
                            fontWeight: _isPemasukan
                                ? FontWeight.bold
                                : FontWeight.normal,
                            fontSize: 14,
                            fontFamily: 'Manrope',
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _isPemasukan = false),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: !_isPemasukan
                              ? Colors.white
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: !_isPemasukan
                              ? [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.05),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                              : [],
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          "Pengeluaran\n(Beli Bahan)",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: !_isPemasukan
                                ? const Color(0xFF000666)
                                : Color(0xFF64748B),
                            fontWeight: !_isPemasukan
                                ? FontWeight.bold
                                : FontWeight.normal,
                            fontSize: 14,
                            fontFamily: 'Manrope',
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // --- 2. PILIHAN VARIAN STATIS ---
            const Text(
              "PILIH VARIAN PARFUM",
              style: TextStyle(
                fontFamily: 'Manrope',
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Color(0xFF454652),
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              height: 56,
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<Map<String, dynamic>>(
                  value: _selectedVariantData,
                  isExpanded: true,
                  icon: const Icon(Icons.expand_more, color: Colors.grey),
                  items: _variantsData.map((Map<String, dynamic> data) {
                    return DropdownMenuItem<Map<String, dynamic>>(
                      value: data,
                      child: Text(
                        data['name'],
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                          fontFamily: 'Manrope',
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      _selectedVariantData = newValue!;
                      _updateTotal();
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 24),

            // --- 3. KUANTITAS (QTY) & GAMBAR PREVIEW ---
            const Text(
              "JUMLAH",
              style: TextStyle(
                fontFamily: 'Manrope',
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Color(0xFF454652),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                // Komponen Kotak Kuantitas
                Expanded(
                  flex: 3,
                  child: Container(
                    height: 64,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () {
                            if (_qty > 1) {
                              setState(() {
                                _qty--;
                                _updateTotal();
                              });
                            }
                          },
                          child: const Icon(
                            Icons.remove,
                            color: Color(0xFF1E2857),
                          ),
                        ),
                        Text(
                          "$_qty",
                          style: const TextStyle(
                            fontSize: 18,
                            fontFamily: 'Manrope',
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        // Figma tidak menampilkan ikon (+) yang tebal, namun secara fungsional ditaruh di area kanan angka
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _qty++;
                              _updateTotal();
                            });
                          },
                          child: const Icon(
                            Icons.add,
                            color: Color(0xFF1E2857),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Komponen Gambar Variant
                Expanded(
                  flex: 2,
                  child: Container(
                    height: 64,
                    decoration: BoxDecoration(
                      color: const Color(
                        0xFF131526,
                      ), // Warna gelap pengganti gambar
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      "PREVIEW VARIANT",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // --- 4. TOTAL HARGA ---
            Text(
              "TOTAL",
              style: const TextStyle(
                fontFamily: 'Manrope',
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Color(0xFF454652),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _totalController,
              // readOnly: true karena nilai dihitung otomatis dari harga x qty
              // Jika user ingin ubah, cukup ubah qty atau pilih varian yang berbeda
              readOnly: true,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFFF1F5F9), // Sedikit abu untuk menandakan read-only
                prefixText: "Rp   ",
                prefixStyle: const TextStyle(
                  color: Color(0xFF94A3B8),
                  fontSize: 16,
                  fontFamily: 'Manrope',
                  fontWeight: FontWeight.bold,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                hintText: "0",
                hintStyle: const TextStyle(
                  color: Color(0xFF1E2857),
                  fontFamily: 'Plus Jakarta Sans',
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // --- 5. CATATAN ---
            const Text(
              "CATATAN TAMBAHAN",
              style: TextStyle(
                fontFamily: 'Manrope',
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Color(0xFF454652),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _catatanController,
              maxLines: 3,
              style: const TextStyle(fontSize: 14),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                hintText: "Masukkan rincian tambahan (opsional)...",
                hintStyle: const TextStyle(
                  color: Color(0xFF94A3B8),
                  fontSize: 14,
                  fontFamily: 'Manrope',
                  fontWeight: FontWeight.normal,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 40),

            // --- 6. TOMBOL SIMPAN ---
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _submitData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF000666), // Navy Blue
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  elevation: 0,
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.check_circle_outline,
                      color: Colors.white,
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Text(
                      "Simpan Transaksi",
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'Manrope',
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
