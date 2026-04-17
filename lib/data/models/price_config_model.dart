import '../../domain/entities/price_config_entity.dart';

class PriceConfigModel extends PriceConfigEntity {
  const PriceConfigModel({
    super.id,
    required super.jenis,
    required super.kualitas,
    required super.ukuran,
    required super.harga,
  });

  factory PriceConfigModel.fromMap(Map<String, dynamic> map) {
    return PriceConfigModel(
      id: map['id'] as String?,
      jenis: map['jenis'] as String,
      kualitas: map['kualitas'] as String,
      ukuran: map['ukuran'] as String,
      harga: (map['harga'] as num).toInt(),
    );
  }

  Map<String, dynamic> toInsertMap() {
    return {
      'jenis': jenis,
      'kualitas': kualitas,
      'ukuran': ukuran,
      'harga': harga,
    };
  }

  factory PriceConfigModel.fromEntity(PriceConfigEntity entity) {
    return PriceConfigModel(
      id: entity.id,
      jenis: entity.jenis,
      kualitas: entity.kualitas,
      ukuran: entity.ukuran,
      harga: entity.harga,
    );
  }
}
