import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/product_entity.dart';
import 'bloc/product_bloc.dart';
import 'bloc/product_event.dart';
import 'bloc/product_state.dart';

// =============================================================================
// HALAMAN KATALOG - DATA DARI SUPABASE
// =============================================================================
class CatalogPage extends StatefulWidget {
  const CatalogPage({super.key});

  @override
  State<CatalogPage> createState() => _CatalogPageState();
}

class _CatalogPageState extends State<CatalogPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // Palet warna per kategori (tanpa SKU)
  static const Map<String, Color> _categoryColors = {
    'Premium Collection': Color(0xFF6C5CE7),
    'Signature Series': Color.fromARGB(225, 0, 6, 102),
    'Classic Line': Color(0xFF00B894),
    'Bahan Baku': Color(0xFFE17055),
  };

  Color _getCategoryColor(String category) {
    return _categoryColors[category] ?? const Color(0xFF94A3B8);
  }

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() => _searchQuery = _searchController.text.toLowerCase());
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<ProductEntity> _filterProducts(List<ProductEntity> products) {
    if (_searchQuery.isEmpty) return products;
    return products
        .where(
          (p) =>
              p.name.toLowerCase().contains(_searchQuery) ||
              p.category.toLowerCase().contains(_searchQuery),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F9),
      body: BlocBuilder<ProductBloc, ProductState>(
        builder: (context, state) {
          return RefreshIndicator(
            onRefresh: () async {
              context.read<ProductBloc>().add(LoadProductsEvent());
            },
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                // -----------------------------------------------------------------
                // 1. HEADER NAVY (SliverAppBar)
                // -----------------------------------------------------------------
                SliverAppBar(
                  expandedHeight: 280,
                  floating: false,
                  pinned: true,
                  backgroundColor: const Color.fromARGB(225, 0, 6, 102),
                  elevation: 0,
                  title: const Text(
                    'Katalog Produk',
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                  actions: [
                    // Tombol refresh
                    IconButton(
                      icon: const Icon(Icons.refresh, color: Colors.white),
                      onPressed: () {
                        context.read<ProductBloc>().add(LoadProductsEvent());
                      },
                    ),
                  ],
                  flexibleSpace: FlexibleSpaceBar(
                    background: Container(
                      decoration: const BoxDecoration(
                        color: Color.fromARGB(225, 0, 6, 102),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 24),
                            child: Text(
                              'RINGKASAN INVENTARIS',
                              style: TextStyle(
                                fontFamily: 'Manrope',
                                fontSize: 12,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 2.4,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: _buildHeaderStats(state),
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                ),

                // -----------------------------------------------------------------
                // 2. SEARCH BAR
                // -----------------------------------------------------------------
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                    child: TextField(
                      controller: _searchController,
                      style: const TextStyle(fontSize: 14),
                      decoration: InputDecoration(
                        hintText: 'Cari nama produk atau kategori...',
                        hintStyle: const TextStyle(color: Color(0xFFADB5BD)),
                        prefixIcon: const Icon(
                          Icons.search,
                          color: Color(0xFFADB5BD),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 14,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                ),

                // -----------------------------------------------------------------
                // 3. KONTEN UTAMA: Loading / Error / Data
                // -----------------------------------------------------------------
                if (state is ProductLoading || state is ProductInitial)
                  const SliverFillRemaining(
                    child: Center(
                      child: CircularProgressIndicator(
                        color: Color.fromARGB(225, 0, 6, 102),
                      ),
                    ),
                  )
                else if (state is ProductError)
                  SliverFillRemaining(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.wifi_off_rounded,
                              size: 64,
                              color: Color(0xFFCBD5E1),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              state.message,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Color(0xFF94A3B8),
                                fontFamily: 'Manrope',
                              ),
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton.icon(
                              onPressed: () {
                                context.read<ProductBloc>().add(
                                  LoadProductsEvent(),
                                );
                              },
                              icon: const Icon(Icons.refresh),
                              label: const Text('Coba Lagi'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color.fromARGB(
                                  225,
                                  0,
                                  6,
                                  102,
                                ),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                else if (state is ProductLoaded) ...[
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        '${_filterProducts(state.products).length} produk ditemukan',
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
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final filtered = _filterProducts(state.products);
                        return _buildProductCard(filtered[index]);
                      }, childCount: _filterProducts(state.products).length),
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeaderStats(ProductState state) {
    if (state is! ProductLoaded) {
      return Row(
        children: [
          _buildHeaderStat(
            icon: Icons.inventory_2_outlined,
            label: 'TOTAL PRODUK',
            value: '-',
          ),
          const SizedBox(width: 16),
          _buildHeaderStat(
            icon: Icons.stacked_bar_chart,
            label: 'TOTAL STOK',
            value: '-',
          ),
          const SizedBox(width: 16),
          _buildHeaderStat(
            icon: Icons.warning_amber_rounded,
            label: 'STOK MENIPIS',
            value: '-',
          ),
        ],
      );
    }

    final products = state.products;
    final totalStock = products.fold<int>(0, (sum, item) => sum + item.stock);
    final lowStockCount = products.where((item) => item.stock < 15).length;

    return Row(
      children: [
        _buildHeaderStat(
          icon: Icons.inventory_2_outlined,
          label: 'TOTAL PRODUK',
          value: '${products.length}',
        ),
        const SizedBox(width: 16),
        _buildHeaderStat(
          icon: Icons.stacked_bar_chart,
          label: 'TOTAL STOK',
          value: '$totalStock',
        ),
        const SizedBox(width: 16),
        _buildHeaderStat(
          icon: Icons.warning_amber_rounded,
          label: 'STOK MENIPIS',
          value: '$lowStockCount',
          isWarning: lowStockCount > 0,
          onTap: () {
            final lowStockProducts = products
                .where((item) => item.stock < 15)
                .toList();
            if (lowStockProducts.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Tidak ada stok yang menipis.')),
              );
              return;
            }
            showDialog(
              context: context,
              builder: (context) {
                return Dialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  backgroundColor: Colors.white,
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFF7675).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.warning_amber_rounded,
                                color: Color(0xFFFF7675),
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 16),
                            const Text(
                              'Stok Menipis',
                              style: TextStyle(
                                fontFamily: 'Plus Jakarta Sans',
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color.fromARGB(225, 0, 6, 102),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Flexible(
                          child: ListView.separated(
                            shrinkWrap: true,
                            itemCount: lowStockProducts.length,
                            separatorBuilder: (context, index) => const Divider(
                              color: Color(0xFFF1F5F9),
                              height: 24,
                            ),
                            itemBuilder: (context, index) {
                              final p = lowStockProducts[index];
                              return Row(
                                children: [
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: const Color.fromARGB(225, 0, 6, 102).withValues(alpha: 0.05),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(
                                      Icons.sanitizer_outlined,
                                      color: Color.fromARGB(225, 0, 6, 102),
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          p.name,
                                          style: const TextStyle(
                                            fontFamily: 'Manrope',
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                            color: Color(0xFF1E2857),
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          p.category,
                                          style: const TextStyle(
                                            fontFamily: 'Plus Jakarta Sans',
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF94A3B8),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFF7675).withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          Icons.warning_amber_rounded,
                                          size: 12,
                                          color: Color(0xFFFF7675),
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          'Sisa ${p.stock}',
                                          style: const TextStyle(
                                            fontFamily: 'Plus Jakarta Sans',
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFFFF7675),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () => Navigator.pop(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color.fromARGB(225, 0, 6, 102),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 0,
                            ),
                            child: const Text(
                              'Tutup',
                              style: TextStyle(
                                fontFamily: 'Plus Jakarta Sans',
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
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
      ],
    );
  }

  Widget _buildHeaderStat({
    required IconData icon,
    required String label,
    required String value,
    bool isWarning = false,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 140,
        height: 140,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isWarning
                    ? const Color(0xFFFF7675).withValues(alpha: 0.1)
                    : const Color.fromARGB(225, 238, 242, 255),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                size: 24,
                color: isWarning
                    ? const Color(0xFFFF7675)
                    : const Color.fromARGB(225, 0, 6, 102),
              ),
            ),
            const Spacer(),
            Text(
              value,
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: isWarning
                    ? const Color(0xFFFF7675)
                    : const Color.fromARGB(225, 0, 6, 102),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                fontFamily: 'Manrope',
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Color(0xFF94A3B8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductCard(ProductEntity item) {
    final formatter = NumberFormat.decimalPattern('id');
    final isLowStock = item.stock < 15;
    final categoryColor = _getCategoryColor(item.category);

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
            // Kotak ikon produk
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: const Color.fromARGB(225, 0, 6, 102),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.sanitizer_outlined,
                color: Colors.white,
                size: 26,
              ),
            ),
            const SizedBox(width: 16),

            // Informasi produk (tengah)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: const TextStyle(
                      fontFamily: 'Manrope',
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Color(0xFF1E2857),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Badge kategori
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: categoryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      item.category,
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: categoryColor,
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
                Text(
                  'Rp ${formatter.format(item.price)}',
                  style: const TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Color.fromARGB(225, 0, 6, 102),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
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
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 10,
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
