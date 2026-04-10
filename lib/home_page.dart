import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:semerbak_de_parfume_id/presentation/home/statistik_home.dart';
import 'package:semerbak_de_parfume_id/widget/section_header.dart';
import 'presentation/home/header_home.dart';
import 'presentation/bloc/transaction/transaction_bloc.dart';
import 'presentation/bloc/transaction/transaction_state.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 245, 247, 249),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(top: 150),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 16, right: 16),
                child: Container(
                  width: width,
                  height: 366.5,
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 0, 6, 102),
                    borderRadius: BorderRadius.circular(32),
                  ),
                  child: HeaderHome(),
                ),
              ),
              SectionHeader(judul: "Statistik Cepat"),
              StatistikHome(),
              SectionHeader(judul: "Transaksi Terakhir"),
              Padding(
                padding: const EdgeInsets.only(left: 24, right: 24),
                child: Container(
                  width: double.infinity,
                  // Menghapus height statis (misal height: 160) agar ukuran dinamis mengikuti jumlah item
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(32),
                  ),
                  // BlocBuilder akan membangun ulang (rebuild) UI ini kapanpun state Transaksi berubah
                  child: BlocBuilder<TransactionBloc, TransactionState>(
                    builder: (context, state) {
                      // 1. Jika masih tahap inisialisasi atau sedang mengambil data, tampilkan loading.
                      if (state is TransactionInitial ||
                          state is TransactionLoading) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(32.0),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      } 
                      // 2. Jika terjadi error saat memanggil API / database
                      else if (state is TransactionError) {
                        return Center(
                          child: Padding(
                            padding: EdgeInsets.all(32.0),
                            child: Text(state.message),
                          ),
                        );
                      } 
                      // 3. Jika data berhasil dimuat (Loaded)
                      else if (state is TransactionLoaded) {
                        final listTransaction = state.transactions;
                        if (listTransaction.isEmpty) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(32.0),
                              child: Text("Belum ada transaksi"),
                            ),
                          );
                        }
                        
                        // Menampilkan daftar transaksi menggunakan ListView.
                        return ListView.builder(
                          // shrinkWrap: true membuat list ini sebesar isi yang ada di dalamnya, tidak lebih.
                          shrinkWrap: true,
                          // Menonaktifkan scroll di dalam list karena kita ingin halaman utamanya yang bisa discroll.
                          physics: const NeverScrollableScrollPhysics(),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          // Batasi hanya menampilkan maksimal 5 item menggunakan sintaks math.min
                          itemCount: math.min(listTransaction.length, 5),
                          itemBuilder: (context, index) {
                            final item = listTransaction[index];
                            final Color color = item.isPemasukan
                                ? Colors.green
                                : Colors.red;
                            final IconData icon = item.isPemasukan
                                ? Icons.arrow_upward
                                : Icons.arrow_downward;
                            final String simbol = item.isPemasukan ? "+" : "-";

                            return ListTile(
                              leading: CircleAvatar(
                                backgroundColor: color.withValues(alpha: 0.1),
                                child: Icon(icon, color: color, size: 20),
                              ),
                              title: Text(
                                item.nama,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  fontFamily: 'Manrope',
                                ),
                              ),
                              subtitle: Text(
                                item.tanggal,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontFamily: 'Manrope',
                                ),
                              ),
                              trailing: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    "$simbol Rp ${NumberFormat.decimalPattern('id').format(item.total)}",
                                    style: TextStyle(
                                      color: color,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      fontFamily: 'Plus Jakarta Sans',
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: color.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      item.isPemasukan ? "BERHASIL" : "KELUAR",
                                      style: TextStyle(
                                        color: color,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'Plus Jakarta Sans',
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ),
              ),
              SizedBox(height: 200),
            ],
          ),
        ),
      ),
    );
  }
}
