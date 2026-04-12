import 'package:equatable/equatable.dart';
import '../../../domain/entities/product_entity.dart';

abstract class ProductEvent extends Equatable {
  const ProductEvent();
  @override
  List<Object> get props => [];
}

class LoadProductsEvent extends ProductEvent {}

class AddProductEvent extends ProductEvent {
  final ProductEntity product;

  const AddProductEvent(this.product);

  @override
  List<Object> get props => [product];
}
