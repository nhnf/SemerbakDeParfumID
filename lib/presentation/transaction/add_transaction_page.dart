import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../domain/entities/product_entity.dart';
import '../../../domain/entities/price_config_entity.dart';
import '../../../domain/entities/transaction_entity.dart';
import '../catalog/bloc/product_bloc.dart';
import '../catalog/bloc/product_state.dart';
import '../catalog/bloc/price_config_bloc.dart';
import '../catalog/bloc/price_config_state.dart';
import '../catalog/bloc/bottle_stock_bloc.dart';
import '../catalog/bloc/bottle_stock_event.dart';
import 'bloc/transaction_bloc.dart';
import 'bloc/transaction_event.dart';
import 'utils/parfum_ukuran_utils.dart';

class AddTransactionPage extends StatefulWidget {
  final bool initialIsPemasukan;

  const AddTransactionPage({super.key, this.initialIsPemasukan = true});

  @override
  State<AddTransactionPage> createState() => _AddTransactionPageState();
}

class _AddTransactionPageState extends State<AddTransactionPage> {
  final _formKey = GlobalKey<FormState>();

  // State Umum
  late bool _isPemasukan;
  int _totalHarga = 0;
  final TextEditingController _totalManualController = TextEditingController();
  final TextEditingController _catatanController = TextEditingController();
  final TextEditingController _namaPengeluaranController =
      TextEditingController();

  // State Penjualan
  String _jenis = 'beli_baru'; // 'beli_baru' atau 'isi_ulang'
  ProductEntity? _selectedProduct;
  String _selectedKualitas = kualitasList[1].value; // default 1:1
  String _selectedUkuran = ukuranList[3].value; // default 30ML BB
  int _qty = 1;

  // State Pengeluaran
  String _kategoriBahan = kategoriBahanList[0]; // 'Botol' default

  @override
  void initState() {
    super.initState();
    _isPemasukan = widget.initialIsPemasukan;
  }

  @override
  void dispose() {
    _totalManualController.dispose();
    _catatanController.dispose();
    _namaPengeluaranController.dispose();
    super.dispose();
  }

  void _updateTotalPenjualan(List<PriceConfigEntity> configs) {
    if (_selectedProduct == null) {
      setState(() => _totalHarga = 0);
      return;
    }

    try {
      PriceConfigEntity? config;
      try {
        config = configs.firstWhere(
          (c) => c.jenis == _jenis && c.kualitas == _selectedKualitas && c.ukuran == _selectedUkuran,
        );
      } catch (_) {
        config = const PriceConfigEntity(
          jenis: '',
          kualitas: '',
          ukuran: '',
          harga: 0,
        );
      }

      setState(() {
        _totalHarga =
            (config?.harga ?? 0) * _qty; // Lebih rapi, memakai null assertion fallback aman
      });
    } catch (e, stack) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error Update Harga: $e'),
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }

  void _simpanTransaksi() {
    if (!_formKey.currentState!.validate()) return;

    if (_isPemasukan && _selectedProduct == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih parfum terlebih dahulu')),
      );
      return;
    }

    int finalTotal = _totalHarga;
    String finalNama = '';

    if (!_isPemasukan) {
      final textRp = _totalManualController.text.replaceAll(
        RegExp(r'[^0-9]'),
        '',
      );
      if (textRp.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Masukkan total harga pengeluaran')),
        );
        return;
      }
      finalTotal = int.parse(textRp);

      if (_kategoriBahan == 'Botol') {
        finalNama = 'Beli Botol $_selectedUkuran';
      } else {
        if (_namaPengeluaranController.text.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Masukkan nama pengeluaran')),
          );
          return;
        }
        finalNama = _namaPengeluaranController.text.trim();
      }
    } else {
      finalNama = _selectedProduct!.name;
    }

    final newTransaction = TransactionEntity(
      productId: _isPemasukan ? _selectedProduct?.id : null,
      nama: finalNama,
      jenis: _isPemasukan ? _jenis : null,
      kualitas: _isPemasukan ? _selectedKualitas : null,
      ukuran: (_isPemasukan || _kategoriBahan == 'Botol')
          ? _selectedUkuran
          : null,
      kategoriBahan: _isPemasukan ? null : _kategoriBahan,
      qty: _qty,
      hargaSatuan: _isPemasukan ? (finalTotal ~/ _qty) : finalTotal,
      total: finalTotal,
      isPemasukan: _isPemasukan,
      catatan: _catatanController.text.isEmpty
          ? null
          : _catatanController.text.trim(),
      tanggal: DateTime.now(),
    );

    // Save transaction
    context.read<TransactionBloc>().add(AddTransactionEvent(newTransaction));

    // Handle Bottle Stock Logic
    if (_isPemasukan && _jenis == 'beli_baru') {
      context.read<BottleStockBloc>().add(
        GenerateBottleStockEvent(_selectedUkuran, -_qty),
      );
    } else if (!_isPemasukan && _kategoriBahan == 'Botol') {
      context.read<BottleStockBloc>().add(
        GenerateBottleStockEvent(_selectedUkuran, _qty),
      );
    }

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Transaksi berhasil ditambahkan!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PriceConfigBloc, PriceConfigState>(
      builder: (context, priceState) {
        List<PriceConfigEntity> configs = [];
        if (priceState is PriceConfigLoaded) {
          configs = priceState.configs;
        }

        return Scaffold(
          backgroundColor: const Color(0xFFF8FAFC),
          appBar: AppBar(
            title: Text(
              _isPemasukan ? 'Catat Penjualan' : 'Catat Pengeluaran',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            backgroundColor: Colors.white,
            foregroundColor: const Color(0xFF1E2857),
            elevation: 0,
            centerTitle: true,
          ),
          body: Form(
            key: _formKey,
            child: Column(
              children: [
                _buildHeaderToggles(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: _isPemasukan
                        ? _buildFormPenjualan(configs)
                        : _buildFormPengeluaran(),
                  ),
                ),
                _buildBottomBar(configs),
              ],
            ),
          ),
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // UI: HEADER TOGGLES
  // ---------------------------------------------------------------------------
  Widget _buildHeaderToggles() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(6),
        child: Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _isPemasukan = true;
                    _qty = 1;
                    _totalManualController.clear();
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: _isPemasukan ? Colors.white : Colors.transparent,
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
                  child: Center(
                    child: Text(
                      'Pemasukan',
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: _isPemasukan
                            ? const Color(0xFF00B894)
                            : const Color(0xFF94A3B8),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _isPemasukan = false;
                    _qty = 1;
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: !_isPemasukan ? Colors.white : Colors.transparent,
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
                  child: Center(
                    child: Text(
                      'Pengeluaran',
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: !_isPemasukan
                            ? const Color(0xFFFF7675)
                            : const Color(0xFF94A3B8),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // UI: FORM PENJUALAN
  // ---------------------------------------------------------------------------
  Widget _buildFormPenjualan(List<PriceConfigEntity> configs) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          title: '1. Jenis Transaksi',
          icon: Icons.shopping_bag_outlined,
          color: const Color(0xFF6C5CE7),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: RadioListTile<String>(
                title: const Text(
                  'Beli Baru\n(dgn botol)',
                  style: TextStyle(fontSize: 13),
                ),
                value: 'beli_baru',
                groupValue: _jenis,
                activeColor: const Color.fromARGB(225, 0, 6, 102),
                contentPadding: EdgeInsets.zero,
                onChanged: (val) => setState(() {
                  _jenis = val!;
                  _updateTotalPenjualan(configs);
                }),
              ),
            ),
            Expanded(
              child: RadioListTile<String>(
                title: const Text(
                  'Isi Ulang\n(tanpa botol)',
                  style: TextStyle(fontSize: 13),
                ),
                value: 'isi_ulang',
                groupValue: _jenis,
                activeColor: const Color.fromARGB(225, 0, 6, 102),
                contentPadding: EdgeInsets.zero,
                onChanged: (val) => setState(() {
                  _jenis = val!;
                  _updateTotalPenjualan(configs);
                }),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        _buildSectionHeader(
          title: '2. Parfum',
          icon: Icons.sanitizer_outlined,
          color: const Color(0xFF00B894),
        ),
        const SizedBox(height: 16),
        BlocBuilder<ProductBloc, ProductState>(
          builder: (context, state) {
            if (state is ProductLoaded) {
              final products = state.products;
              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    hint: const Text('Pilih Parfum'),
                    value: _selectedProduct?.id.toString(),
                    items: products.map((p) {
                      return DropdownMenuItem<String>(
                        value: p.id.toString(),
                        child: Text(
                          p.name,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val == null) return; // Jika null, hentikan proses

                      try {
                        // 1. Cari produknya terlebih dahulu
                        final selected = products.firstWhere(
                          (p) => p.id.toString() == val,
                        );

                        // 2. Update state produk saja
                        setState(() {
                          _selectedProduct = selected;
                        });

                        // 3. Panggil fungsi update harga di LUAR setState
                        // (karena fungsinya sudah punya setState sendiri)
                        _updateTotalPenjualan(configs);
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error pilih parfum: $e')),
                        );
                      }
                    },
                  ),
                ),
              );
            }
            return const CircularProgressIndicator();
          },
        ),
        const SizedBox(height: 24),

        _buildSectionHeader(
          title: '3. Kualitas',
          icon: Icons.star_border,
          color: const Color(0xFFFFB020),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: kualitasList.map((opt) {
            final isSelected = _selectedKualitas == opt.value;
            return ChoiceChip(
              label: Text(opt.label),
              selected: isSelected,
              selectedColor: const Color.fromARGB(225, 0, 6, 102),
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.black,
              ),
              onSelected: (val) {
                setState(() {
                  _selectedKualitas = opt.value;
                  _updateTotalPenjualan(configs);
                });
              },
            );
          }).toList(),
        ),
        const SizedBox(height: 24),

        _buildSectionHeader(
          title: '4. Ukuran & Jumlah',
          icon: Icons.water_drop_outlined,
          color: const Color(0xFF0984E3),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: ukuranList.map((opt) {
            final isSelected = _selectedUkuran == opt.value;
            return ChoiceChip(
              label: Text(opt.label),
              selected: isSelected,
              selectedColor: const Color.fromARGB(225, 0, 6, 102),
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.black,
              ),
              onSelected: (val) {
                setState(() {
                  _selectedUkuran = opt.value;
                  _updateTotalPenjualan(configs);
                });
              },
            );
          }).toList(),
        ),
        const SizedBox(height: 20),
        _buildQtyStepper(configs),
        const SizedBox(height: 24),

        _buildSectionHeader(
          title: 'Keterangan (Opsional)',
          icon: Icons.notes_rounded,
          color: const Color(0xFF94A3B8),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _catatanController,
          maxLines: 2,
          decoration: InputDecoration(
            hintText: 'Tambahkan catatan jika ada...',
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // UI: FORM PENGELUARAN
  // ---------------------------------------------------------------------------
  Widget _buildFormPengeluaran() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          title: 'Kategori Bahan',
          icon: Icons.category_outlined,
          color: const Color(0xFFFF7675),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              value: _kategoriBahan,
              items: kategoriBahanList.map((k) {
                return DropdownMenuItem(
                  value: k,
                  child: Text(
                    k,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                );
              }).toList(),
              onChanged: (val) {
                setState(() {
                  _kategoriBahan = val!;
                  if (_kategoriBahan != 'Botol')
                    _qty = 1; // auto reset qty if not botol
                });
              },
            ),
          ),
        ),
        const SizedBox(height: 24),

        if (_kategoriBahan == 'Botol') ...[
          _buildSectionHeader(
            title: 'Ukuran Botol & Jumlah (Otomatis + Stok)',
            icon: Icons.water_drop_outlined,
            color: const Color(0xFF0984E3),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: ukuranList.map((opt) {
              final isSelected = _selectedUkuran == opt.value;
              return ChoiceChip(
                label: Text(opt.label),
                selected: isSelected,
                selectedColor: const Color.fromARGB(225, 0, 6, 102),
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : Colors.black,
                ),
                onSelected: (val) {
                  setState(() {
                    _selectedUkuran = opt.value;
                  });
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          _buildQtyStepper(null),
          const SizedBox(height: 24),
        ] else ...[
          _buildSectionHeader(
            title: 'Nama Bahan / Pengeluaran',
            icon: Icons.drive_file_rename_outline,
            color: const Color(0xFF00B894),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _namaPengeluaranController,
            decoration: InputDecoration(
              hintText: 'Misal: Alkohol 1 Liter',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],

        _buildSectionHeader(
          title: 'Total Harga Beban',
          icon: Icons.payments_outlined,
          color: const Color(0xFF6C5CE7),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _totalManualController,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: InputDecoration(
            prefixText: 'Rp ',
            hintText: '0',
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
          ),
        ),
        const SizedBox(height: 24),

        _buildSectionHeader(
          title: 'Keterangan (Opsional)',
          icon: Icons.notes_rounded,
          color: const Color(0xFF94A3B8),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _catatanController,
          maxLines: 2,
          decoration: InputDecoration(
            hintText: 'Tambahkan catatan jika ada...',
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // WIDGETS
  // ---------------------------------------------------------------------------
  Widget _buildSectionHeader({
    required String title,
    required IconData icon,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 20, color: color),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E2857),
          ),
        ),
      ],
    );
  }

  Widget _buildQtyStepper(List<PriceConfigEntity>? configs) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Jumlah (Qty)',
            style: TextStyle(
              fontFamily: 'Manrope',
              fontWeight: FontWeight.bold,
              color: Color(0xFF475569),
            ),
          ),
          Row(
            children: [
              IconButton(
                onPressed: _qty > 1
                    ? () => setState(() {
                        _qty--;
                        if (configs != null) _updateTotalPenjualan(configs);
                      })
                    : null,
                icon: const Icon(Icons.remove_circle_outline),
                color: const Color(0xFF94A3B8),
              ),
              Container(
                width: 40,
                alignment: Alignment.center,
                child: Text(
                  '$_qty',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
              IconButton(
                onPressed: () => setState(() {
                  _qty++;
                  if (configs != null) _updateTotalPenjualan(configs);
                }),
                icon: const Icon(Icons.add_circle_outline),
                color: const Color.fromARGB(225, 0, 6, 102),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(List<PriceConfigEntity> configs) {
    final formatter = NumberFormat.decimalPattern('id');
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          if (_isPemasukan) ...[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Total Harga',
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 12,
                    color: Color(0xFF94A3B8),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Rp ${formatter.format(_totalHarga)}',
                  style: const TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(225, 0, 6, 102),
                  ),
                ),
                if (_totalHarga > 0)
                  Text(
                    '${_qty}x Rp ${formatter.format(_totalHarga ~/ _qty)}',
                    style: const TextStyle(
                      fontSize: 10,
                      color: Color(0xFF94A3B8),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 24),
          ],
          Expanded(
            child: SizedBox(
              height: 56,
              child: ElevatedButton(
                onPressed: _simpanTransaksi,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(225, 0, 6, 102),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Simpan',
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
