import 'package:equatable/equatable.dart';

class ProductEntity extends Equatable {
  final String? id;
  final String name;
  final String category;
  final int stock;

  const ProductEntity({
    this.id,
    required this.name,
    required this.category,
    required this.stock,
  });

  @override
  List<Object?> get props => [id, name, category, stock];

  ProductEntity copyWith({
    String? id,
    String? name,
    String? category,
    int? stock,
  }) {
    return ProductEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      stock: stock ?? this.stock,
    );
  }
}
