import '../../../domain/entities/bottle_stock_entity.dart';

abstract class BottleStockState {}

class BottleStockInitial extends BottleStockState {}

class BottleStockLoading extends BottleStockState {}

class BottleStockLoaded extends BottleStockState {
  final List<BottleStockEntity> stocks;
  BottleStockLoaded(this.stocks);
}

class BottleStockError extends BottleStockState {
  final String message;
  BottleStockError(this.message);
}
