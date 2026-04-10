import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:semerbak_de_parfume_id/presentation/main/main_page.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'data/datasources/local/database_helper.dart';
import 'data/datasources/local/transaction_local_datasource.dart';
import 'data/repositories/transaction_repository_impl.dart';
import 'domain/usecases/add_transaction.dart';
import 'domain/usecases/get_transactions.dart';
import 'presentation/bloc/transaction/transaction_bloc.dart';
import 'presentation/bloc/transaction/transaction_event.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isWindows || Platform.isLinux) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }
  
  // Clean Architecture Dependency Injection (Manual)
  final databaseHelper = DatabaseHelper();
  final localDataSource = TransactionLocalDataSourceImpl(databaseHelper: databaseHelper);
  final repository = TransactionRepositoryImpl(localDataSource: localDataSource);
  final getTransactions = GetTransactions(repository);
  final addTransaction = AddTransaction(repository);

  runApp(MyApp(
    getTransactionsUseCase: getTransactions,
    addTransactionUseCase: addTransaction,
  ));
}

class MyApp extends StatelessWidget {
  final GetTransactions getTransactionsUseCase;
  final AddTransaction addTransactionUseCase;

  const MyApp({
    super.key,
    required this.getTransactionsUseCase,
    required this.addTransactionUseCase,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<TransactionBloc>(
          create: (context) => TransactionBloc(
            getTransactionsUseCase: getTransactionsUseCase,
            addTransactionUseCase: addTransactionUseCase,
          )..add(LoadTransactionsEvent()),
        ),
      ],
      child: MaterialApp(
        title: 'Semerbak De Parfume ID',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        ),
        // Mengubah awal halaman (Home) ke kerangka MainPage yang memuat Navbar
        home: const MainPage(),
      ),
    );
  }
}
