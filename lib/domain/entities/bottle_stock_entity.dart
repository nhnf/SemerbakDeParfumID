import 'package:equatable/equatable.dart';

class BottleStockEntity extends Equatable {
  final String ukuran;
  final int stok;

  const BottleStockEntity({
    required this.ukuran,
    required this.stok,
  });

  BottleStockEntity copyWith({int? stok}) {
    return BottleStockEntity(
      ukuran: ukuran,
      stok: stok ?? this.stok,
    );
  }

  @override
  List<Object?> get props => [ukuran, stok];
}
