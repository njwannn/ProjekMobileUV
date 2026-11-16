import 'dart:math';
import 'package:flutter/material.dart';
import '../models/uv_data.dart';
import '../utils/uv_risk_level.dart';

class UvStatsRow extends StatelessWidget {
  final List<UvData> history;
  final VoidCallback onExportTap;

  const UvStatsRow({
    super.key,
    required this.history,
    required this.onExportTap,
  });

  @override
  Widget build(BuildContext context) {
    double peakUv = 0.0;
    double avgUv = 0.0;

    if (history.isNotEmpty) {
      final uvValues = history.map((e) => e.uvIndex).toList();
      peakUv = uvValues.reduce(max);
      avgUv = uvValues.reduce((a, b) => a + b) / uvValues.length;
    }

    final peakRisk = UvRiskLevel.fromUvIndex(peakUv);

    return Row(
      children: [
        // Peak UV Card
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFE9EDF0)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  offset: const Offset(0, 2),
                  blurRadius: 8,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.wb_twilight_rounded,
                      size: 15,
                      color: peakRisk.primaryColor,
                    ),
                    const SizedBox(width: 5),
                    const Text(
                      'Puncak',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF707E94),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      history.isEmpty ? '-' : peakUv.toStringAsFixed(1),
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: peakRisk.textColor,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'UV',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: peakRisk.textColor.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        const SizedBox(width: 10),

        // Avg UV Card
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFE9EDF0)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  offset: const Offset(0, 2),
                  blurRadius: 8,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(
                      Icons.show_chart_rounded,
                      size: 15,
                      color: Color(0xFF588157),
                    ),
                    SizedBox(width: 5),
                    Text(
                      'Rata-rata',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF707E94),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      history.isEmpty ? '-' : avgUv.toStringAsFixed(1),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1E2429),
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      'UV',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF707E94),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        const SizedBox(width: 10),

        // Export CSV Action Card
        InkWell(
          onTap: onExportTap,
          borderRadius: BorderRadius.circular(18),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              color: const Color(0xFF2E4F32),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF2E4F32).withValues(alpha: 0.2),
                  offset: const Offset(0, 4),
                  blurRadius: 10,
                ),
              ],
            ),
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.file_download_outlined,
                  size: 20,
                  color: Colors.white,
                ),
                SizedBox(height: 6),
                Text(
                  'Unduh CSV',
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
