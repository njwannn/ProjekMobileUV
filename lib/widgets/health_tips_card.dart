import 'package:flutter/material.dart';
import '../models/uv_data.dart';
import '../utils/uv_risk_level.dart';

class HealthTipsCard extends StatelessWidget {
  final UvData? uvData;

  const HealthTipsCard({
    super.key,
    required this.uvData,
  });

  @override
  Widget build(BuildContext context) {
    final risk = uvData?.riskLevel ?? UvRiskLevel.fromUvIndex(0.0);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xFFE9EDF0),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            offset: const Offset(0, 4),
            blurRadius: 16,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: risk.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.health_and_safety_outlined,
                  size: 20,
                  color: risk.primaryColor,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Saran Perlindungan Kulit',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1E2429),
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          ...risk.tips.asMap().entries.map((entry) {
            final index = entry.key;
            final tipText = entry.value;

            IconData iconData;
            switch (index) {
              case 0:
                iconData = Icons.wb_sunny_outlined;
                break;
              case 1:
                iconData = Icons.remove_red_eye_outlined;
                break;
              default:
                iconData = Icons.umbrella_outlined;
            }

            return Padding(
              padding: EdgeInsets.only(bottom: index == risk.tips.length - 1 ? 0 : 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 2),
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF4F6F8),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      iconData,
                      size: 15,
                      color: const Color(0xFF5A6672),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      tipText,
                      style: const TextStyle(
                        fontSize: 13.5,
                        height: 1.4,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF333E48),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
