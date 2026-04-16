import re

with open("lib/presentation/report/report_page.dart", "r", encoding="utf-8") as f:
    content = f.read()

# 1. Imports and Class start
p1_target = """class ReportPage extends StatefulWidget {
  const ReportPage({super.key});

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  void _printOrDownloadPdf(String type, List<Map<String, dynamic>> structuredData) async {"""

p1_replace = """enum ReportFilter { mingguIni, bulanIni, pilihTanggal }

class ReportPage extends StatefulWidget {
  const ReportPage({super.key});

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  ReportFilter _selectedFilter = ReportFilter.mingguIni;
  late DateTime _startDate;
  late DateTime _endDate;

  @override
  void initState() {
    super.initState();
    _setMingguIni();
  }

  void _setMingguIni() {
    final now = DateTime.now();
    final difference = now.weekday - DateTime.monday;
    _startDate = DateTime(now.year, now.month, now.day).subtract(Duration(days: difference));
    _endDate = _startDate.add(const Duration(days: 6, hours: 23, minutes: 59, seconds: 59));
  }

  void _setBulanIni() {
    final now = DateTime.now();
    _startDate = DateTime(now.year, now.month, 1);
    final nextMonth = DateTime(now.year, now.month + 1, 1);
    _endDate = nextMonth.subtract(const Duration(seconds: 1));
  }

  Future<void> _selectCustomDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      initialDateRange: DateTimeRange(start: _startDate, end: _endDate),
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: const Color.fromARGB(225, 0, 6, 102),
            colorScheme: const ColorScheme.light(primary: Color.fromARGB(225, 0, 6, 102)),
            buttonTheme: const ButtonThemeData(textTheme: ButtonTextTheme.primary),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedFilter = ReportFilter.pilihTanggal;
        _startDate = DateTime(picked.start.year, picked.start.month, picked.start.day);
        _endDate = DateTime(picked.end.year, picked.end.month, picked.end.day, 23, 59, 59);
      });
    }
  }

  String _getFilterLabel() {
    switch (_selectedFilter) {
      case ReportFilter.mingguIni:
        return 'MINGGU INI';
      case ReportFilter.bulanIni:
        return 'BULAN INI';
      case ReportFilter.pilihTanggal:
        return 'CUSTOM TANGGAL';
    }
  }

  String _getFilterLabelTitleCase() {
    switch (_selectedFilter) {
      case ReportFilter.mingguIni:
        return 'Minggu Ini';
      case ReportFilter.bulanIni:
        return 'Bulan Ini';
      case ReportFilter.pilihTanggal:
        return 'Custom Tanggal';
    }
  }

  void _printOrDownloadPdf(String type, List<Map<String, dynamic>> structuredData) async {"""
content = content.replace(p1_target, p1_replace)

# 2. Logic parsing
p2_target = """      body: BlocBuilder<TransactionBloc, TransactionState>(
        builder: (context, state) {
          int totalPemasukan = 0;
          int totalPengeluaran = 0;
          List<Map<String, dynamic>> structuredData = [];

          // Struktur data bar chart hari (Senin = 0, Selasa = 1 ... Minggu = 6)
          List<double> pemasukanHarian = List.filled(7, 0.0);
          List<double> pengeluaranHarian = List.filled(7, 0.0);

          if (state is TransactionLoaded) {
            // Kita fokus pada bulan ini untuk grafik
            final now = DateTime.now();
            final trBulanIni = state.transactions.where((t) => t.tanggal.year == now.year && t.tanggal.month == now.month).toList();
            
            for (var tx in trBulanIni) {
              if (tx.isPemasukan) {
                totalPemasukan += tx.total;
                // mapping hari: weekday 1 = senin, maka index = weekday - 1
                pemasukanHarian[tx.tanggal.weekday - 1] += tx.total.toDouble();
              } else {
                totalPengeluaran += tx.total;
                pengeluaranHarian[tx.tanggal.weekday - 1] += tx.total.toDouble();
              }
            }

            // Membentuk struktur untuk PDF
            structuredData = state.transactions.map((tx) {
              return {
                'date': DateFormat('dd MMM yyyy').format(tx.tanggal),
                'desc': tx.nama,
                'amount': tx.total,
                'isPemasukan': tx.isPemasukan,
              };
            }).toList();
          }"""
p2_replace = """      body: BlocBuilder<TransactionBloc, TransactionState>(
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
            }

            // Membentuk struktur untuk PDF
            structuredData = filteredTransactions.map((tx) {
              return {
                'date': DateFormat('dd MMM yyyy').format(tx.tanggal),
                'desc': tx.nama,
                'amount': tx.total,
                'isPemasukan': tx.isPemasukan,
              };
            }).toList();
          }"""
content = content.replace(p2_target, p2_replace)

# 3. Label and UI Filter Row
p3_target = """              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. KARTU RINGKASAN UTAMA
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(225, 0, 6, 102),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF1E2857).withValues(alpha: 0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'LABA BERSIH (BULAN INI)',"""
p3_replace = """              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildFilterRow(),
                const SizedBox(height: 16),
                Text(
                  'Periode: ${DateFormat('dd MMM yyyy').format(_startDate)} - ${DateFormat('dd MMM yyyy').format(_endDate)}',
                  style: const TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 13,
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 24),

                // 1. KARTU RINGKASAN UTAMA
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(225, 0, 6, 102),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF1E2857).withValues(alpha: 0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        'LABA BERSIH (${_getFilterLabel()})',"""
content = content.replace(p3_target, p3_replace)

# 4. Text Title Grafik
p4_target = """                // 2. GRAFIK (BAR CHART)
                const Text(
                  'Grafik Arus Kas (Bulan Ini)',"""
p4_replace = """                // 2. GRAFIK (BAR CHART)
                Text(
                  'Grafik Arus Kas (${_getFilterLabelTitleCase()})',"""
content = content.replace(p4_target, p4_replace)

# 5. Chart Data
p5_target = """                Container(
                  height: 250,
                  padding: const EdgeInsets.only(top: 32, right: 16, bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  // Render FlChart
                  child: BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: 3000000,
                      barTouchData: BarTouchData(enabled: false),
                      titlesData: FlTitlesData(
                        show: true,
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (double value, _) {
                              const style = TextStyle(color: Color(0xFF94A3B8), fontWeight: FontWeight.bold, fontSize: 10);
                              switch (value.toInt()) {
                                case 0: return const Text('Sen', style: style);
                                case 1: return const Text('Sel', style: style);
                                case 2: return const Text('Rab', style: style);
                                case 3: return const Text('Kam', style: style);
                                case 4: return const Text('Jum', style: style);
                                case 5: return const Text('Sab', style: style);
                                case 6: return const Text('Min', style: style);
                                default: return const Text('', style: style);
                              }
                            },
                          ),
                        ),
                        leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      ),
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        horizontalInterval: 1000000,
                        getDrawingHorizontalLine: (value) => FlLine(color: Colors.grey.shade200, strokeWidth: 1, dashArray: [5, 5]),
                      ),
                      borderData: FlBorderData(show: false),
                      barGroups: [
                        _buildBarGroup(0, pemasukanHarian[0], pengeluaranHarian[0]),
                        _buildBarGroup(1, pemasukanHarian[1], pengeluaranHarian[1]),
                        _buildBarGroup(2, pemasukanHarian[2], pengeluaranHarian[2]),
                        _buildBarGroup(3, pemasukanHarian[3], pengeluaranHarian[3]),
                        _buildBarGroup(4, pemasukanHarian[4], pengeluaranHarian[4]),
                        _buildBarGroup(5, pemasukanHarian[5], pengeluaranHarian[5]),
                        _buildBarGroup(6, pemasukanHarian[6], pengeluaranHarian[6]),
                      ],
                    ),
                  ),
                ),"""
p5_replace = """                Container(
                  height: 250,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Builder(
                    builder: (context) {
                      double maxY = 3000000;
                      double maxVal = 0;
                      for (var v in pemasukanHarian) if (v > maxVal) maxVal = v;
                      for (var v in pengeluaranHarian) if (v > maxVal) maxVal = v;
                      if (maxVal > 0) {
                        maxY = maxVal + (maxVal * 0.2); // +20% margin
                      }
                      
                      return SingleChildScrollView(
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
                      );
                    }
                  ),
                ),"""
content = content.replace(p5_target, p5_replace)

# 6. Add choice chip method at the end
p6_target = """  Widget _buildExportCard({required String title, required String subtitle, required IconData icon, required VoidCallback onTap}) {"""
p6_replace = """  Widget _buildFilterRow() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildChoiceChip('Minggu Ini', ReportFilter.mingguIni, () {
            setState(() {
              _selectedFilter = ReportFilter.mingguIni;
              _setMingguIni();
            });
          }),
          const SizedBox(width: 8),
          _buildChoiceChip('Bulan Ini', ReportFilter.bulanIni, () {
            setState(() {
              _selectedFilter = ReportFilter.bulanIni;
              _setBulanIni();
            });
          }),
          const SizedBox(width: 8),
          _buildChoiceChip('Pilih Tanggal', ReportFilter.pilihTanggal, () {
            _selectCustomDateRange();
          }),
        ],
      ),
    );
  }

  Widget _buildChoiceChip(String label, ReportFilter filter, VoidCallback onTap) {
    final isSelected = _selectedFilter == filter;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color.fromARGB(225, 0, 6, 102) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? Colors.transparent : const Color(0xFFE2E8F0)),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : const Color(0xFF64748B),
            fontWeight: FontWeight.bold,
            fontSize: 12,
            fontFamily: 'Plus Jakarta Sans',
          ),
        ),
      ),
    );
  }

  Widget _buildExportCard({required String title, required String subtitle, required IconData icon, required VoidCallback onTap}) {"""
content = content.replace(p6_target, p6_replace)

with open("lib/presentation/report/report_page.dart", "w", encoding="utf-8") as f:
    f.write(content)

print("Replacement successful")
