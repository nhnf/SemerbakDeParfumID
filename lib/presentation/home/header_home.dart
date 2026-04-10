import 'package:flutter/material.dart';

import '../../widget/card_cash_flow.dart';

class HeaderHome extends StatelessWidget {
  const HeaderHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'LABA/RUGI BULAN INI',
            style: TextStyle(
              fontFamily: 'Manrope',
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 2.4,
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Rp',
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 24,
                  fontWeight: FontWeight.normal,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '132.833.000',
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 40,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: -1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          CardCashFlow(
            label: 'PEMASUKAN',
            amount: 'Rp 145.833.000',
            icon: Icons.arrow_upward,
            iconColor: Colors.green,
          ),

          const SizedBox(height: 16),
          CardCashFlow(
            label: 'PENGELUARAN',
            amount: 'Rp 13.000.000',
            icon: Icons.arrow_downward,
            iconColor: Colors.red,
          ),
        ],
      ),
    );
  }
}
