import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/add_transaction.dart';
import '../../../domain/usecases/get_transactions.dart';
import 'transaction_event.dart';
import 'transaction_state.dart';

class TransactionBloc extends Bloc<TransactionEvent, TransactionState> {
  final GetTransactions getTransactionsUseCase;
  final AddTransaction addTransactionUseCase;

  TransactionBloc({
    required this.getTransactionsUseCase,
    required this.addTransactionUseCase,
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
      // Ingat state sebelumnya jika ada (untuk mencegah layar kedip jika tidak perlu loading layar penuh)
      emit(TransactionLoading());
      try {
        // Eksekusi fungsi simpan ke lokal DB
        await addTransactionUseCase.execute(event.transaction);
        // Setelah sukses, muat ulang daftar transaksi terbaru
        final transactions = await getTransactionsUseCase.execute();
        emit(TransactionLoaded(transactions));
      } catch (e) {
        emit(TransactionError("Gagal menambah transaksi: ${e.toString()}"));
      }
    });
  }
}
