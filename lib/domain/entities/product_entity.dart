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
}
