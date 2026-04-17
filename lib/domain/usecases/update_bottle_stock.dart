import '../repositories/bottle_stock_repository.dart';

class UpdateBottleStock {
  final BottleStockRepository repository;

  UpdateBottleStock(this.repository);

  Future<void> execute(String ukuran, int stok) async {
    return await repository.updateBottleStock(ukuran, stok);
  }
}
