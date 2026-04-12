import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../common/widgets/card_statistik.dart';
import '../../catalog/bloc/product_bloc.dart';
import '../../catalog/bloc/product_state.dart';
import '../../transaction/bloc/transaction_bloc.dart';
import '../../transaction/bloc/transaction_state.dart';

class StatistikHome extends StatelessWidget {
  const StatistikHome({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TransactionBloc, TransactionState>(
      builder: (context, txState) {
        return BlocBuilder<ProductBloc, ProductState>(
          builder: (context, prodState) {
            final formatter = NumberFormat.decimalPattern('id');

            // Kalkulasi Total Parfum Terjual
            int totalTerjual = 0;
            if (txState is TransactionLoaded) {
              for (var tx in txState.transactions) {
                if (tx.isPemasukan) {
                  totalTerjual += tx.qty;
                }
              }
            }

            // Kalkulasi Total Stok Tersedia
            int totalStok = 0;
            if (prodState is ProductLoaded) {
              for (var p in prodState.products) {
                totalStok += p.stock;
              }
            }

            return SizedBox(
              height: 160,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    CardStatistik(
                      icon: 'assets/icons/spray.png',
                      amount: txState is TransactionLoading ? '...' : formatter.format(totalTerjual),
                      label: 'TOTAL PARFUM TERJUAL',
                    ),
                    CardStatistik(
                      icon: 'assets/icons/bottle.png',
                      amount: prodState is ProductLoading ? '...' : formatter.format(totalStok),
                      label: 'TOTAL STOK TERSEDIA',
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
