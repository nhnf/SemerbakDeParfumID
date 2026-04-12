import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_colors.dart';
import '../widgets/header_home.dart';
import 'package:semerbak_de_parfume_id/presentation/home/widgets/statistik_home.dart';
import '../../common/widgets/section_header.dart';
import '../widgets/recent_transactions_list.dart';
import '../../transaction/pages/all_transactions_page.dart';
import '../../transaction/bloc/transaction_bloc.dart';
import '../../transaction/bloc/transaction_event.dart';
import '../../catalog/bloc/product_bloc.dart';
import '../../catalog/bloc/product_event.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: () async {
            context.read<TransactionBloc>().add(LoadTransactionsEvent());
            context.read<ProductBloc>().add(LoadProductsEvent());
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: const BoxDecoration(
                          color: AppColors.primaryNavy,
                          shape: BoxShape.circle,
                        ),
                        child: Image.asset(
                          'assets/icons/bottle.png',
                          width: 36,
                          height: 36,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        "Semerbak De Parfume ID",
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryNavy,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  width: width,
                  height: 366.5,
                  decoration: BoxDecoration(
                    color: AppColors.primaryNavy,
                    borderRadius: BorderRadius.circular(32),
                  ),
                  child: const HeaderHome(),
                ),
              ),
              const SectionHeader(judul: "Statistik Cepat"),
              const StatistikHome(),
              SectionHeader(
                judul: "Transaksi Terakhir",
                onSeeAll: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AllTransactionsPage(),
                    ),
                  );
                },
              ),
              const RecentTransactionsList(),
              const SizedBox(height: 200),
            ],
          ),
        ),
        ),
      ),
    );
  }
}
