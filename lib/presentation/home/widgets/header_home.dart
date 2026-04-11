import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../transaction/bloc/transaction_bloc.dart';
import '../../transaction/bloc/transaction_state.dart';
import '../../common/widgets/card_cash_flow.dart';

class HeaderHome extends StatelessWidget {
  const HeaderHome({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TransactionBloc, TransactionState>(
      builder: (context, state) {
        int totalPemasukan = 0;
        int totalPengeluaran = 0;

        if (state is TransactionLoaded) {
          final now = DateTime.now();
          final bulanIni = state.transactions.where((t) =>
              t.tanggal.year == now.year && t.tanggal.month == now.month);

          for (final t in bulanIni) {
            if (t.isPemasukan) {
              totalPemasukan += t.total;
            } else {
              totalPengeluaran += t.total;
            }
          }
        }

        final labaRugi = totalPemasukan - totalPengeluaran;

        return Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'LABA/RUGI BULAN INI',
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 2.4,
                ),
              ),
              if (state is TransactionLoading)
                const Padding(
                  padding: EdgeInsets.only(top: 16),
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  ),
                )
              else
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      'Rp',
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 24,
                        fontWeight: FontWeight.normal,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        CurrencyFormatter.format(labaRugi.abs()),
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 36,
                          fontWeight: FontWeight.w900,
                          color: labaRugi < 0
                              ? Colors.red.shade200
                              : Colors.white,
                          letterSpacing: -1.2,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (labaRugi < 0)
                      const Padding(
                        padding: EdgeInsets.only(left: 4, bottom: 4),
                        child: Text(
                          '(Rugi)',
                          style: TextStyle(
                            fontFamily: 'Manrope',
                            fontSize: 12,
                            color: AppColors.redDescent,
                          ),
                        ),
                      ),
                  ],
                ),
              const SizedBox(height: 32),
              CardCashFlow(
                label: 'PEMASUKAN',
                amount: CurrencyFormatter.formatWithSymbol(totalPemasukan),
                icon: Icons.arrow_upward,
                iconColor: AppColors.greenAscent,
              ),
              const SizedBox(height: 16),
              CardCashFlow(
                label: 'PENGELUARAN',
                amount: CurrencyFormatter.formatWithSymbol(totalPengeluaran),
                icon: Icons.arrow_downward,
                iconColor: AppColors.redDescent,
              ),
            ],
          ),
        );
      },
    );
  }
}
