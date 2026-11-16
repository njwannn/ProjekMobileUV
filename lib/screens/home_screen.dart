import 'dart:async';
import 'package:flutter/material.dart';
import '../models/uv_data.dart';
import '../services/thingspeak_service.dart';
import '../widgets/connection_badge.dart';
import '../widgets/health_tips_card.dart';
import '../widgets/uv_display_card.dart';
import '../widgets/uv_stats_row.dart';
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
  bool _isExporting = false;

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

  void _showExportCsvSheet() {
    int selectedCount = 50;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (bottomSheetContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 36,
                      height: 4,
                      decoration: BoxDecoration(
                        color: const Color(0xFFDCE2E6),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2E4F32).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.table_view_rounded,
                          size: 22,
                          color: Color(0xFF2E4F32),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Unduh / Ekspor Data CSV',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1E2429),
                            ),
                          ),
                          Text(
                            'Kompatibel dengan Excel, Google Sheets, & SPSS',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF707E94),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Pilih Rentang Data Feed:',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF333E48),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [25, 50, 100].map((count) {
                      final isSelected = selectedCount == count;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text('$count Data Terakhir'),
                          selected: isSelected,
                          onSelected: (val) {
                            if (val) {
                              setModalState(() => selectedCount = count);
                            }
                          },
                          selectedColor: const Color(0xFF2E4F32),
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : const Color(0xFF333E48),
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                            fontSize: 12.5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color: isSelected ? const Color(0xFF2E4F32) : const Color(0xFFE9EDF0),
                            ),
                          ),
                          showCheckmark: false,
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 18),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF7F9FA),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE9EDF0)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline_rounded, size: 18, color: Color(0xFF707E94)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Kolom yang diekspor: Entry ID, Waktu Lokal, UTC, Indeks UV, Status Bahaya, dan Rekomendasi Perlindungan.',
                            style: TextStyle(
                              fontSize: 11.5,
                              color: const Color(0xFF5A6672),
                              height: 1.35,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: FilledButton.icon(
                      onPressed: _isExporting
                          ? null
                          : () async {
                              Navigator.pop(bottomSheetContext);
                              await _performExport(selectedCount);
                            },
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF2E4F32),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      icon: _isExporting
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Icon(Icons.file_download_outlined, size: 20),
                      label: Text(
                        _isExporting ? 'Menyiapkan CSV...' : 'Download & Bagikan File CSV',
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _performExport(int resultsCount) async {
    setState(() => _isExporting = true);
    try {
      final file = await _service.exportDataCsv(results: resultsCount);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text('File CSV "${file.uri.pathSegments.last}" berhasil disiapkan.'),
                ),
              ],
            ),
            backgroundColor: const Color(0xFF2E4F32),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal mengekspor data: $e'),
            backgroundColor: const Color(0xFFD65A31),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isExporting = false);
      }
    }
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
            tooltip: 'Unduh / Ekspor CSV',
            icon: const Icon(Icons.file_download_outlined, size: 22),
            onPressed: _showExportCsvSheet,
          ),
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

              const SizedBox(height: 16),

              // Quick Stats & Export Row (Peak UV, Avg UV, Export CSV)
              UvStatsRow(
                history: _history,
                onExportTap: _showExportCsvSheet,
              ),

              const SizedBox(height: 16),

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
