import 'package:flutter/material.dart';

class CardStatistik extends StatelessWidget {
  final String icon;
  final String amount;
  final String label;
  final VoidCallback? onTap;
  const CardStatistik({
    super.key,
    required this.amount,
    required this.icon,
    required this.label,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 24, right: 24),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 200,
          height: 160,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(32),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 24, top: 24),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Color.fromARGB(225, 238, 242, 255),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Image.asset(icon),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 24, bottom: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      amount,
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 30,
                        color: Color.fromARGB(225, 0, 6, 102),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      label,
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(225, 100, 116, 139),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
