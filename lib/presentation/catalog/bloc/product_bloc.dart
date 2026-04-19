import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/add_product.dart';
import '../../../domain/usecases/get_products.dart';
import '../../../domain/usecases/update_product.dart';
import '../../../domain/usecases/delete_product.dart';
import 'product_event.dart';
import 'product_state.dart';

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final GetProducts getProductsUseCase;
  final AddProduct addProductUseCase;
  final UpdateProduct updateProductUseCase;
  final DeleteProduct deleteProductUseCase;

  ProductBloc({
    required this.getProductsUseCase,
    required this.addProductUseCase,
    required this.updateProductUseCase,
    required this.deleteProductUseCase,
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

    on<UpdateProductEvent>((event, emit) async {
      emit(ProductLoading());
      try {
        await updateProductUseCase.execute(event.product);
        final products = await getProductsUseCase.execute();
        emit(ProductLoaded(products));
      } catch (e) {
        emit(ProductError('Gagal update produk: ${e.toString()}'));
      }
    });

    on<DeleteProductEvent>((event, emit) async {
      emit(ProductLoading());
      try {
        await deleteProductUseCase.execute(event.productId);
        final products = await getProductsUseCase.execute();
        emit(ProductLoaded(products));
      } catch (e) {
        emit(ProductError('Gagal hapus produk: ${e.toString()}'));
      }
    });
  }
}
