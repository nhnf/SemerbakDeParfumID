import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../domain/entities/product_entity.dart';
import '../../../domain/entities/transaction_entity.dart';
import '../catalog/bloc/product_bloc.dart';
import '../catalog/bloc/product_state.dart';
import 'bloc/transaction_bloc.dart';
import 'bloc/transaction_event.dart';

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

  // Produk yang dipilih dari database Supabase
  ProductEntity? _selectedProduct;

  @override
  void dispose() {
    _totalController.dispose();
    _catatanController.dispose();
    super.dispose();
  }

  void _updateTotal() {
    if (_selectedProduct == null) return;
    final total = _selectedProduct!.price * _qty;
    _totalController.text = NumberFormat.decimalPattern('id').format(total);
  }

  void _submitData() {
    if (_selectedProduct == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tolong pilih produk terlebih dahulu')),
      );
      return;
    }

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

    final String catatan = _catatanController.text.trim();
    final String finalNama = catatan.isNotEmpty
        ? '${_selectedProduct!.name} ($catatan)'
        : '${_selectedProduct!.name} ($_qty item)';

    final newTransaction = TransactionEntity(
      productId: _selectedProduct!.id,
      nama: finalNama,
      qty: _qty,
      hargaSatuan: _selectedProduct!.price,
      total: total,
      isPemasukan: _isPemasukan,
      catatan: catatan.isNotEmpty ? catatan : null,
      tanggal: DateTime.now(),
    );

    context.read<TransactionBloc>().add(AddTransactionEvent(newTransaction));
    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Transaksi berhasil ditambahkan!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
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
      body: BlocBuilder<ProductBloc, ProductState>(
        builder: (context, productState) {
          // Saat produk dimuat dari Supabase, inisialisasi pilihan pertama
          if (productState is ProductLoaded &&
              productState.products.isNotEmpty &&
              _selectedProduct == null) {
            // Gunakan post-frame callback agar tidak setState di dalam build
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                setState(() {
                  _selectedProduct = productState.products.first;
                  _updateTotal();
                });
              }
            });
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                                        color: Colors.black.withValues(
                                            alpha: 0.05),
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
                                        color: Colors.black.withValues(
                                            alpha: 0.05),
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
                                    : const Color(0xFF64748B),
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

                // --- 2. PILIHAN PRODUK DARI SUPABASE ---
                const Text(
                  "PILIH PRODUK",
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
                  child: _buildProductDropdown(productState),
                ),
                const SizedBox(height: 24),

                // --- 3. KUANTITAS ---
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
                Container(
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
                const SizedBox(height: 24),

                // --- 4. TOTAL HARGA ---
                const Text(
                  "TOTAL",
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF454652),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _totalController,
                  readOnly: true,
                  style:
                      const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: const Color(0xFFF1F5F9),
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
                      backgroundColor: const Color(0xFF000666),
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
          );
        },
      ),
    );
  }

  Widget _buildProductDropdown(ProductState productState) {
    if (productState is ProductLoading || productState is ProductInitial) {
      return const Row(
        children: [
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          SizedBox(width: 12),
          Text('Memuat produk...', style: TextStyle(color: Colors.grey)),
        ],
      );
    }

    if (productState is ProductError) {
      return Text(
        'Gagal memuat produk',
        style: TextStyle(color: Colors.red.shade400),
      );
    }

    if (productState is ProductLoaded) {
      final products = productState.products;
      if (products.isEmpty) {
        return const Text(
          'Tidak ada produk tersedia',
          style: TextStyle(color: Colors.grey),
        );
      }

      return DropdownButtonHideUnderline(
        child: DropdownButton<ProductEntity>(
          value: _selectedProduct != null &&
                  products.any((p) => p.id == _selectedProduct!.id)
              ? _selectedProduct
              : null,
          isExpanded: true,
          icon: const Icon(Icons.expand_more, color: Colors.grey),
          hint: const Text('Pilih produk...'),
          items: products.map((ProductEntity product) {
            return DropdownMenuItem<ProductEntity>(
              value: product,
              child: Text(
                product.name,
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
              _selectedProduct = newValue;
              _updateTotal();
            });
          },
        ),
      );
    }

    return const SizedBox.shrink();
  }
}
