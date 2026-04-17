import '../entities/bottle_stock_entity.dart';

abstract class BottleStockRepository {
  Future<List<BottleStockEntity>> getBottleStocks();
  Future<void> updateBottleStock(String ukuran, int stok);
  Future<void> generateBottleStock(String ukuran, int increment);
}
