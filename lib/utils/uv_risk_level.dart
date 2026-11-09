import 'package:flutter/material.dart';

enum UvRiskCategory {
  low,
  moderate,
  high,
  veryHigh,
}

class UvRiskLevel {
  final UvRiskCategory category;
  final String label;
  final String localizedName;
  final String summary;
  final Color primaryColor;
  final Color backgroundColor;
  final Color textColor;
  final List<String> tips;

  const UvRiskLevel({
    required this.category,
    required this.label,
    required this.localizedName,
    required this.summary,
    required this.primaryColor,
    required this.backgroundColor,
    required this.textColor,
    required this.tips,
  });

  static UvRiskLevel fromUvIndex(double uv) {
    if (uv < 3.0) {
      return const UvRiskLevel(
        category: UvRiskCategory.low,
        label: 'LOW',
        localizedName: 'Aman',
        summary: 'Risiko bahaya minimal dari sinar UV matahari.',
        // Soft Sage Green
        primaryColor: Color(0xFF588157),
        backgroundColor: Color(0xFFEFF5F0),
        textColor: Color(0xFF2E4F32),
        tips: [
          'Aman beraktivitas di luar ruangan.',
          'Gunakan kacamata hitam pada hari terik untuk kenyamanan mata.',
          'Cukup gunakan pelembap ringan atau tabir surya jika beraktivitas lama.',
        ],
      );
    } else if (uv < 6.0) {
      return const UvRiskLevel(
        category: UvRiskCategory.moderate,
        label: 'MODERATE',
        localizedName: 'Sedang',
        summary: 'Tingkat radiasi sedang. Perlindungan kulit disarankan.',
        // Soft Mustard / Warm Amber
        primaryColor: Color(0xFFC78B2A),
        backgroundColor: Color(0xFFFCF7EC),
        textColor: Color(0xFF6B4500),
        tips: [
          'Gunakan tabir surya SPF 30+ sebelum keluar ruangan.',
          'Kenakan topi atau kacamata dengan perlindungan UV 400.',
          'Cari tempat teduh jika berada di bawah matahari langsung siang hari.',
        ],
      );
    } else if (uv < 8.0) {
      return const UvRiskLevel(
        category: UvRiskCategory.high,
        label: 'HIGH',
        localizedName: 'Tinggi',
        summary: 'Risiko bahaya tinggi. Kurangi paparan langsung di siang hari.',
        // Soft Coral / Soft Orange
        primaryColor: Color(0xFFD65A31),
        backgroundColor: Color(0xFFFDF0EB),
        textColor: Color(0xFF7A2509),
        tips: [
          'Wajib gunakan tabir surya SPF 30-50 dan aplikasikan ulang tiap 2 jam.',
          'Kurangi aktivitas di bawah sinar matahari langsung pukul 10.00 - 16.00.',
          'Kenakan pakaian pelindung lengan panjang, topi bertepi lebar, dan kacamata UV.',
        ],
      );
    } else {
      return const UvRiskLevel(
        category: UvRiskCategory.veryHigh,
        label: 'VERY HIGH',
        localizedName: 'Sangat Tinggi',
        summary: 'Tingkat radiasi sangat tinggi. Kulit dapat terbakar dengan cepat.',
        // Elegant Soft Mulberry / Red-Purple
        primaryColor: Color(0xFFA54562),
        backgroundColor: Color(0xFFFBF0F3),
        textColor: Color(0xFF5E1B2E),
        tips: [
          'Hindari berada di luar ruangan antara pukul 10.00 - 16.00.',
          'Wajib tabir surya SPF 50+, pakaian tertutup pelindung UV, dan kacamata.',
          'Cari area berteduh maksimal atau tetaplah berada di dalam ruangan.',
        ],
      );
    }
  }
}
