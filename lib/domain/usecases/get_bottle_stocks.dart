import '../entities/bottle_stock_entity.dart';
import '../repositories/bottle_stock_repository.dart';

class GetBottleStocks {
  final BottleStockRepository repository;

  GetBottleStocks(this.repository);

  Future<List<BottleStockEntity>> execute() async {
    return await repository.getBottleStocks();
  }
}
