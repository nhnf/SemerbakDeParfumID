import '../../../domain/entities/product_entity.dart';
import '../../../domain/repositories/product_repository.dart';
import '../datasources/remote/supabase_datasource.dart';

class ProductRepositoryImpl implements ProductRepository {
  final SupabaseDataSource remoteDataSource;

  ProductRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<ProductEntity>> getProducts() async {
    return await remoteDataSource.getProducts();
  }
}
