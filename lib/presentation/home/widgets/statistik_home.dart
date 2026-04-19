import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../common/widgets/card_statistik.dart';
import '../../catalog/bloc/bottle_stock_bloc.dart';
import '../../catalog/bloc/bottle_stock_state.dart';
import '../../transaction/bloc/transaction_bloc.dart';
import '../../transaction/bloc/transaction_state.dart';

class StatistikHome extends StatelessWidget {
  const StatistikHome({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TransactionBloc, TransactionState>(
      builder: (context, txState) {
        return BlocBuilder<BottleStockBloc, BottleStockState>(
          builder: (context, bottleState) {
            final formatter = NumberFormat.decimalPattern('id');

            // Kalkulasi Total Parfum Terjual
            int totalTerjual = 0;
            if (txState is TransactionLoaded) {
              for (var tx in txState.transactions) {
                // Semua transaksi pemasukan dianggap sebagai penjualan parfum
                if (tx.isPemasukan) {
                  totalTerjual += tx.qty;
                }
              }
            }

            // Kalkulasi Total Stok Tersedia (Semua Botol)
            int totalStokBotol = 0;
            if (bottleState is BottleStockLoaded) {
              for (var bottle in bottleState.stocks) {
                totalStokBotol += bottle.stok;
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
                      amount: bottleState is BottleStockLoading ? '...' : formatter.format(totalStokBotol),
                      label: 'TOTAL STOK BOTOL',
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

