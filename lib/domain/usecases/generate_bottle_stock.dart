import '../repositories/bottle_stock_repository.dart';

class GenerateBottleStock {
  final BottleStockRepository repository;

  GenerateBottleStock(this.repository);

  Future<void> execute(String ukuran, int increment) async {
    return await repository.generateBottleStock(ukuran, increment);
  }
}
