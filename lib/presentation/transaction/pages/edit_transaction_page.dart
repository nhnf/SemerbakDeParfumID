import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../domain/entities/product_entity.dart';
import '../../../domain/entities/transaction_entity.dart';
import '../../catalog/bloc/product_bloc.dart';
import '../../catalog/bloc/product_state.dart';
import '../bloc/transaction_bloc.dart';
import '../bloc/transaction_event.dart';

class EditTransactionPage extends StatefulWidget {
  final TransactionEntity transaction;
  const EditTransactionPage({super.key, required this.transaction});

  @override
  State<EditTransactionPage> createState() => _EditTransactionPageState();
}

class _EditTransactionPageState extends State<EditTransactionPage> {
  late int _qty;
  late TextEditingController _totalController;
  late TextEditingController _catatanController;
  late bool _isPemasukan;
  ProductEntity? _selectedProduct;

  @override
  void initState() {
    super.initState();
    _qty = widget.transaction.qty;
    _isPemasukan = widget.transaction.isPemasukan;
    _totalController = TextEditingController(
      text: NumberFormat.decimalPattern('id').format(widget.transaction.total),
    );
    _catatanController = TextEditingController(text: widget.transaction.catatan ?? '');
    
    // Inisialisasi produk jika daftar produk sudah dimuat
    final productState = context.read<ProductBloc>().state;
    if (productState is ProductLoaded && productState.products.isNotEmpty) {
      _selectedProduct = productState.products.cast<ProductEntity>().firstWhere(
        (p) => p.id == widget.transaction.productId,
        orElse: () => productState.products.first,
      );
    }
  }

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

    final String numText = _totalController.text.replaceAll(RegExp(r'[^0-9]'), '');
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

    final updatedTransaction = TransactionEntity(
      id: widget.transaction.id,
      productId: _selectedProduct!.id,
      nama: finalNama,
      qty: _qty,
      hargaSatuan: _selectedProduct!.price,
      total: total,
      isPemasukan: _isPemasukan,
      catatan: catatan.isNotEmpty ? catatan : null,
      tanggal: widget.transaction.tanggal,
    );

    context.read<TransactionBloc>().add(UpdateTransactionEvent(updatedTransaction));
    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Transaksi berhasil diperbarui!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Edit Transaksi',
          style: TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Color(0xFF1E2857),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF1E2857)),
      ),
      body: BlocBuilder<ProductBloc, ProductState>(
        builder: (context, productState) {
          if (productState is ProductLoaded && _selectedProduct == null) {
            if (productState.products.isNotEmpty) {
              _selectedProduct = productState.products.cast<ProductEntity>().firstWhere(
                (p) => p.id == widget.transaction.productId,
                orElse: () => productState.products.first,
              );
            }
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF2F4F7),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      _buildToggleButton("Pemasukan", true),
                      _buildToggleButton("Pengeluaran", false),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                const Text("PILIH PRODUK", style: _labelStyle),
                const SizedBox(height: 8),
                Container(
                  height: 56,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                  child: _buildProductDropdown(productState),
                ),
                const SizedBox(height: 24),
                const Text("JUMLAH", style: _labelStyle),
                const SizedBox(height: 8),
                _buildQtyStepper(),
                const SizedBox(height: 24),
                const Text("TOTAL", style: _labelStyle),
                const SizedBox(height: 8),
                _buildTotalField(),
                const SizedBox(height: 24),
                const Text("CATATAN TAMBAHAN", style: _labelStyle),
                const SizedBox(height: 8),
                _buildCatatanField(),
                const SizedBox(height: 40),
                _buildSubmitButton(),
              ],
            ),
          );
        },
      ),
    );
  }

  static const _labelStyle = TextStyle(
    fontFamily: 'Manrope',
    fontSize: 12,
    fontWeight: FontWeight.bold,
    color: Color(0xFF454652),
    letterSpacing: 1.2,
  );

  Widget _buildToggleButton(String label, bool value) {
    bool active = _isPemasukan == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _isPemasukan = value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: active ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: active ? [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4, offset: const Offset(0, 2))] : [],
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: active ? const Color(0xFF000666) : Colors.grey,
              fontWeight: active ? FontWeight.bold : FontWeight.normal,
              fontFamily: 'Manrope',
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQtyStepper() {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(icon: const Icon(Icons.remove), onPressed: _qty > 1 ? () => setState(() { _qty--; _updateTotal(); }) : null),
          Text("$_qty", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          IconButton(icon: const Icon(Icons.add), onPressed: () => setState(() { _qty++; _updateTotal(); })),
        ],
      ),
    );
  }

  Widget _buildTotalField() {
    return TextField(
      controller: _totalController,
      readOnly: true,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      decoration: InputDecoration(
        filled: true,
        fillColor: const Color(0xFFF1F5F9),
        prefixText: "Rp   ",
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      ),
    );
  }

  Widget _buildCatatanField() {
    return TextField(
      controller: _catatanController,
      maxLines: 3,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        hintText: "Rincian tambahan...",
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _submitData,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF000666),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        ),
        child: const Text("Simpan Perubahan", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildProductDropdown(ProductState state) {
    if (state is ProductLoaded) {
      return DropdownButtonHideUnderline(
        child: DropdownButton<ProductEntity>(
          value: _selectedProduct,
          isExpanded: true,
          items: state.products.map((p) => DropdownMenuItem(value: p, child: Text(p.name))).toList(),
          onChanged: (v) => setState(() { _selectedProduct = v; _updateTotal(); }),
        ),
      );
    }
    return const Center(child: CircularProgressIndicator());
  }
}
