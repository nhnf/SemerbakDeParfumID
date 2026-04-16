import re

with open("lib/presentation/report/report_page.dart", "r", encoding="utf-8") as f:
    content = f.read()

# Logic parsing update for grouping by weeks
p1_target = """      body: BlocBuilder<TransactionBloc, TransactionState>(
        builder: (context, state) {
          int totalPemasukan = 0;
          int totalPengeluaran = 0;
          List<Map<String, dynamic>> structuredData = [];

          final int daysCount = _endDate.difference(_startDate).inDays + 1;
          List<double> pemasukanHarian = List.filled(daysCount, 0.0);
          List<double> pengeluaranHarian = List.filled(daysCount, 0.0);

          if (state is TransactionLoaded) {
            final filteredTransactions = state.transactions.where((t) {
              return t.tanggal.isAfter(_startDate.subtract(const Duration(seconds: 1))) &&
                     t.tanggal.isBefore(_endDate.add(const Duration(seconds: 1)));
            }).toList();
            
            for (var tx in filteredTransactions) {
              if (tx.isPemasukan) {
                totalPemasukan += tx.total;
              } else {
                totalPengeluaran += tx.total;
              }
              
              final int dayIndex = tx.tanggal.difference(_startDate).inDays;
              if (dayIndex >= 0 && dayIndex < daysCount) {
                if (tx.isPemasukan) {
                  pemasukanHarian[dayIndex] += tx.total.toDouble();
                } else {
                  pengeluaranHarian[dayIndex] += tx.total.toDouble();
                }
              }
            }"""
p1_replace = """      body: BlocBuilder<TransactionBloc, TransactionState>(
        builder: (context, state) {
          int totalPemasukan = 0;
          int totalPengeluaran = 0;
          List<Map<String, dynamic>> structuredData = [];

          final bool isBulanIni = _selectedFilter == ReportFilter.bulanIni;
          final int daysCount = _endDate.difference(_startDate).inDays + 1;
          
          int barsCount = daysCount;
          if (isBulanIni) {
             barsCount = (daysCount / 7).ceil();
          }

          List<double> pemasukanHarian = List.filled(barsCount, 0.0);
          List<double> pengeluaranHarian = List.filled(barsCount, 0.0);

          if (state is TransactionLoaded) {
            final filteredTransactions = state.transactions.where((t) {
              return t.tanggal.isAfter(_startDate.subtract(const Duration(seconds: 1))) &&
                     t.tanggal.isBefore(_endDate.add(const Duration(seconds: 1)));
            }).toList();
            
            for (var tx in filteredTransactions) {
              if (tx.isPemasukan) {
                totalPemasukan += tx.total;
              } else {
                totalPengeluaran += tx.total;
              }
              
              final int dayIndex = tx.tanggal.difference(_startDate).inDays;
              if (dayIndex >= 0 && dayIndex < daysCount) {
                int barIndex = dayIndex;
                if (isBulanIni) {
                  barIndex = dayIndex // 7; // // Wait, dart uses ~/ for integer division. Let me use ~/ 
                }
                
                // Using ~/ directly in the string since this is Python string for Dart code
                int bIdx = isBulanIni ? (dayIndex ~/ 7) : dayIndex;

                if (tx.isPemasukan) {
                  pemasukanHarian[bIdx] += tx.total.toDouble();
                } else {
                  pengeluaranHarian[bIdx] += tx.total.toDouble();
                }
              }
            }"""
content = content.replace(p1_target, p1_replace)

# Chart rendering update for grouping by weeks
p2_target = """                      return SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.only(top: 32, right: 16, bottom: 16, left: 16),
                        child: SizedBox(
                          width: (daysCount * 45.0) < MediaQuery.of(context).size.width - 80 
                              ? MediaQuery.of(context).size.width - 80 
                              : daysCount * 45.0,
                          child: BarChart(
                            BarChartData(
                              alignment: BarChartAlignment.spaceAround,
                              maxY: maxY,
                              barTouchData: BarTouchData(enabled: false),
                              titlesData: FlTitlesData(
                                show: true,
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    getTitlesWidget: (double value, _) {
                                      final int index = value.toInt();
                                      if (index >= 0 && index < daysCount) {
                                        final date = _startDate.add(Duration(days: index));
                                        return Padding(
                                          padding: const EdgeInsets.only(top: 8.0),
                                          child: Text(
                                            '${date.day}/${date.month}',
                                            style: const TextStyle(color: Color(0xFF94A3B8), fontWeight: FontWeight.bold, fontSize: 10),
                                          ),
                                        );
                                      }
                                      return const SizedBox.shrink();
                                    },
                                    reservedSize: 28,
                                  ),
                                ),
                                leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              ),
                              gridData: FlGridData(
                                show: true,
                                drawVerticalLine: false,
                                horizontalInterval: (maxY / 4) > 0 ? (maxY / 4) : 1000000,
                                getDrawingHorizontalLine: (value) => FlLine(color: Colors.grey.shade200, strokeWidth: 1, dashArray: [5, 5]),
                              ),
                              borderData: FlBorderData(show: false),
                              barGroups: List.generate(daysCount, (index) {
                                return _buildBarGroup(index, pemasukanHarian[index], pengeluaranHarian[index]);
                              }),
                            ),
                          ),
                        ),
                      );"""
p2_replace = """                      return SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.only(top: 32, right: 16, bottom: 16, left: 16),
                        child: SizedBox(
                          width: (barsCount * 45.0) < MediaQuery.of(context).size.width - 80 
                              ? MediaQuery.of(context).size.width - 80 
                              : barsCount * 45.0,
                          child: BarChart(
                            BarChartData(
                              alignment: BarChartAlignment.spaceAround,
                              maxY: maxY,
                              barTouchData: BarTouchData(enabled: false),
                              titlesData: FlTitlesData(
                                show: true,
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    getTitlesWidget: (double value, _) {
                                      final int index = value.toInt();
                                      if (index >= 0 && index < barsCount) {
                                        if (isBulanIni) {
                                          return Padding(
                                            padding: const EdgeInsets.only(top: 8.0),
                                            child: Text(
                                              'M${index + 1}',
                                              style: const TextStyle(color: Color(0xFF94A3B8), fontWeight: FontWeight.bold, fontSize: 10, fontFamily: 'Plus Jakarta Sans'),
                                            ),
                                          );
                                        }
                                        
                                        final date = _startDate.add(Duration(days: index));
                                        return Padding(
                                          padding: const EdgeInsets.only(top: 8.0),
                                          child: Text(
                                            '${date.day}/${date.month}',
                                            style: const TextStyle(color: Color(0xFF94A3B8), fontWeight: FontWeight.bold, fontSize: 10, fontFamily: 'Plus Jakarta Sans'),
                                          ),
                                        );
                                      }
                                      return const SizedBox.shrink();
                                    },
                                    reservedSize: 28,
                                  ),
                                ),
                                leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              ),
                              gridData: FlGridData(
                                show: true,
                                drawVerticalLine: false,
                                horizontalInterval: (maxY / 4) > 0 ? (maxY / 4) : 1000000,
                                getDrawingHorizontalLine: (value) => FlLine(color: Colors.grey.shade200, strokeWidth: 1, dashArray: [5, 5]),
                              ),
                              borderData: FlBorderData(show: false),
                              barGroups: List.generate(barsCount, (index) {
                                return _buildBarGroup(index, pemasukanHarian[index], pengeluaranHarian[index]);
                              }),
                            ),
                          ),
                        ),
                      );"""
content = content.replace(p2_target, p2_replace)


with open("lib/presentation/report/report_page.dart", "w", encoding="utf-8") as f:
    f.write(content)

print("Replacement successful")
