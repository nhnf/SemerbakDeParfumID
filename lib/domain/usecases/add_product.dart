import '../entities/product_entity.dart';
import '../repositories/product_repository.dart';

class AddProduct {
  final ProductRepository repository;

  AddProduct(this.repository);

  Future<void> execute(ProductEntity product) async {
    return await repository.addProduct(product);
  }
}
