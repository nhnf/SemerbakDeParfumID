import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/add_transaction.dart';
import '../../../domain/usecases/get_transactions.dart';
import '../../../domain/usecases/update_transaction.dart';
import '../../../domain/usecases/delete_transaction.dart';
import 'transaction_event.dart';
import 'transaction_state.dart';

class TransactionBloc extends Bloc<TransactionEvent, TransactionState> {
  final GetTransactions getTransactionsUseCase;
  final AddTransaction addTransactionUseCase;
  final UpdateTransaction updateTransactionUseCase;
  final DeleteTransaction deleteTransactionUseCase;

  TransactionBloc({
    required this.getTransactionsUseCase,
    required this.addTransactionUseCase,
    required this.updateTransactionUseCase,
    required this.deleteTransactionUseCase,
  }) : super(TransactionInitial()) {
    on<LoadTransactionsEvent>((event, emit) async {
      emit(TransactionLoading());
      try {
        final transactions = await getTransactionsUseCase.execute();
        emit(TransactionLoaded(transactions));
      } catch (e) {
        emit(TransactionError("Gagal mengambil data transaksi: ${e.toString()}"));
      }
    });

    on<AddTransactionEvent>((event, emit) async {
      emit(TransactionLoading());
      try {
        await addTransactionUseCase.execute(event.transaction);
        final transactions = await getTransactionsUseCase.execute();
        emit(TransactionLoaded(transactions));
      } catch (e) {
        emit(TransactionError("Gagal menambah transaksi: ${e.toString()}"));
      }
    });

    on<UpdateTransactionEvent>((event, emit) async {
      emit(TransactionLoading());
      try {
        await updateTransactionUseCase.execute(event.transaction);
        final transactions = await getTransactionsUseCase.execute();
        emit(TransactionLoaded(transactions));
      } catch (e) {
        emit(TransactionError("Gagal mengubah transaksi: ${e.toString()}"));
      }
    });

    on<DeleteTransactionEvent>((event, emit) async {
      emit(TransactionLoading());
      try {
        await deleteTransactionUseCase.execute(event.id);
        final transactions = await getTransactionsUseCase.execute();
        emit(TransactionLoaded(transactions));
      } catch (e) {
        emit(TransactionError("Gagal menghapus transaksi: ${e.toString()}"));
      }
    });
  }
}
