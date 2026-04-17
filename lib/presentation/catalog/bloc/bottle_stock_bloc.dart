import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/get_bottle_stocks.dart';
import '../../../domain/usecases/update_bottle_stock.dart';
import '../../../domain/usecases/generate_bottle_stock.dart';
import 'bottle_stock_event.dart';
import 'bottle_stock_state.dart';

class BottleStockBloc extends Bloc<BottleStockEvent, BottleStockState> {
  final GetBottleStocks getBottleStocksUseCase;
  final UpdateBottleStock updateBottleStockUseCase;
  final GenerateBottleStock generateBottleStockUseCase;

  BottleStockBloc({
    required this.getBottleStocksUseCase,
    required this.updateBottleStockUseCase,
    required this.generateBottleStockUseCase,
  }) : super(BottleStockInitial()) {
    on<LoadBottleStocksEvent>((event, emit) async {
      emit(BottleStockLoading());
      try {
        final stocks = await getBottleStocksUseCase.execute();
        emit(BottleStockLoaded(stocks));
      } catch (e) {
        emit(BottleStockError('Gagal memuat stok botol: ${e.toString()}'));
      }
    });

    on<UpdateBottleStockEvent>((event, emit) async {
      try {
        await updateBottleStockUseCase.execute(event.ukuran, event.stok);
        add(LoadBottleStocksEvent());
      } catch (e) {
        print('Error updating bottle stock: $e');
        add(LoadBottleStocksEvent());
      }
    });

    on<GenerateBottleStockEvent>((event, emit) async {
      try {
        await generateBottleStockUseCase.execute(event.ukuran, event.increment);
        add(LoadBottleStocksEvent());
      } catch (e) {
        print('Error generating bottle stock: $e');
        add(LoadBottleStocksEvent());
      }
    });
  }
}
