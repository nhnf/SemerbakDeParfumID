import '../../models/transaction_model.dart';
import 'database_helper.dart';

abstract class TransactionLocalDataSource {
  Future<List<TransactionModel>> getTransactions();
  Future<void> cacheTransaction(TransactionModel transactionToCache);
}

class TransactionLocalDataSourceImpl implements TransactionLocalDataSource {
  final DatabaseHelper databaseHelper;

  TransactionLocalDataSourceImpl({required this.databaseHelper});

  @override
  Future<List<TransactionModel>> getTransactions() async {
    final result = await databaseHelper.getTransactions();
    return result.map((json) => TransactionModel.fromMap(json)).toList();
  }

  @override
  Future<void> cacheTransaction(TransactionModel transactionToCache) async {
    await databaseHelper.insertTransaction(transactionToCache.toMap());
  }
}
