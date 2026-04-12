import 'package:flutter/material.dart';

class SectionHeader extends StatelessWidget {
  final String judul;
  final VoidCallback? onSeeAll;
  const SectionHeader({super.key, required this.judul, this.onSeeAll});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            judul,
            style: const TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: Color.fromARGB(225, 0, 6, 102),
            ),
          ),
          if (onSeeAll != null)
            TextButton(
              onPressed: onSeeAll,
              child: const Text(
                "Lihat Semua",
                style: TextStyle(
                  color: Color.fromARGB(225, 0, 6, 102),
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Manrope',
                ),
              ),
            ),
        ],
      ),
    );
  }
}
