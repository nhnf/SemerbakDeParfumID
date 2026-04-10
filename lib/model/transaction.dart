class Transaction {
  final String nama;
  final String jumlah;
  final String harga;
  final String total;
  final String tanggal;
  final bool isPemasukan;

  Transaction({
    required this.nama,
    required this.jumlah,
    required this.harga,
    required this.total,
    required this.tanggal,
    required this.isPemasukan,
  });
}
