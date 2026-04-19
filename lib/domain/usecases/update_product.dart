import '../entities/product_entity.dart';
import '../repositories/product_repository.dart';

class UpdateProduct {
  final ProductRepository repository;

  UpdateProduct(this.repository);

  Future<void> execute(ProductEntity product) async {
    return await repository.updateProduct(product);
  }
}
