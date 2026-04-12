import '../repositories/transaction_repository.dart';

class DeleteTransaction {
  final TransactionRepository repository;

  DeleteTransaction(this.repository);

  Future<void> execute(String id) {
    return repository.deleteTransaction(id);
  }
}
