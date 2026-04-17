import 'package:equatable/equatable.dart';

class PriceConfigEntity extends Equatable {
  final String? id;
  final String jenis;   // 'beli_baru' | 'isi_ulang'
  final String kualitas; // '1:2' | '1:1' | '2:1'
  final String ukuran;  // '6ML' | '10ML' | ...
  final int harga;

  const PriceConfigEntity({
    this.id,
    required this.jenis,
    required this.kualitas,
    required this.ukuran,
    required this.harga,
  });

  PriceConfigEntity copyWith({int? harga}) {
    return PriceConfigEntity(
      id: id,
      jenis: jenis,
      kualitas: kualitas,
      ukuran: ukuran,
      harga: harga ?? this.harga,
    );
  }

  @override
  List<Object?> get props => [id, jenis, kualitas, ukuran, harga];
}
