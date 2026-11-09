import 'package:flutter/material.dart';

class ConnectionBadge extends StatelessWidget {
  final bool isConnected;
  final bool isDemo;
  final VoidCallback? onTap;

  const ConnectionBadge({
    super.key,
    required this.isConnected,
    this.isDemo = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = isConnected
        ? (isDemo ? const Color(0xFFE29578) : const Color(0xFF4A7C59))
        : const Color(0xFF9E9E9E);

    final statusText = isDemo
        ? 'Mode Demo'
        : (isConnected ? 'ThingSpeak Terhubung' : 'Terputus');

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: statusColor.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: statusColor.withValues(alpha: 0.3), width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(
                color: statusColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: statusColor.withValues(alpha: 0.4),
                    blurRadius: 4,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),
            Text(
              statusText,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: statusColor,
                letterSpacing: 0.1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
