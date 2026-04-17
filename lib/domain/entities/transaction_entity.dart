import 'package:equatable/equatable.dart';

class TransactionEntity extends Equatable {
  final String? id; // UUID dari Supabase
  final String? productId; // FK ke products.id (nullable)
  final String nama;
  final String? jenis; // 'beli_baru', 'isi_ulang'
  final String? kualitas; // '1:2', '1:1', '2:1'
  final String? ukuran; // Ukuran parfum: 6ML, 10ML, 20ML, 30ML BB, dst
  final String? kategoriBahan; // 'botol', 'alkohol', 'bibit', dll
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
    this.jenis,
    this.kualitas,
    this.ukuran,
    this.kategoriBahan,
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
        jenis,
        kualitas,
        ukuran,
        kategoriBahan,
        qty,
        hargaSatuan,
        total,
        isPemasukan,
        catatan,
        tanggal,
      ];
}
