import 'package:flutter/material.dart';
import '../models/uv_data.dart';
import '../utils/uv_risk_level.dart';

class UvDisplayCard extends StatelessWidget {
  final UvData? uvData;
  final bool isLoading;

  const UvDisplayCard({
    super.key,
    required this.uvData,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final data = uvData ??
        UvData(
          uvIndex: 0.0,
          timestamp: DateTime.now(),
        );

    final risk = data.riskLevel;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 26),
      decoration: BoxDecoration(
        color: risk.backgroundColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: risk.primaryColor.withValues(alpha: 0.22),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: risk.primaryColor.withValues(alpha: 0.08),
            offset: const Offset(0, 10),
            blurRadius: 24,
            spreadRadius: -4,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row: Category Pill & Loading / Live Indicator
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: risk.primaryColor.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: risk.primaryColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${risk.label} • ${risk.localizedName.toUpperCase()}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                        color: risk.textColor,
                      ),
                    ),
                  ],
                ),
              ),
              if (isLoading)
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(risk.primaryColor),
                  ),
                )
              else
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.schedule_rounded,
                      size: 14,
                      color: risk.textColor.withValues(alpha: 0.7),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      data.formattedTime,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: risk.textColor.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
            ],
          ),

          const SizedBox(height: 20),

          // Main UV Number with elegant typography
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                data.uvIndex.toStringAsFixed(1),
                style: TextStyle(
                  fontSize: 72,
                  fontWeight: FontWeight.w800,
                  height: 1.0,
                  letterSpacing: -2.0,
                  color: risk.textColor,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'UV INDEX',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                  color: risk.textColor.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Risk Summary text
          Text(
            risk.summary,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              height: 1.45,
              color: risk.textColor.withValues(alpha: 0.85),
            ),
          ),

          const SizedBox(height: 20),

          // Visual Segmented Scale (Minimalist Meter 0 - 11+)
          _buildUvScaleBar(data.uvIndex, risk),
        ],
      ),
    );
  }

  Widget _buildUvScaleBar(double uv, UvRiskLevel risk) {
    // Clamp uv index between 0 and 12 for the scale marker
    final normalized = (uv / 12.0).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          alignment: Alignment.centerLeft,
          children: [
            // Background bar with subtle gradients representing UV bands
            Container(
              height: 6,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF81C784), // Low
                    Color(0xFFFFD54F), // Moderate
                    Color(0xFFFF8A65), // High
                    Color(0xFFBA68C8), // Very High
                  ],
                ),
              ),
            ),
            // Current position thumb
            LayoutBuilder(
              builder: (context, constraints) {
                final thumbOffset = constraints.maxWidth * normalized;
                return Transform.translate(
                  offset: Offset((thumbOffset - 7).clamp(0.0, constraints.maxWidth - 14), 0),
                  child: Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: risk.primaryColor,
                        width: 3,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.15),
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '0 (Aman)',
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w500,
                color: risk.textColor.withValues(alpha: 0.5),
              ),
            ),
            Text(
              '3 (Sedang)',
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w500,
                color: risk.textColor.withValues(alpha: 0.5),
              ),
            ),
            Text(
              '6 (Tinggi)',
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w500,
                color: risk.textColor.withValues(alpha: 0.5),
              ),
            ),
            Text(
              '8+ (Ekstrem)',
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w500,
                color: risk.textColor.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
