import '../../domain/entities/product_entity.dart';

class ProductModel extends ProductEntity {
  const ProductModel({
    super.id,
    required super.name,
    required super.category,
    required super.stock,
  });

  factory ProductModel.fromMap(Map<String, dynamic> map) {
    return ProductModel(
      id: map['id']?.toString() ?? map['uuid']?.toString() ?? map['name']?.toString(),
      name: map['name'] as String? ?? 'Unknown',
      category: map['category'] as String? ?? '',
      stock: (map['stock'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'stock': stock,
    };
  }

  Map<String, dynamic> toInsertMap() {
    return {
      'name': name,
      'category': category,
      if (stock != null) 'stock': stock,
    };
  }

  factory ProductModel.fromEntity(ProductEntity entity) {
    return ProductModel(
      id: entity.id,
      name: entity.name,
      category: entity.category,
      stock: entity.stock,
    );
  }
}
