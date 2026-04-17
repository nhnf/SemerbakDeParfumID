import '../../../domain/entities/bottle_stock_entity.dart';
import '../../../domain/repositories/bottle_stock_repository.dart';
import '../datasources/remote/supabase_datasource.dart';

class BottleStockRepositoryImpl implements BottleStockRepository {
  final SupabaseDataSource remoteDataSource;

  BottleStockRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<BottleStockEntity>> getBottleStocks() async {
    return await remoteDataSource.getBottleStocks();
  }

  @override
  Future<void> updateBottleStock(String ukuran, int stok) async {
    await remoteDataSource.updateBottleStock(ukuran, stok);
  }

  @override
  Future<void> generateBottleStock(String ukuran, int increment) async {
    await remoteDataSource.generateBottleStock(ukuran, increment);
  }
}
