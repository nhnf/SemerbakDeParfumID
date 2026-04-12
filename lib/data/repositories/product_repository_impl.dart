import '../../../domain/entities/product_entity.dart';
import '../../../domain/repositories/product_repository.dart';
import '../models/product_model.dart';
import '../datasources/remote/supabase_datasource.dart';

class ProductRepositoryImpl implements ProductRepository {
  final SupabaseDataSource remoteDataSource;

  ProductRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<ProductEntity>> getProducts() async {
    return await remoteDataSource.getProducts();
  }

  @override
  Future<void> addProduct(ProductEntity product) async {
    final model = ProductModel.fromEntity(product);
    await remoteDataSource.insertProduct(model);
  }
}
