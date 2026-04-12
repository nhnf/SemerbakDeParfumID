import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/add_product.dart';
import '../../../domain/usecases/get_products.dart';
import 'product_event.dart';
import 'product_state.dart';

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final GetProducts getProductsUseCase;
  final AddProduct addProductUseCase;

  ProductBloc({
    required this.getProductsUseCase,
    required this.addProductUseCase,
  }) : super(ProductInitial()) {
    on<LoadProductsEvent>((event, emit) async {
      emit(ProductLoading());
      try {
        final products = await getProductsUseCase.execute();
        emit(ProductLoaded(products));
      } catch (e) {
        emit(ProductError('Gagal mengambil data produk: ${e.toString()}'));
      }
    });

    on<AddProductEvent>((event, emit) async {
      emit(ProductLoading());
      try {
        await addProductUseCase.execute(event.product);
        final products = await getProductsUseCase.execute();
        emit(ProductLoaded(products));
      } catch (e) {
        emit(ProductError('Gagal menambah produk: ${e.toString()}'));
      }
    });
  }
}
