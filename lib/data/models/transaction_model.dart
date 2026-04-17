import '../../domain/entities/transaction_entity.dart';

class TransactionModel extends TransactionEntity {
  const TransactionModel({
    super.id,
    super.productId,
    required super.nama,
    super.jenis,
    super.kualitas,
    super.ukuran,
    super.kategoriBahan,
    required super.qty,
    required super.hargaSatuan,
    required super.total,
    required super.isPemasukan,
    super.catatan,
    required super.tanggal,
  });

  /// Membuat model dari response JSON Supabase
  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'] as String?,
      productId: map['product_id'] as String?,
      nama: map['nama'] as String,
      jenis: map['jenis'] as String?,
      kualitas: map['kualitas'] as String?,
      ukuran: map['ukuran'] as String?,
      kategoriBahan: map['kategori_bahan'] as String?,
      qty: (map['qty'] as num?)?.toInt() ?? 1,
      hargaSatuan: (map['harga_satuan'] as num?)?.toInt() ?? 0,
      total: (map['total'] as num).toInt(),
      isPemasukan: map['is_pemasukan'] as bool,
      catatan: map['catatan'] as String?,
      tanggal: DateTime.parse(map['tanggal'] as String),
    );
  }

  /// Mengkonversi ke Map untuk dikirim ke Supabase (INSERT/UPDATE)
  Map<String, dynamic> toInsertMap() {
    return {
      if (productId != null) 'product_id': productId,
      'nama': nama,
      if (jenis != null) 'jenis': jenis,
      if (kualitas != null) 'kualitas': kualitas,
      if (ukuran != null) 'ukuran': ukuran,
      if (kategoriBahan != null) 'kategori_bahan': kategoriBahan,
      'qty': qty,
      'harga_satuan': hargaSatuan,
      'total': total,
      'is_pemasukan': isPemasukan,
      if (catatan != null && catatan!.isNotEmpty) 'catatan': catatan,
      'tanggal': tanggal.toIso8601String(),
    };
  }

  factory TransactionModel.fromEntity(TransactionEntity entity) {
    return TransactionModel(
      id: entity.id,
      productId: entity.productId,
      nama: entity.nama,
      jenis: entity.jenis,
      kualitas: entity.kualitas,
      ukuran: entity.ukuran,
      kategoriBahan: entity.kategoriBahan,
      qty: entity.qty,
      hargaSatuan: entity.hargaSatuan,
      total: entity.total,
      isPemasukan: entity.isPemasukan,
      catatan: entity.catatan,
      tanggal: entity.tanggal,
    );
  }
}
