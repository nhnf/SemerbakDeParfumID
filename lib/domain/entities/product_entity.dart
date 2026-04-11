import 'package:equatable/equatable.dart';

class ProductEntity extends Equatable {
  final String id;
  final String name;
  final String category;
  final int price;
  final int stock;

  const ProductEntity({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.stock,
  });

  @override
  List<Object?> get props => [id, name, category, price, stock];
}
