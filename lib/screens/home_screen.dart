import 'dart:async';
import 'package:flutter/material.dart';
import '../models/uv_data.dart';
import '../services/thingspeak_service.dart';
import '../widgets/connection_badge.dart';
import '../widgets/health_tips_card.dart';
import '../widgets/uv_display_card.dart';
import '../widgets/uv_trend_chart.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late final ThingSpeakService _service;
  late final AnimationController _refreshAnimController;

  UvData? _latestData;
  List<UvData> _history = [];
  bool _isConnected = false;
  bool _isLoading = false;

  StreamSubscription<UvData>? _latestSub;
  StreamSubscription<List<UvData>>? _historySub;
  StreamSubscription<bool>? _connectionSub;

  @override
  void initState() {
    super.initState();
    _refreshAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    // Inisialisasi Service ThingSpeak
    _service = ThingSpeakService();

    // Subscribe to reactive data streams
    _latestSub = _service.latestDataStream.listen((data) {
      if (mounted) {
        setState(() {
          _latestData = data;
          _isLoading = false;
        });
      }
    });

    _historySub = _service.historyDataStream.listen((history) {
      if (mounted) {
        setState(() {
          _history = history;
        });
      }
    });

    _connectionSub = _service.connectionStateStream.listen((connected) {
      if (mounted) {
        setState(() {
          _isConnected = connected;
        });
      }
    });

    // Mulai auto-fetch berkala 15 detik
    _service.startAutoFetch();
  }

  @override
  void dispose() {
    _refreshAnimController.dispose();
    _latestSub?.cancel();
    _historySub?.cancel();
    _connectionSub?.cancel();
    _service.dispose();
    super.dispose();
  }

  Future<void> _handleRefresh() async {
    setState(() => _isLoading = true);
    _refreshAnimController.repeat();
    await _service.fetchAllData();
    if (mounted) {
      _refreshAnimController.stop();
      _refreshAnimController.reset();
      setState(() => _isLoading = false);
    }
  }

  void _showConfigDialog() {
    final channelController = TextEditingController(
      text: _service.isConfigured ? _service.channelId : '',
    );
    final apiKeyController = TextEditingController(text: _service.apiKey);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.tune_rounded, size: 22, color: Color(0xFF1E2429)),
            SizedBox(width: 8),
            Text(
              'Konfigurasi ThingSpeak',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Masukkan Channel ID ThingSpeak Anda untuk membaca data sensor secara real-time:',
              style: TextStyle(fontSize: 13, color: Color(0xFF6C757D), height: 1.4),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: channelController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Channel ID',
                hintText: 'Contoh: 1234567',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: apiKeyController,
              decoration: InputDecoration(
                labelText: 'Read API Key (Opsional)',
                hintText: 'Kosongkan jika publik',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _service.updateCredentials(channelId: 'CHANNEL_ID', apiKey: '');
              _handleRefresh();
            },
            child: const Text('Reset Demo', style: TextStyle(color: Color(0xFF8A99A8))),
          ),
          FilledButton(
            onPressed: () {
              final newId = channelController.text.trim();
              if (newId.isNotEmpty) {
                _service.updateCredentials(
                  channelId: newId,
                  apiKey: apiKeyController.text.trim(),
                );
                Navigator.pop(ctx);
                _handleRefresh();
              }
            },
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF2E4F32),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Simpan & Hubungkan'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FA),
      appBar: AppBar(
        titleSpacing: 20,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'UV Monitor',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1E2429),
                letterSpacing: -0.5,
              ),
            ),
            Text(
              'Pemantau Radiasi Matahari Real-Time',
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w400,
                color: const Color(0xFF1E2429).withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Konfigurasi Channel ThingSpeak',
            icon: const Icon(Icons.tune_rounded, size: 22),
            onPressed: _showConfigDialog,
          ),
          RotationTransition(
            turns: _refreshAnimController,
            child: IconButton(
              tooltip: 'Muat Ulang Data',
              icon: const Icon(Icons.refresh_rounded, size: 22),
              onPressed: _isLoading ? null : _handleRefresh,
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        color: const Color(0xFF588157),
        backgroundColor: Colors.white,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Connection Status Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ConnectionBadge(
                    isConnected: _isConnected || !_service.isConfigured,
                    isDemo: !_service.isConfigured,
                    onTap: _showConfigDialog,
                  ),
                  Text(
                    'Auto-sync: 15 detik',
                    style: TextStyle(
                      fontSize: 11.5,
                      color: const Color(0xFF707E94).withValues(alpha: 0.9),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Main UV Display Card
              UvDisplayCard(
                uvData: _latestData,
                isLoading: _isLoading,
              ),

              const SizedBox(height: 20),

              // Health Tips Card
              HealthTipsCard(
                uvData: _latestData,
              ),

              const SizedBox(height: 20),

              // UV Trend Chart (fl_chart)
              UvTrendChart(
                history: _history,
                isLoading: _isLoading,
              ),

              const SizedBox(height: 24),

              // Subtle informative footer
              Center(
                child: Column(
                  children: [
                    Text(
                      'Sumber Data: ThingSpeak IoT Feed (${_service.isConfigured ? "ID: ${_service.channelId}" : "Demo Mode"})',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFFA0ACB9),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'WHO UV Index Standards & Health Guidelines',
                      style: TextStyle(
                        fontSize: 10.5,
                        color: Color(0xFFB5BFC9),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
