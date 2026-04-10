import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// =============================================================================
// DATA MODEL STATIS
// Sebelum terhubung ke database nyata, kita gunakan data dummy ini.
// Setiap 'item' merepresentasikan satu varian parfum di dalam katalog.
// =============================================================================
class CatalogItem {
  final String name;
  final String sku;
  final String category;
  final int price;
  final int stock;
  final Color categoryColor;

  const CatalogItem({
    required this.name,
    required this.sku,
    required this.category,
    required this.price,
    required this.stock,
    required this.categoryColor,
  });
}

// Data produk statis sementara sesuai dengan varian di AddTransactionPage
const List<CatalogItem> _catalogData = [
  CatalogItem(
    name: 'Baccarat 30ml',
    sku: 'SM-BCC-030',
    category: 'Premium Collection',
    price: 150000,
    stock: 45,
    categoryColor: Color(0xFF6C5CE7),
  ),
  CatalogItem(
    name: 'Luxury Oud 50ml',
    sku: 'SM-OUD-050',
    category: 'Signature Series',
    price: 450000,
    stock: 18,
    categoryColor: Color(0xFFDCA73A),
  ),
  CatalogItem(
    name: 'Midnight Bloom 30ml',
    sku: 'SM-MBL-030',
    category: 'Signature Series',
    price: 450000,
    stock: 27,
    categoryColor: Color(0xFFDCA73A),
  ),
  CatalogItem(
    name: 'Sweet Vanilla 100ml',
    sku: 'SM-SVN-100',
    category: 'Classic Line',
    price: 1200000,
    stock: 12,
    categoryColor: Color(0xFF00B894),
  ),
  CatalogItem(
    name: 'Botol Kaca Premium',
    sku: 'SM-BTL-PKG',
    category: 'Bahan Baku',
    price: 21000,
    stock: 8,
    categoryColor: Color(0xFFE17055),
  ),
];

// =============================================================================
// HALAMAN KATALOG UTAMA
// =============================================================================
class CatalogPage extends StatefulWidget {
  const CatalogPage({super.key});

  @override
  State<CatalogPage> createState() => _CatalogPageState();
}

class _CatalogPageState extends State<CatalogPage> {
  // Controller untuk fitur pencarian (search bar)
  final TextEditingController _searchController = TextEditingController();

  // Daftar produk yang difilter berdasarkan kata kunci pencarian
  List<CatalogItem> _filteredItems = _catalogData;

  @override
  void initState() {
    super.initState();
    // Setiap kali user mengetik di search bar, panggil _filterItems
    _searchController.addListener(_filterItems);
  }

  // Fungsi memfilter daftar item berdasarkan nama atau SKU
  void _filterItems() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredItems = _catalogData
          .where((item) =>
              item.name.toLowerCase().contains(query) ||
              item.sku.toLowerCase().contains(query) ||
              item.category.toLowerCase().contains(query))
          .toList();
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterItems);
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Total stok gabungan dari semua item
    final totalStock =
        _catalogData.fold<int>(0, (sum, item) => sum + item.stock);
    // Item dengan stok menipis (< 15)
    final lowStockCount =
        _catalogData.where((item) => item.stock < 15).length;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F9),
      body: CustomScrollView(
        slivers: [
          // -----------------------------------------------------------------
          // 1. HEADER NAVY BERGAYA (SliverAppBar)
          // Menggunakan SliverAppBar agar header mengkerut saat di-scroll
          // -----------------------------------------------------------------
          SliverAppBar(
            expandedHeight: 200,
            floating: false,
            pinned: true,
            backgroundColor: const Color(0xFF1E2857),
            elevation: 0,
            // Judul yang selalu terlihat saat header mengkerut
            title: const Text(
              'Katalog Produk',
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontSize: 18,
              ),
            ),
            // Area yang menghilang saat di-scroll (expanded part)
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF1A1E4E), Color(0xFF1E2857)],
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(
                      left: 24, right: 24, top: 80, bottom: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      const Text(
                        'RINGKASAN INVENTARIS',
                        style: TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 10,
                          color: Color(0xFFDCA73A),
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Row berisi 2 angka statistik cepat
                      Row(
                        children: [
                          _buildHeaderStat(
                            label: 'Total Produk',
                            value: '${_catalogData.length} Item',
                          ),
                          const SizedBox(width: 24),
                          _buildHeaderStat(
                            label: 'Total Stok',
                            value: '$totalStock Unit',
                          ),
                          const SizedBox(width: 24),
                          _buildHeaderStat(
                            label: 'Stok Menipis',
                            value: '$lowStockCount Item',
                            isWarning: lowStockCount > 0,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // -----------------------------------------------------------------
          // 2. SEARCH BAR
          // -----------------------------------------------------------------
          SliverToBoxAdapter(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: TextField(
                controller: _searchController,
                style: const TextStyle(fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Cari nama produk atau SKU...',
                  hintStyle: const TextStyle(color: Color(0xFFADB5BD)),
                  prefixIcon: const Icon(Icons.search, color: Color(0xFFADB5BD)),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
          ),

          // -----------------------------------------------------------------
          // 3. JUMLAH PRODUK DITAMPILKAN
          // -----------------------------------------------------------------
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                '${_filteredItems.length} produk ditemukan',
                style: const TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 11,
                  color: Color(0xFF94A3B8),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 12)),

          // -----------------------------------------------------------------
          // 4. DAFTAR KARTU PRODUK
          // SliverList agar bisa bergabung dengan SliverAppBar tanpa masalah
          // -----------------------------------------------------------------
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final item = _filteredItems[index];
                  return _buildProductCard(item);
                },
                childCount: _filteredItems.length,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget helper: Statistik kecil di area header
  Widget _buildHeaderStat({
    required String label,
    required String value,
    bool isWarning = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isWarning ? const Color(0xFFFF7675) : Colors.white,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Manrope',
            fontSize: 10,
            color: Color(0xFF8898AA),
          ),
        ),
      ],
    );
  }

  // Widget helper: Kartu satu produk
  Widget _buildProductCard(CatalogItem item) {
    final formatter = NumberFormat.decimalPattern('id');
    // Stok dianggap "menipis" jika kurang dari 15 unit
    final isLowStock = item.stock < 15;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            // Kotak ikon produk (gradient)
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF1E2857).withValues(alpha: 0.8),
                    const Color(0xFF1A1E4E),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.sanitizer_outlined,
                color: Color(0xFFDCA73A),
                size: 26,
              ),
            ),
            const SizedBox(width: 16),

            // Informasi produk (tengah)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nama produk
                  Text(
                    item.name,
                    style: const TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Color(0xFF1E2857),
                    ),
                  ),
                  const SizedBox(height: 2),
                  // SKU
                  Text(
                    'SKU: ${item.sku}',
                    style: const TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 11,
                      color: Color(0xFF94A3B8),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Badge kategori
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: item.categoryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      item.category,
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: item.categoryColor,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Kolom Kanan: Harga & Stok
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Harga satuan
                Text(
                  'Rp ${formatter.format(item.price)}',
                  style: const TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: Color(0xFF1E2857),
                  ),
                ),
                const SizedBox(height: 8),
                // Stok info dengan warna kondisional
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isLowStock
                        ? const Color(0xFFFF7675).withValues(alpha: 0.1)
                        : const Color(0xFF00B894).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isLowStock
                            ? Icons.warning_amber_rounded
                            : Icons.inventory_2_outlined,
                        size: 12,
                        color: isLowStock
                            ? const Color(0xFFFF7675)
                            : const Color(0xFF00B894),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${item.stock} unit',
                        style: TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: isLowStock
                              ? const Color(0xFFFF7675)
                              : const Color(0xFF00B894),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
