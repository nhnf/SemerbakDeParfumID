import 'package:equatable/equatable.dart';

class TransactionEntity extends Equatable {
  final int? id;
  final String nama;
  final int total;
  final String tanggal;
  final bool isPemasukan;

  const TransactionEntity({
    this.id,
    required this.nama,
    required this.total,
    required this.tanggal,
    required this.isPemasukan,
  });

  @override
  List<Object?> get props => [id, nama, total, tanggal, isPemasukan];
}
