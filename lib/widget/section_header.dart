import 'package:flutter/material.dart';

class SectionHeader extends StatelessWidget {
  final String judul;
  const SectionHeader({super.key, required this.judul});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Text(
        judul,
        style: TextStyle(
          fontFamily: 'Plus Jakarta Sans',
          fontSize: 20,
          fontWeight: FontWeight.w900,
          color: const Color.fromARGB(255, 49, 46, 129),
        ),
      ),
    );
  }
}
