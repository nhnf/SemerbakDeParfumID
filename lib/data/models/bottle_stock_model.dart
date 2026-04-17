import '../../domain/entities/bottle_stock_entity.dart';

class BottleStockModel extends BottleStockEntity {
  const BottleStockModel({
    required super.ukuran,
    required super.stok,
  });

  factory BottleStockModel.fromMap(Map<String, dynamic> map) {
    return BottleStockModel(
      ukuran: map['ukuran'] as String,
      stok: (map['stok'] as num).toInt(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'ukuran': ukuran,
      'stok': stok,
    };
  }

  factory BottleStockModel.fromEntity(BottleStockEntity entity) {
    return BottleStockModel(
      ukuran: entity.ukuran,
      stok: entity.stok,
    );
  }
}
