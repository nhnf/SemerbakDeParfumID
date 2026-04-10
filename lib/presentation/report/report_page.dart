import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';
import 'pdf_service.dart';

class ReportPage extends StatefulWidget {
  const ReportPage({super.key});

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  // Data dummy transaksi untuk grafik & laporan PDF (akan diganti Data Asli ke depan)
  final List<Map<String, dynamic>> _dummyTransactions = [
    {'date': '01 Apr', 'desc': 'Penjualan Baccarat', 'amount': 1500000, 'isPemasukan': true},
    {'date': '02 Apr', 'desc': 'Penjualan Luxury Oud', 'amount': 900000, 'isPemasukan': true},
    {'date': '03 Apr', 'desc': 'Beli Botol Kaca', 'amount': 420000, 'isPemasukan': false},
    {'date': '04 Apr', 'desc': 'Penjualan Midnight Bloom', 'amount': 1350000, 'isPemasukan': true},
    {'date': '05 Apr', 'desc': 'Sewa Stan', 'amount': 1000000, 'isPemasukan': false},
    {'date': '06 Apr', 'desc': 'Penjualan Sweet Vanilla', 'amount': 2400000, 'isPemasukan': true},
    {'date': '07 Apr', 'desc': 'Biaya Iklan', 'amount': 500000, 'isPemasukan': false},
  ];

  int _totalPemasukan = 0;
  int _totalPengeluaran = 0;

  @override
  void initState() {
    super.initState();
    _calculateTotals();
  }

  void _calculateTotals() {
    for (var tx in _dummyTransactions) {
      if (tx['isPemasukan'] == true) {
        _totalPemasukan += tx['amount'] as int;
      } else {
        _totalPengeluaran += tx['amount'] as int;
      }
    }
  }

  void _printOrDownloadPdf(String type) async {
    final pdfBytes = await PdfService.generateReportPdf(
      reportType: type,
      transactions: _dummyTransactions,
    );
    
    // Menampilkan Preview PDF yang kaya fitur (Print, Share, Save)
    await Printing.layoutPdf(
      onLayout: (format) async => pdfBytes,
      name: 'Laporan_Semerbak_$type',
    );
  }

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.decimalPattern('id');
    final labaBersih = _totalPemasukan - _totalPengeluaran;

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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. KARTU RINGKASAN UTAMA
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF1E2857), Color(0xFF131526)],
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF1E2857).withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Text(
                    'LABA BERSIH (7 HARI TERAKHIR)',
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFDCA73A),
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Rp ${formatter.format(labaBersih)}',
                    style: const TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildMiniStat(
                        'Pemasukan',
                        'Rp ${formatter.format(_totalPemasukan)}',
                        Icons.arrow_upward,
                        Colors.greenAccent,
                      ),
                      Container(width: 1, height: 40, color: Colors.white24),
                      _buildMiniStat(
                        'Pengeluaran',
                        'Rp ${formatter.format(_totalPengeluaran)}',
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
            const Text(
              'GRAFIK ARUS KAS',
              style: TextStyle(
                fontFamily: 'Manrope',
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Color(0xFF94A3B8),
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              height: 250,
              padding: const EdgeInsets.only(top: 32, right: 16, bottom: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
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
                    _buildBarGroup(0, 1500000, 420000),
                    _buildBarGroup(1, 900000, 0),
                    _buildBarGroup(2, 0, 1000000),
                    _buildBarGroup(3, 1350000, 0),
                    _buildBarGroup(4, 2400000, 500000),
                    _buildBarGroup(5, 500000, 100000), // dummy
                    _buildBarGroup(6, 1200000, 200000), // dummy
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLegendItem('Pemasukan', const Color(0xFFDCA73A)),
                const SizedBox(width: 16),
                _buildLegendItem('Pengeluaran', const Color(0xFFFF7675)),
              ],
            ),
            const SizedBox(height: 32),

            // 3. ACTION BUTTONS (DOWNLOAD PDF)
            const Text(
              'EKSPOR LAPORAN',
              style: TextStyle(
                fontFamily: 'Manrope',
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Color(0xFF94A3B8),
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 16),
            _buildExportCard(
              title: 'Laporan Mingguan',
              subtitle: 'Rekapitulasi 7 hari terakhir',
              icon: Icons.calendar_view_week,
              onTap: () => _printOrDownloadPdf('Mingguan'),
            ),
            const SizedBox(height: 12),
            _buildExportCard(
              title: 'Laporan Bulanan',
              subtitle: 'Rekapitulasi sebulan penuh',
              icon: Icons.calendar_month,
              onTap: () => _printOrDownloadPdf('Bulanan'),
            ),
            const SizedBox(height: 80), // Spacer untuk navbar
          ],
        ),
      ),
    );
  }

  Widget _buildMiniStat(String label, String value, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: color.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, color: color, size: 16),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: Colors.white70, fontSize: 10, fontFamily: 'Manrope')),
            Text(value, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold, fontFamily: 'Plus Jakarta Sans')),
          ],
        ),
      ],
    );
  }

  BarChartGroupData _buildBarGroup(int x, double pemasukan, double pengeluaran) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: pemasukan, // Harus 'toY' bukan 'y' di versi 1.2.0. Ini juga warna gold.
          color: const Color(0xFFDCA73A),
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
        Container(width: 12, height: 12, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4))),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 10, color: Color(0xFF454652), fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildExportCard({required String title, required String subtitle, required IconData icon, required VoidCallback onTap}) {
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
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF1E2857))),
                  const SizedBox(height: 2),
                  Text(subtitle, style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF1E2857),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text('PDF', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11)),
            ),
          ],
        ),
      ),
    );
  }
}
