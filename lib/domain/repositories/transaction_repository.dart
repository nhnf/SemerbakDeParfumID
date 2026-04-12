import '../entities/transaction_entity.dart';

abstract class TransactionRepository {
  Future<List<TransactionEntity>> getTransactions();
  // Karena hanya setup dasar, fungsi insert dll belum di-expose/implementasi untuk UI,
  // tapi untuk jaga-jaga kita siapkan:
  Future<void> addTransaction(TransactionEntity transaction);
  Future<void> updateTransaction(TransactionEntity transaction);
  Future<void> deleteTransaction(String id);
}
