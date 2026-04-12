import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:semerbak_de_parfume_id/presentation/main/main_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/supabase_config.dart';
import 'data/datasources/remote/supabase_datasource.dart';
import 'data/repositories/product_repository_impl.dart';
import 'data/repositories/transaction_repository_impl.dart';
import 'domain/usecases/add_transaction.dart';
import 'domain/usecases/add_product.dart';
import 'domain/usecases/get_products.dart';
import 'domain/usecases/get_transactions.dart';
import 'domain/usecases/update_transaction.dart';
import 'domain/usecases/delete_transaction.dart';
import 'presentation/catalog/bloc/product_bloc.dart';
import 'presentation/catalog/bloc/product_event.dart';
import 'presentation/transaction/bloc/transaction_bloc.dart';
import 'presentation/transaction/bloc/transaction_event.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id', null);

  // Inisialisasi Supabase
  await Supabase.initialize(
    url: SupabaseConfig.projectUrl,
    anonKey: SupabaseConfig.anonKey,
  );

  // Dependency Injection (Manual Clean Architecture)
  final supabaseClient = Supabase.instance.client;
  final supabaseDataSource = SupabaseDataSource(supabaseClient);

  final transactionRepository = TransactionRepositoryImpl(
    remoteDataSource: supabaseDataSource,
  );
  final productRepository = ProductRepositoryImpl(
    remoteDataSource: supabaseDataSource,
  );

  final getTransactions = GetTransactions(transactionRepository);
  final addTransaction = AddTransaction(transactionRepository);
  final updateTransaction = UpdateTransaction(transactionRepository);
  final deleteTransaction = DeleteTransaction(transactionRepository);
  final getProducts = GetProducts(productRepository);
  final addProduct = AddProduct(productRepository);

  runApp(
    MyApp(
      getTransactionsUseCase: getTransactions,
      addTransactionUseCase: addTransaction,
      updateTransactionUseCase: updateTransaction,
      deleteTransactionUseCase: deleteTransaction,
      getProductsUseCase: getProducts,
      addProductUseCase: addProduct,
    ),
  );
}

class MyApp extends StatelessWidget {
  final GetTransactions getTransactionsUseCase;
  final AddTransaction addTransactionUseCase;
  final UpdateTransaction updateTransactionUseCase;
  final DeleteTransaction deleteTransactionUseCase;
  final GetProducts getProductsUseCase;
  final AddProduct addProductUseCase;

  const MyApp({
    super.key,
    required this.getTransactionsUseCase,
    required this.addTransactionUseCase,
    required this.updateTransactionUseCase,
    required this.deleteTransactionUseCase,
    required this.getProductsUseCase,
    required this.addProductUseCase,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<TransactionBloc>(
          create: (context) => TransactionBloc(
            getTransactionsUseCase: getTransactionsUseCase,
            addTransactionUseCase: addTransactionUseCase,
            updateTransactionUseCase: updateTransactionUseCase,
            deleteTransactionUseCase: deleteTransactionUseCase,
          )..add(LoadTransactionsEvent()),
        ),
        BlocProvider<ProductBloc>(
          create: (context) =>
              ProductBloc(
                getProductsUseCase: getProductsUseCase,
                addProductUseCase: addProductUseCase,
              )..add(LoadProductsEvent()),
        ),
      ],
      child: MaterialApp(
        title: 'Semerbak De Parfume ID',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        ),
        home: const MainPage(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
