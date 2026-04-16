import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';
import '../../domain/entities/transaction_entity.dart';
import '../transaction/bloc/transaction_bloc.dart';
import '../transaction/bloc/transaction_state.dart';
import '../transaction/bloc/transaction_event.dart';
import 'pdf_service.dart';

enum ReportFilter { mingguIni, bulanIni, pilihTanggal }

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
    _startDate = DateTime(
      now.year,
      now.month,
      now.day,
    ).subtract(Duration(days: difference));
    _endDate = _startDate.add(
      const Duration(days: 6, hours: 23, minutes: 59, seconds: 59),
    );
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
            colorScheme: const ColorScheme.light(
              primary: Color.fromARGB(225, 0, 6, 102),
            ),
            buttonTheme: const ButtonThemeData(
              textTheme: ButtonTextTheme.primary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedFilter = ReportFilter.pilihTanggal;
        _startDate = DateTime(
          picked.start.year,
          picked.start.month,
          picked.start.day,
        );
        _endDate = DateTime(
          picked.end.year,
          picked.end.month,
          picked.end.day,
          23,
          59,
          59,
        );
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

  void _printOrDownloadPdf(
    String type,
    List<Map<String, dynamic>> structuredData,
  ) async {
    final pdfBytes = await PdfService.generateReportPdf(
      reportType: type,
      transactions: structuredData,
    );

    // Menampilkan Preview PDF yang kaya fitur (Print, Share, Save)
    await Printing.layoutPdf(
      onLayout: (format) async => pdfBytes,
      name: 'Laporan_Semerbak_$type',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Dasbor Laporan',
          style: TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Color(0xFF1E2857),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
      ),
      body: BlocBuilder<TransactionBloc, TransactionState>(
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
              return t.tanggal.isAfter(
                    _startDate.subtract(const Duration(seconds: 1)),
                  ) &&
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
                int bIdx = isBulanIni ? (dayIndex ~/ 7) : dayIndex;

                if (tx.isPemasukan) {
                  pemasukanHarian[bIdx] += tx.total.toDouble();
                } else {
                  pengeluaranHarian[bIdx] += tx.total.toDouble();
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
          }

          final formatter = NumberFormat.decimalPattern('id');
          final labaBersih = totalPemasukan - totalPengeluaran;

          return RefreshIndicator(
            onRefresh: () async {
              context.read<TransactionBloc>().add(LoadTransactionsEvent());
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
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
                          'TOTAL TRANSAKSI',
                          style: TextStyle(
                            fontFamily: 'Manrope',
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 2.4,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Rp ${formatter.format(labaBersih)}',
                          style: const TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 40,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: -1.2,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildMiniStat(
                              'Pemasukan',
                              'Rp ${formatter.format(totalPemasukan)}',
                              Icons.arrow_upward,
                              Colors.greenAccent,
                            ),
                            Container(
                              width: 1,
                              height: 40,
                              color: Colors.white24,
                            ),
                            _buildMiniStat(
                              'Pengeluaran',
                              'Rp ${formatter.format(totalPengeluaran)}',
                              Icons.arrow_downward,
                              Colors.redAccent,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // 2. GRAFIK (BAR CHART)
                  Text(
                    'Grafik Arus Kas (${_getFilterLabelTitleCase()})',
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: Color.fromARGB(225, 0, 6, 102),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
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
                        for (var v in pemasukanHarian)
                          if (v > maxVal) maxVal = v;
                        for (var v in pengeluaranHarian)
                          if (v > maxVal) maxVal = v;
                        if (maxVal > 0) {
                          maxY = maxVal + (maxVal * 0.2); // +20% margin
                        }

                        return SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.only(
                            top: 32,
                            right: 16,
                            bottom: 16,
                            left: 16,
                          ),
                          child: SizedBox(
                            width:
                                (barsCount * 45.0) <
                                    MediaQuery.of(context).size.width - 80
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
                                            final startDateOfWeek = _startDate
                                                .add(Duration(days: index * 7));
                                            int daysToAdd = 6;
                                            if (index == barsCount - 1) {
                                              daysToAdd =
                                                  daysCount - (index * 7) - 1;
                                            }
                                            final endDateOfWeek =
                                                startDateOfWeek.add(
                                                  Duration(days: daysToAdd),
                                                );

                                            return Padding(
                                              padding: const EdgeInsets.only(
                                                top: 8.0,
                                              ),
                                              child: Text(
                                                'M${index + 1}\n${startDateOfWeek.day}/${startDateOfWeek.month}-${endDateOfWeek.day}/${endDateOfWeek.month}',
                                                textAlign: TextAlign.center,
                                                style: const TextStyle(
                                                  color: Color(0xFF94A3B8),
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 8,
                                                  fontFamily:
                                                      'Plus Jakarta Sans',
                                                ),
                                              ),
                                            );
                                          }

                                          final date = _startDate.add(
                                            Duration(days: index),
                                          );
                                          return Padding(
                                            padding: const EdgeInsets.only(
                                              top: 8.0,
                                            ),
                                            child: Text(
                                              '${date.day}/${date.month}',
                                              style: const TextStyle(
                                                color: Color(0xFF94A3B8),
                                                fontWeight: FontWeight.bold,
                                                fontSize: 10,
                                                fontFamily: 'Plus Jakarta Sans',
                                              ),
                                            ),
                                          );
                                        }
                                        return const SizedBox.shrink();
                                      },
                                      reservedSize: 42,
                                    ),
                                  ),
                                  leftTitles: const AxisTitles(
                                    sideTitles: SideTitles(showTitles: false),
                                  ),
                                  topTitles: const AxisTitles(
                                    sideTitles: SideTitles(showTitles: false),
                                  ),
                                  rightTitles: const AxisTitles(
                                    sideTitles: SideTitles(showTitles: false),
                                  ),
                                ),
                                gridData: FlGridData(
                                  show: true,
                                  drawVerticalLine: false,
                                  horizontalInterval: (maxY / 4) > 0
                                      ? (maxY / 4)
                                      : 1000000,
                                  getDrawingHorizontalLine: (value) => FlLine(
                                    color: Colors.grey.shade200,
                                    strokeWidth: 1,
                                    dashArray: [5, 5],
                                  ),
                                ),
                                borderData: FlBorderData(show: false),
                                barGroups: List.generate(barsCount, (index) {
                                  return _buildBarGroup(
                                    index,
                                    pemasukanHarian[index],
                                    pengeluaranHarian[index],
                                  );
                                }),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildLegendItem(
                        'Pemasukan',
                        const Color.fromARGB(225, 0, 6, 102),
                      ),
                      const SizedBox(width: 16),
                      _buildLegendItem('Pengeluaran', const Color(0xFFFF7675)),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // 3. ACTION BUTTONS (DOWNLOAD PDF)
                  const Text(
                    'Ekspor Laporan',
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: Color.fromARGB(225, 0, 6, 102),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildExportCard(
                    title: 'Laporan Rekapitulasi Aktual',
                    subtitle: 'Semua transaksi Supabase',
                    icon: Icons.calendar_view_week,
                    onTap: () => _printOrDownloadPdf('Aktual', structuredData),
                  ),
                  const SizedBox(height: 80), // Spacer untuk navbar
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMiniStat(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 16),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 10,
                fontFamily: 'Manrope',
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.bold,
                fontFamily: 'Plus Jakarta Sans',
              ),
            ),
          ],
        ),
      ],
    );
  }

  BarChartGroupData _buildBarGroup(
    int x,
    double pemasukan,
    double pengeluaran,
  ) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: pemasukan, // Harus 'toY' bukan 'y' di versi 1.2.0
          color: const Color.fromARGB(225, 0, 6, 102),
          width: 8,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
        ),
        BarChartRodData(
          toY: pengeluaran,
          color: const Color(0xFFFF7675), // Merah pengeluaran
          width: 8,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
        ),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            color: Color(0xFF454652),
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildFilterRow() {
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

  Widget _buildChoiceChip(
    String label,
    ReportFilter filter,
    VoidCallback onTap,
  ) {
    final isSelected = _selectedFilter == filter;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color.fromARGB(225, 0, 6, 102)
              : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.transparent : const Color(0xFFE2E8F0),
          ),
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

  Widget _buildExportCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: const Color(0xFF1E2857)),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Color(0xFF1E2857),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF94A3B8),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF1E2857),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'PDF',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
