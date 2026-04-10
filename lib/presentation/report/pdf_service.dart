import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';

class PdfService {
  // Fungsi utama untuk generate PDF, baik mingguan maupun bulanan
  static Future<Uint8List> generateReportPdf({
    required String reportType,
    required List<Map<String, dynamic>> transactions,
  }) async {
    final pdf = pw.Document();
    
    // Perhitungan Ringkasan
    int totalPemasukan = 0;
    int totalPengeluaran = 0;
    for (var tx in transactions) {
      if (tx['isPemasukan'] == true) {
        totalPemasukan += tx['amount'] as int;
      } else {
        totalPengeluaran += tx['amount'] as int;
      }
    }
    final int labaBersih = totalPemasukan - totalPengeluaran;

    final formatter = NumberFormat.decimalPattern('id');

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            // HEADER LAPORAN
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'SEMERBAK DE PARFUME ID',
                      style: pw.TextStyle(
                        fontSize: 24,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColor.fromHex('#1E2857'),
                      ),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      'Laporan Arus Kas $reportType',
                      style: pw.TextStyle(
                        fontSize: 14,
                        color: PdfColor.fromHex('#94A3B8'),
                      ),
                    ),
                  ],
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text(
                      'Dicetak pada:',
                      style: pw.TextStyle(fontSize: 10, color: PdfColors.grey),
                    ),
                    pw.Text(
                      DateFormat('dd MMM yyyy, HH:mm').format(DateTime.now()),
                      style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
            pw.SizedBox(height: 32),

            // RINGKASAN KEUANGAN (KOTAK)
            pw.Container(
              padding: const pw.EdgeInsets.all(16),
              decoration: pw.BoxDecoration(
                color: PdfColor.fromHex('#F8FAFC'),
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(12)),
                border: pw.Border.all(color: PdfColor.fromHex('#E2E8F0')),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                children: [
                  _buildSummaryItem('Total Pemasukan', totalPemasukan, PdfColors.green700, formatter),
                  _buildSummaryItem('Total Pengeluaran', totalPengeluaran, PdfColors.red700, formatter),
                  _buildSummaryItem('Laba Bersih', labaBersih, PdfColor.fromHex('#1E2857'), formatter),
                ],
              ),
            ),
            pw.SizedBox(height: 32),

            // JUDUL TABEL
            pw.Text(
              'RINCIAN TRANSAKSI',
              style: pw.TextStyle(
                fontSize: 12,
                fontWeight: pw.FontWeight.bold,
                letterSpacing: 1.5,
                color: PdfColor.fromHex('#1E2857'),
              ),
            ),
            pw.SizedBox(height: 12),

            // TABEL DAFTAR TRANSAKSI
            pw.TableHelper.fromTextArray(
              border: pw.TableBorder.all(color: PdfColor.fromHex('#E2E8F0')),
              headerDecoration: pw.BoxDecoration(
                color: PdfColor.fromHex('#1E2857'),
              ),
              headerHeight: 30,
              cellHeight: 28,
              cellAlignments: {
                0: pw.Alignment.centerLeft,
                1: pw.Alignment.centerLeft,
                2: pw.Alignment.center,
                3: pw.Alignment.centerRight,
              },
              headerStyle: pw.TextStyle(
                color: PdfColors.white,
                fontWeight: pw.FontWeight.bold,
                fontSize: 10,
              ),
              cellStyle: const pw.TextStyle(fontSize: 10),
              headers: ['Tanggal', 'Deskripsi', 'Tipe', 'Nominal (Rp)'],
              data: transactions.map((tx) {
                final isMasuk = tx['isPemasukan'] as bool;
                return [
                  tx['date'],
                  tx['desc'],
                  isMasuk ? 'Pemasukan' : 'Pengeluaran',
                  formatter.format(tx['amount']),
                ];
              }).toList(),
            ),
            pw.SizedBox(height: 32),

            // FOOTER SIGNATURE
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.end,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    pw.Text('Disetujui Oleh,'),
                    pw.SizedBox(height: 60),
                    pw.Text('Manajer Semerbak De Parfume',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  ],
                ),
              ],
            ),
          ];
        },
      ),
    );

    return pdf.save();
  }

  // Helper widget untuk summary di PDF
  static pw.Widget _buildSummaryItem(String label, int amount, PdfColor color, NumberFormat formatter) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        pw.Text(
          label,
          style: pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          'Rp ${formatter.format(amount)}',
          style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: color),
        ),
      ],
    );
  }
}
