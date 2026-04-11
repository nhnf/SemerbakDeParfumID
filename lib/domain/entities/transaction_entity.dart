import 'package:equatable/equatable.dart';

class TransactionEntity extends Equatable {
  final String? id; // UUID dari Supabase
  final String? productId; // FK ke products.id (nullable)
  final String nama;
  final int qty;
  final int hargaSatuan;
  final int total;
  final bool isPemasukan;
  final String? catatan;
  final DateTime tanggal;

  const TransactionEntity({
    this.id,
    this.productId,
    required this.nama,
    required this.qty,
    required this.hargaSatuan,
    required this.total,
    required this.isPemasukan,
    this.catatan,
    required this.tanggal,
  });

  @override
  List<Object?> get props => [
        id,
        productId,
        nama,
        qty,
        hargaSatuan,
        total,
        isPemasukan,
        catatan,
        tanggal,
      ];
}
