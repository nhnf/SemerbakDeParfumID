abstract class BottleStockEvent {}

class LoadBottleStocksEvent extends BottleStockEvent {}

class UpdateBottleStockEvent extends BottleStockEvent {
  final String ukuran;
  final int stok;
  UpdateBottleStockEvent(this.ukuran, this.stok);
}

class GenerateBottleStockEvent extends BottleStockEvent {
  final String ukuran;
  final int increment;
  GenerateBottleStockEvent(this.ukuran, this.increment);
}
