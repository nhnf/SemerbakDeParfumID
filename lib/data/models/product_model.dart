import '../../domain/entities/product_entity.dart';

class ProductModel extends ProductEntity {
  const ProductModel({
    super.id,
    required super.name,
    required super.category,
    required super.price,
    required super.stock,
  });

  factory ProductModel.fromMap(Map<String, dynamic> map) {
    return ProductModel(
      id: map['id'] as String?,
      name: map['name'] as String,
      category: map['category'] as String? ?? '',
      price: (map['price'] as num).toInt(),
      stock: (map['stock'] as num).toInt(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'price': price,
      'stock': stock,
    };
  }

  Map<String, dynamic> toInsertMap() {
    return {
      'name': name,
      'category': category,
      if (price != null) 'price': price,
      if (stock != null) 'stock': stock,
    };
  }

  factory ProductModel.fromEntity(ProductEntity entity) {
    return ProductModel(
      id: entity.id,
      name: entity.name,
      category: entity.category,
      price: entity.price,
      stock: entity.stock,
    );
  }
}
