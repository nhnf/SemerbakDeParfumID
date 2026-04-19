import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:semerbak_de_parfume_id/presentation/main/main_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/supabase_config.dart';
import 'data/datasources/remote/supabase_datasource.dart';
import 'data/repositories/product_repository_impl.dart';
import 'data/repositories/transaction_repository_impl.dart';
import 'data/repositories/price_config_repository_impl.dart';
import 'data/repositories/bottle_stock_repository_impl.dart';

import 'domain/usecases/add_transaction.dart';
import 'domain/usecases/add_product.dart';
import 'domain/usecases/get_products.dart';
import 'domain/usecases/get_transactions.dart';
import 'domain/usecases/update_transaction.dart';
import 'domain/usecases/delete_transaction.dart';
import 'domain/usecases/get_price_configs.dart';
import 'domain/usecases/update_price_config.dart';
import 'domain/usecases/get_bottle_stocks.dart';
import 'domain/usecases/update_bottle_stock.dart';
import 'domain/usecases/generate_bottle_stock.dart';

import 'presentation/catalog/bloc/product_bloc.dart';
import 'presentation/catalog/bloc/product_event.dart';
import 'domain/usecases/update_product.dart';
import 'domain/usecases/delete_product.dart';
import 'presentation/catalog/bloc/price_config_bloc.dart';
import 'presentation/catalog/bloc/price_config_event.dart';
import 'presentation/catalog/bloc/bottle_stock_bloc.dart';
import 'presentation/catalog/bloc/bottle_stock_event.dart';
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

  final transactionRepository = TransactionRepositoryImpl(remoteDataSource: supabaseDataSource);
  final productRepository = ProductRepositoryImpl(remoteDataSource: supabaseDataSource);
  final priceConfigRepository = PriceConfigRepositoryImpl(remoteDataSource: supabaseDataSource);
  final bottleStockRepository = BottleStockRepositoryImpl(remoteDataSource: supabaseDataSource);

  final getTransactions = GetTransactions(transactionRepository);
  final addTransaction = AddTransaction(transactionRepository);
  final updateTransaction = UpdateTransaction(transactionRepository);
  final deleteTransaction = DeleteTransaction(transactionRepository);
  final getProducts = GetProducts(productRepository);
  final addProduct = AddProduct(productRepository);
  final updateProduct = UpdateProduct(productRepository);
  final deleteProduct = DeleteProduct(productRepository);

  final getPriceConfigs = GetPriceConfigs(priceConfigRepository);
  final updatePriceConfig = UpdatePriceConfig(priceConfigRepository);

  final getBottleStocks = GetBottleStocks(bottleStockRepository);
  final updateBottleStock = UpdateBottleStock(bottleStockRepository);
  final generateBottleStock = GenerateBottleStock(bottleStockRepository);

  runApp(
    MyApp(
      getTransactionsUseCase: getTransactions,
      addTransactionUseCase: addTransaction,
      updateTransactionUseCase: updateTransaction,
      deleteTransactionUseCase: deleteTransaction,
      getProductsUseCase: getProducts,
      addProductUseCase: addProduct,
      updateProductUseCase: updateProduct,
      deleteProductUseCase: deleteProduct,
      getPriceConfigsUseCase: getPriceConfigs,
      updatePriceConfigUseCase: updatePriceConfig,
      getBottleStocksUseCase: getBottleStocks,
      updateBottleStockUseCase: updateBottleStock,
      generateBottleStockUseCase: generateBottleStock,
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
  final UpdateProduct updateProductUseCase;
  final DeleteProduct deleteProductUseCase;

  final GetPriceConfigs getPriceConfigsUseCase;
  final UpdatePriceConfig updatePriceConfigUseCase;

  final GetBottleStocks getBottleStocksUseCase;
  final UpdateBottleStock updateBottleStockUseCase;
  final GenerateBottleStock generateBottleStockUseCase;

  const MyApp({
    super.key,
    required this.getTransactionsUseCase,
    required this.addTransactionUseCase,
    required this.updateTransactionUseCase,
    required this.deleteTransactionUseCase,
    required this.getProductsUseCase,
    required this.addProductUseCase,
    required this.updateProductUseCase,
    required this.deleteProductUseCase,
    required this.getPriceConfigsUseCase,
    required this.updatePriceConfigUseCase,
    required this.getBottleStocksUseCase,
    required this.updateBottleStockUseCase,
    required this.generateBottleStockUseCase,
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
          create: (context) => ProductBloc(
            getProductsUseCase: getProductsUseCase,
            addProductUseCase: addProductUseCase,
            updateProductUseCase: updateProductUseCase,
            deleteProductUseCase: deleteProductUseCase,
          )..add(LoadProductsEvent()),
        ),
        BlocProvider<PriceConfigBloc>(
          create: (context) => PriceConfigBloc(
            getPriceConfigsUseCase: getPriceConfigsUseCase,
            updatePriceConfigUseCase: updatePriceConfigUseCase,
          )..add(LoadPriceConfigsEvent()),
        ),
        BlocProvider<BottleStockBloc>(
          create: (context) => BottleStockBloc(
            getBottleStocksUseCase: getBottleStocksUseCase,
            updateBottleStockUseCase: updateBottleStockUseCase,
            generateBottleStockUseCase: generateBottleStockUseCase,
          )..add(LoadBottleStocksEvent()),
        ),
      ],
      child: MaterialApp(
        title: 'Semerbak De Parfume ID',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(225, 0, 6, 102)),
        ),
        home: const MainPage(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
