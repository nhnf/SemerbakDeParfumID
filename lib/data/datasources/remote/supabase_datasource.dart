import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/product_model.dart';
import '../../models/transaction_model.dart';
import '../../models/price_config_model.dart';
import '../../models/bottle_stock_model.dart';

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

  /// Insert produk baru
  Future<ProductModel> insertProduct(ProductModel model) async {
    final response = await _client
        .from('products')
        .insert(model.toInsertMap())
        .select()
        .single();
    return ProductModel.fromMap(response);
  }

  /// Update produk berdasarkan ID
  Future<void> updateProduct(ProductModel model) async {
    if (model.id == null) throw Exception('Product ID is required for update.');
    await _client
        .from('products')
        .update({'name': model.name, 'category': model.category, 'stock': model.stock})
        .eq('id', model.id!);
  }

  /// Hapus produk berdasarkan ID
  Future<void> deleteProduct(String productId) async {
    await _client.from('products').delete().eq('id', productId);
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

  /// Update transaksi berdasarkan ID
  Future<TransactionModel> updateTransaction(TransactionModel model) async {
    if (model.id == null) throw Exception("Transaction ID is required for update.");
    final response = await _client
        .from('transactions')
        .update(model.toInsertMap())
        .eq('id', model.id!)
        .select()
        .single();
    return TransactionModel.fromMap(response);
  }

  /// Hapus transaksi berdasarkan ID
  Future<void> deleteTransaction(String id) async {
    await _client.from('transactions').delete().eq('id', id);
  }

  // ============================================================
  // PRICE CONFIG
  // ============================================================

  Future<List<PriceConfigModel>> getPriceConfigs() async {
    final response = await _client.from('price_config').select();
    return (response as List<dynamic>)
        .map((json) => PriceConfigModel.fromMap(json as Map<String, dynamic>))
        .toList();
  }

  Future<void> updatePriceConfig(PriceConfigModel model) async {
    await _client
        .from('price_config')
        .update({'harga': model.harga})
        .eq('jenis', model.jenis)
        .eq('kualitas', model.kualitas)
        .eq('ukuran', model.ukuran);
  }

  // ============================================================
  // BOTTLE STOCK
  // ============================================================

  Future<List<BottleStockModel>> getBottleStocks() async {
    final response = await _client.from('bottle_stock').select().order('ukuran', ascending: true);
    return (response as List<dynamic>)
        .map((json) => BottleStockModel.fromMap(json as Map<String, dynamic>))
        .toList();
  }

  Future<void> updateBottleStock(String ukuran, int stok) async {
    await _client
        .from('bottle_stock')
        .update({'stok': stok})
        .eq('ukuran', ukuran);
  }

  Future<void> generateBottleStock(String ukuran, int increment) async {
    // Dipanggil untuk nambah/ngurang stok saat transaksi dsb. (Supabase RPC lebih baik, tapi sementara kita ambil -> update)
    final response = await _client.from('bottle_stock').select('stok').eq('ukuran', ukuran).single();
    final currentStok = (response['stok'] as num).toInt();
    final newStok = currentStok + increment;
    
    await _client
        .from('bottle_stock')
        .update({'stok': newStok < 0 ? 0 : newStok})
        .eq('ukuran', ukuran);
  }
}
