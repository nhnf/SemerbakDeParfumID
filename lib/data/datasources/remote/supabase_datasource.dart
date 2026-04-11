import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/product_model.dart';
import '../../models/transaction_model.dart';

/// Remote datasource yang berkomunikasi langsung dengan Supabase
class SupabaseDataSource {
  final SupabaseClient _client;

  SupabaseDataSource(this._client);

  // ============================================================
  // PRODUCTS
  // ============================================================

  /// Ambil semua produk dari tabel `products`, urut berdasarkan nama
  Future<List<ProductModel>> getProducts() async {
    final response = await _client
        .from('products')
        .select()
        .order('name', ascending: true);

    return (response as List<dynamic>)
        .map((json) => ProductModel.fromMap(json as Map<String, dynamic>))
        .toList();
  }

  // ============================================================
  // TRANSACTIONS
  // ============================================================

  /// Ambil semua transaksi, urut dari terbaru
  Future<List<TransactionModel>> getTransactions() async {
    final response = await _client
        .from('transactions')
        .select()
        .order('tanggal', ascending: false);

    return (response as List<dynamic>)
        .map((json) => TransactionModel.fromMap(json as Map<String, dynamic>))
        .toList();
  }

  /// Insert transaksi baru dan kembalikan data yang tersimpan
  Future<TransactionModel> insertTransaction(TransactionModel model) async {
    final response = await _client
        .from('transactions')
        .insert(model.toInsertMap())
        .select()
        .single();

    return TransactionModel.fromMap(response);
  }

  /// Hapus transaksi berdasarkan ID
  Future<void> deleteTransaction(String id) async {
    await _client.from('transactions').delete().eq('id', id);
  }
}
