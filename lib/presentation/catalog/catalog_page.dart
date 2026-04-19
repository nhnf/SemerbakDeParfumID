import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/entities/price_config_entity.dart';
import '../../domain/entities/bottle_stock_entity.dart';
import 'bloc/product_bloc.dart';
import 'bloc/product_event.dart';
import 'bloc/product_state.dart';
import 'bloc/price_config_bloc.dart';
import 'bloc/price_config_event.dart';
import 'bloc/price_config_state.dart';
import 'bloc/bottle_stock_bloc.dart';
import 'bloc/bottle_stock_event.dart';
import 'bloc/bottle_stock_state.dart';

class CatalogPage extends StatefulWidget {
  const CatalogPage({super.key});

  @override
  State<CatalogPage> createState() => _CatalogPageState();
}

class _CatalogPageState extends State<CatalogPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

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
    _tabController = TabController(length: 3, vsync: this);
    _searchController.addListener(() {
      setState(() => _searchQuery = _searchController.text.toLowerCase());
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
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

  Future<void> _refreshAll() async {
    context.read<ProductBloc>().add(LoadProductsEvent());
    context.read<PriceConfigBloc>().add(LoadPriceConfigsEvent());
    context.read<BottleStockBloc>().add(LoadBottleStocksEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F9),
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 280,
              floating: false,
              pinned: true,
              backgroundColor: const Color.fromARGB(225, 0, 6, 102),
              elevation: 0,
              title: const Text(
                'Katalog & Manajemen',
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.refresh, color: Colors.white),
                  onPressed: _refreshAll,
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
                        child: BlocBuilder<ProductBloc, ProductState>(
                          builder: (context, state) => _buildHeaderStats(state),
                        ),
                      ),
                      const SizedBox(height: 60),
                    ],
                  ),
                ),
              ),
              bottom: TabBar(
                controller: _tabController,
                indicatorColor: Colors.white,
                indicatorWeight: 3,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white.withValues(alpha: 0.6),
                labelStyle: const TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontWeight: FontWeight.bold,
                ),
                tabs: const [
                  Tab(text: 'Produk'),
                  Tab(text: 'Harga'),
                  Tab(text: 'Stok Botol'),
                ],
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildProdukTab(),
            _buildHargaConfigTab(),
            _buildStokBotolTab(),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // WIDGETS STATISTIK (HEADER)
  // ===========================================================================
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
            icon: Icons.warning_amber_rounded,
            label: 'STOK MENIPIS',
            value: '-',
          ),
        ],
      );
    }

    final products = state.products;
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
          icon: Icons.warning_amber_rounded,
          label: 'STOK MENIPIS',
          value: '$lowStockCount',
          isWarning: lowStockCount > 0,
          onTap: lowStockCount > 0
              ? () => _showLowStockDialog(context, products)
              : null,
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
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
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

  void _showLowStockDialog(BuildContext context, List<ProductEntity> products) {
    final lowStockItems = products.where((p) => p.stock < 15).toList();
    if (lowStockItems.isEmpty) return;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Daftar Stok Menipis',
            style: TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontWeight: FontWeight.bold,
            ),
          ),
          content: SizedBox(
            width: double.maxFinite,
            height: 300,
            child: ListView.builder(
              itemCount: lowStockItems.length,
              itemBuilder: (context, index) {
                final item = lowStockItems[index];
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.warning, color: Color(0xFFFF7675)),
                  title: Text(
                    item.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(item.category),
                  trailing: Text(
                    'Sisa: ${item.stock}',
                    style: const TextStyle(
                      color: Color(0xFFFF7675),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Tutup',
                style: TextStyle(color: Color.fromARGB(225, 0, 6, 102)),
              ),
            ),
          ],
        );
      },
    );
  }

  // ===========================================================================
  // TAB 1: PRODUK (Tanpa Harga)
  // ===========================================================================
  Widget _buildProdukTab() {
    return BlocBuilder<ProductBloc, ProductState>(
      builder: (context, state) {
        if (state is ProductLoading || state is ProductInitial) {
          return const Center(
            child: CircularProgressIndicator(
              color: Color.fromARGB(225, 0, 6, 102),
            ),
          );
        } else if (state is ProductError) {
          return Center(child: Text(state.message));
        } else if (state is ProductLoaded) {
          final filtered = _filterProducts(state.products);
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                child: TextField(
                  controller: _searchController,
                  style: const TextStyle(fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'Cari nama produk...',
                    hintStyle: const TextStyle(color: Color(0xFFADB5BD)),
                    prefixIcon: const Icon(
                      Icons.search,
                      color: Color(0xFFADB5BD),
                    ),
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
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final item = filtered[index];
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
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: categoryColor.withValues(
                                        alpha: 0.1,
                                      ),
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
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isLowStock
                                        ? const Color(
                                            0xFFFF7675,
                                          ).withValues(alpha: 0.1)
                                        : const Color(
                                            0xFF00B894,
                                          ).withValues(alpha: 0.1),
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
                                        'Stok ${item.stock}',
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
                                const SizedBox(height: 8),
                                PopupMenuButton<String>(
                                  icon: const Icon(
                                    Icons.more_horiz,
                                    color: Color(0xFF94A3B8),
                                  ),
                                  onSelected: (value) {
                                    if (value == 'edit') {
                                      _showEditProductDialog(context, item);
                                    } else if (value == 'delete') {
                                      _showDeleteProductDialog(context, item);
                                    }
                                  },
                                  itemBuilder: (context) => [
                                    const PopupMenuItem(
                                      value: 'edit',
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.edit,
                                            size: 18,
                                            color: Color.fromARGB(
                                              225,
                                              0,
                                              6,
                                              102,
                                            ),
                                          ),
                                          SizedBox(width: 8),
                                          Text('Edit Produk'),
                                        ],
                                      ),
                                    ),
                                    const PopupMenuItem(
                                      value: 'delete',
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.delete_outline,
                                            size: 18,
                                            color: Color(0xFFFF7675),
                                          ),
                                          SizedBox(width: 8),
                                          Text(
                                            'Hapus',
                                            style: TextStyle(
                                              color: Color(0xFFFF7675),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        }
        return const SizedBox();
      },
    );
  }

  // ===========================================================================
  // TAB 2: HARGA CONFIG
  // ===========================================================================
  Widget _buildHargaConfigTab() {
    return BlocBuilder<PriceConfigBloc, PriceConfigState>(
      builder: (context, state) {
        if (state is PriceConfigLoading || state is PriceConfigInitial) {
          return const Center(
            child: CircularProgressIndicator(
              color: Color.fromARGB(225, 0, 6, 102),
            ),
          );
        } else if (state is PriceConfigError) {
          return Center(child: Text(state.message));
        } else if (state is PriceConfigLoaded) {
          final configs = state.configs;
          // Kelompokkan berdasarkan jenis -> kualitas -> daftar ukuran
          final Map<String, Map<String, List<PriceConfigEntity>>> grouped = {
            'Beli Baru': {},
            'Isi Ulang': {},
          };

          for (var c in configs) {
            final jenisLable = c.jenis == 'beli_baru'
                ? 'Beli Baru'
                : 'Isi Ulang';
            grouped[jenisLable] ??= {};
            grouped[jenisLable]![c.kualitas] ??= [];
            grouped[jenisLable]![c.kualitas]!.add(c);
          }

          return ListView(
            padding: const EdgeInsets.all(20),
            children: grouped.entries.map((jEntry) {
              final jenis = jEntry.key;
              final kualitasMap = jEntry.value;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    jenis,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(225, 0, 6, 102),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...kualitasMap.entries.map((kEntry) {
                    final kualitas = kEntry.key;
                    final listUkuran = kEntry.value;

                    // Mengurutkan ukuran
                    listUkuran.sort((a, b) => a.ukuran.compareTo(b.ukuran));

                    return Container(
                      margin: const EdgeInsets.only(bottom: 20),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(
                                225,
                                0,
                                6,
                                102,
                              ).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Kualitas $kualitas',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color.fromARGB(225, 0, 6, 102),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          ...listUkuran.map((c) {
                            final formatter = NumberFormat.decimalPattern('id');
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    c.ukuran,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        'Rp ${formatter.format(c.harga)}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.edit,
                                          size: 16,
                                          color: Color(0xFF94A3B8),
                                        ),
                                        constraints: const BoxConstraints(),
                                        padding: const EdgeInsets.only(left: 8),
                                        onPressed: () {
                                          _showEditHargaDialog(context, c);
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          }),
                        ],
                      ),
                    );
                  }),
                ],
              );
            }).toList(),
          );
        }
        return const SizedBox();
      },
    );
  }

  void _showEditHargaDialog(BuildContext context, PriceConfigEntity config) {
    final controller = TextEditingController(text: config.harga.toString());
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Harga - ${config.ukuran} (${config.kualitas})'),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: const InputDecoration(
              prefixText: 'Rp ',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(225, 0, 6, 102),
              ),
              onPressed: () {
                final val = int.tryParse(controller.text) ?? 0;
                final updated = config.copyWith(harga: val);
                context.read<PriceConfigBloc>().add(
                  UpdatePriceConfigEvent(updated),
                );
                Navigator.pop(context);
              },
              child: const Text(
                'Simpan',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  // ===========================================================================
  // TAB 3: STOK BOTOL
  // ===========================================================================
  Widget _buildStokBotolTab() {
    return BlocBuilder<BottleStockBloc, BottleStockState>(
      builder: (context, state) {
        if (state is BottleStockLoading || state is BottleStockInitial) {
          return const Center(
            child: CircularProgressIndicator(
              color: Color.fromARGB(225, 0, 6, 102),
            ),
          );
        } else if (state is BottleStockError) {
          return Center(child: Text(state.message));
        } else if (state is BottleStockLoaded) {
          final stocks = state.stocks;
          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: stocks.length,
            itemBuilder: (context, index) {
              final stock = stocks[index];
              final isLow = stock.stok < 10;
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(
                          225,
                          0,
                          6,
                          102,
                        ).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.water_drop_outlined,
                        color: Color.fromARGB(225, 0, 6, 102),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Botol ${stock.ukuran}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Sisa ${stock.stok} unit',
                            style: TextStyle(
                              color: isLow ? Colors.red : Colors.grey[600],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                        _showEditStokDialog(context, stock);
                      },
                    ),
                  ],
                ),
              );
            },
          );
        }
        return const SizedBox();
      },
    );
  }

  void _showEditStokDialog(BuildContext context, BottleStockEntity stock) {
    final controller = TextEditingController(text: stock.stok.toString());
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Stok - Botol ${stock.ukuran}'),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: const InputDecoration(border: OutlineInputBorder()),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(225, 0, 6, 102),
              ),
              onPressed: () {
                final val = int.tryParse(controller.text) ?? 0;
                context.read<BottleStockBloc>().add(
                  UpdateBottleStockEvent(stock.ukuran, val),
                );
                Navigator.pop(context);
              },
              child: const Text(
                'Simpan',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showEditProductDialog(BuildContext context, ProductEntity product) {
    final nameController = TextEditingController(text: product.name);
    final categoryController = TextEditingController(text: product.category);
    final stockController = TextEditingController(
      text: product.stock.toString(),
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Produk'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nama Produk',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: categoryController,
                  decoration: const InputDecoration(
                    labelText: 'Kategori (Laki/Perempuan/Unisex)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: stockController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(
                    labelText: 'Stok Terkini',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(225, 0, 6, 102),
              ),
              onPressed: () {
                final updProduct = product.copyWith(
                  name: nameController.text.trim(),
                  category: categoryController.text.trim(),
                  stock: int.tryParse(stockController.text.trim()) ?? 0,
                );
                context.read<ProductBloc>().add(UpdateProductEvent(updProduct));
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Produk berhasil diperbarui!')),
                );
              },
              child: const Text(
                'Simpan',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteProductDialog(BuildContext context, ProductEntity product) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Hapus Produk?'),
          content: Text(
            'Apakah Anda yakin ingin menghapus produk "${product.name}"? Ini tidak dapat dibatalkan.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Batal',
                style: TextStyle(color: Color.fromARGB(225, 0, 6, 102)),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF7675),
              ),
              onPressed: () {
                if (product.id != null) {
                  context.read<ProductBloc>().add(
                    DeleteProductEvent(product.id!),
                  );
                }
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Produk dihapus!')),
                );
              },
              child: const Text('Hapus', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }
}
