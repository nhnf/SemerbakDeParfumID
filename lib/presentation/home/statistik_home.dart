import 'package:flutter/material.dart';

import '../../widget/card_statistik.dart';

class StatistikHome extends StatelessWidget {
  const StatistikHome({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 160,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          CardStatistik(
            icon: 'assets/icons/spray.png',
            amount: '1.239',
            label: 'TOTAL PARFUM TERJUAL',
          ),
          CardStatistik(
            amount: '127',
            icon: 'assets/icons/bottle.png',
            label: 'SISA BOTOL KOSONG',
          ),
        ],
      ),
    );
  }
}
