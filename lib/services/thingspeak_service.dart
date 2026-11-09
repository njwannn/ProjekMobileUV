import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/uv_data.dart';

class ThingSpeakService {
  // ==========================================
  // CONFIGURATION (Ganti dengan Channel ID Anda)
  // ==========================================
  static const String defaultChannelId = 'CHANNEL_ID'; // Placeholder Channel ID
  static const String defaultApiKey = ''; // Optional Read API Key jika channel privat

  String channelId;
  String apiKey;

  Timer? _pollingTimer;
  final Duration pollingInterval;

  // Stream Controllers for Reactive UI updates
  final _latestDataController = StreamController<UvData>.broadcast();
  final _historyDataController = StreamController<List<UvData>>.broadcast();
  final _connectionStateController = StreamController<bool>.broadcast();

  Stream<UvData> get latestDataStream => _latestDataController.stream;
  Stream<List<UvData>> get historyDataStream => _historyDataController.stream;
  Stream<bool> get connectionStateStream => _connectionStateController.stream;

  ThingSpeakService({
    this.channelId = defaultChannelId,
    this.apiKey = defaultApiKey,
    this.pollingInterval = const Duration(seconds: 15),
  });

  void updateCredentials({required String channelId, String apiKey = ''}) {
    this.channelId = channelId.trim();
    this.apiKey = apiKey.trim();
    // Fetch immediately with new credentials
    fetchAllData();
  }

  bool get isConfigured =>
      channelId.isNotEmpty &&
      channelId != 'CHANNEL_ID' &&
      channelId != 'YOUR_CHANNEL_ID';

  /// Memulai auto-fetch periodik (default 15 detik)
  void startAutoFetch() {
    stopAutoFetch();
    // Panggilan pertama saat start
    fetchAllData();
    // Timer berkala 15 detik
    _pollingTimer = Timer.periodic(pollingInterval, (_) {
      fetchAllData();
    });
  }

  /// Menghentikan timer auto-fetch
  void stopAutoFetch() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }

  /// Mengambil data terbaru (results=1) dan histori terbaru (results=10) untuk grafik
  Future<void> fetchAllData() async {
    try {
      final history = await fetchHistory(results: 10);
      if (history.isNotEmpty) {
        _historyDataController.add(history);
        _latestDataController.add(history.last);
        _connectionStateController.add(true);
      }
    } catch (e) {
      debugPrint('Error fetching ThingSpeak data: $e');
      _connectionStateController.add(false);

      // Jika masih menggunakan placeholder CHANNEL_ID, sediakan demo mock data yang elegan
      if (!isConfigured) {
        final mockHistory = _generateMockHistory();
        _historyDataController.add(mockHistory);
        _latestDataController.add(mockHistory.last);
      }
    }
  }

  /// Request data feed terbaru (results=1)
  Future<UvData> fetchLatestFeed() async {
    if (!isConfigured) {
      return _generateSingleMock();
    }

    final queryParams = <String, String>{'results': '1'};
    if (apiKey.isNotEmpty) {
      queryParams['api_key'] = apiKey;
    }

    final uri = Uri.https(
      'api.thingspeak.com',
      '/channels/$channelId/feeds.json',
      queryParams,
    );

    final response = await http.get(uri).timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final feeds = data['feeds'] as List<dynamic>?;
      if (feeds != null && feeds.isNotEmpty) {
        return UvData.fromJson(feeds.last as Map<String, dynamic>);
      }
      throw Exception('Data feed kosong');
    } else {
      throw Exception(
          'Gagal memuat data dari ThingSpeak (Status: ${response.statusCode})');
    }
  }

  /// Request histori feed untuk visualisasi grafik tren
  Future<List<UvData>> fetchHistory({int results = 10}) async {
    if (!isConfigured) {
      return _generateMockHistory();
    }

    final queryParams = <String, String>{'results': results.toString()};
    if (apiKey.isNotEmpty) {
      queryParams['api_key'] = apiKey;
    }

    final uri = Uri.https(
      'api.thingspeak.com',
      '/channels/$channelId/feeds.json',
      queryParams,
    );

    final response = await http.get(uri).timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final feeds = data['feeds'] as List<dynamic>?;
      if (feeds != null && feeds.isNotEmpty) {
        return feeds
            .map((item) => UvData.fromJson(item as Map<String, dynamic>))
            .toList();
      }
      return [];
    } else {
      throw Exception(
          'Gagal memuat histori ThingSpeak (Status: ${response.statusCode})');
    }
  }

  /// Mock data jika pengguna belum memasukkan Channel ID asli
  List<UvData> _generateMockHistory() {
    final now = DateTime.now();
    final random = Random();
    final baseValues = [1.2, 1.8, 2.5, 3.8, 5.2, 6.7, 7.3, 6.8, 5.1, 4.2];

    return List.generate(baseValues.length, (index) {
      final variation = (random.nextDouble() * 0.4) - 0.2;
      final val = (baseValues[index] + variation).clamp(0.0, 11.0);
      return UvData(
        uvIndex: double.parse(val.toStringAsFixed(1)),
        timestamp: now.subtract(Duration(minutes: (10 - index) * 15)),
        entryId: index + 1,
      );
    });
  }

  UvData _generateSingleMock() {
    return UvData(
      uvIndex: 4.6,
      timestamp: DateTime.now(),
      entryId: 999,
    );
  }

  void dispose() {
    stopAutoFetch();
    _latestDataController.close();
    _historyDataController.close();
    _connectionStateController.close();
  }
}
