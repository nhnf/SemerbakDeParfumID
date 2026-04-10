import '../../domain/entities/transaction_entity.dart';

class TransactionModel extends TransactionEntity {
  const TransactionModel({
    super.id,
    required super.nama,
    required super.total,
    required super.tanggal,
    required super.isPemasukan,
  });

  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'],
      nama: map['nama'],
      total: map['total'],
      tanggal: map['tanggal'],
      isPemasukan: map['isPemasukan'] == 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nama': nama,
      'total': total,
      'tanggal': tanggal,
      'isPemasukan': isPemasukan ? 1 : 0,
    };
  }

  factory TransactionModel.fromEntity(TransactionEntity entity) {
    return TransactionModel(
      id: entity.id,
      nama: entity.nama,
      total: entity.total,
      tanggal: entity.tanggal,
      isPemasukan: entity.isPemasukan,
    );
  }
}
