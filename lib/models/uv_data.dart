import 'package:intl/intl.dart';
import '../utils/uv_risk_level.dart';

class UvData {
  final double uvIndex;
  final DateTime timestamp;
  final int? entryId;

  const UvData({
    required this.uvIndex,
    required this.timestamp,
    this.entryId,
  });

  UvRiskLevel get riskLevel => UvRiskLevel.fromUvIndex(uvIndex);

  String get formattedTime {
    return DateFormat('HH:mm:ss').format(timestamp);
  }

  String get formattedDateTime {
    return DateFormat('d MMM yyyy, HH:mm').format(timestamp);
  }

  factory UvData.fromJson(Map<String, dynamic> json) {
    // Parse UV index safely from field1 (string, double, or int)
    double parsedUv = 0.0;
    final rawField1 = json['field1'];
    if (rawField1 != null) {
      if (rawField1 is num) {
        parsedUv = rawField1.toDouble();
      } else if (rawField1 is String) {
        parsedUv = double.tryParse(rawField1) ?? 0.0;
      }
    }

    // Ensure non-negative
    if (parsedUv < 0) parsedUv = 0.0;

    // Parse created_at timestamp safely
    DateTime parsedTime = DateTime.now();
    final rawCreatedAt = json['created_at'];
    if (rawCreatedAt != null && rawCreatedAt is String) {
      final parsed = DateTime.tryParse(rawCreatedAt);
      if (parsed != null) {
        parsedTime = parsed.toLocal();
      }
    }

    // Parse entry_id safely
    int? parsedEntryId;
    final rawEntryId = json['entry_id'];
    if (rawEntryId is int) {
      parsedEntryId = rawEntryId;
    } else if (rawEntryId is String) {
      parsedEntryId = int.tryParse(rawEntryId);
    }

    return UvData(
      uvIndex: parsedUv,
      timestamp: parsedTime,
      entryId: parsedEntryId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'field1': uvIndex.toStringAsFixed(1),
      'created_at': timestamp.toUtc().toIso8601String(),
      'entry_id': entryId,
    };
  }

  @override
  String toString() => 'UvData(uvIndex: $uvIndex, timestamp: $timestamp, entryId: $entryId)';
}
