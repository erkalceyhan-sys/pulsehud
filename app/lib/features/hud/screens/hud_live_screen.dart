import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/services/system_monitor_service.dart';
import '../../../core/services/wallpaper_service.dart';
import '../models/hud_theme_config.dart';
import '../painters/obsidian_painter.dart';
import '../../themes/screens/theme_picker_screen.dart';
import '../../settings/screens/settings_screen.dart';

class HudLiveScreen extends StatefulWidget {
  const HudLiveScreen({super.key});

  @override
  State<HudLiveScreen> createState() => _HudLiveScreenState();
}

class _HudLiveScreenState extends State<HudLiveScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  HudThemeConfig _currentTheme = HudThemeConfig.availableThemes[1]; // Default: Apple Obsidian Minimalist

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final monitor = Provider.of<SystemMonitorService>(context);
    final m = monitor.metrics;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'HARDWARE',
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Live Pulse',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.palette_outlined, color: Colors.white70),
                        onPressed: () async {
                          final selected = await Navigator.push<HudThemeConfig>(
                            context,
                            MaterialPageRoute(builder: (_) => const ThemePickerScreen()),
                          );
                          if (selected != null) {
                            setState(() => _currentTheme = selected);
                          }
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.settings_outlined, color: Colors.white70),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const SettingsScreen()),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Central Apple Activity Rings
              Center(
                child: SizedBox(
                  width: 240,
                  height: 240,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      AnimatedBuilder(
                        animation: _animController,
                        builder: (context, _) {
                          return CustomPaint(
                            size: const Size(240, 240),
                            painter: ObsidianPainter(
                              metrics: m,
                              animationValue: _animController.value,
                            ),
                          );
                        },
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            m.cpuFrequencyGhz.toStringAsFixed(2),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 34,
                              fontWeight: FontWeight.bold,
                              letterSpacing: -1.0,
                            ),
                          ),
                          const Text(
                            'GHz',
                            style: TextStyle(
                              color: Colors.white60,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'CPU FREQ',
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 28),

              // 2x2 Apple Style Cards Grid
              Row(
                children: [
                  Expanded(
                    child: _buildAppleCard(
                      label: 'CPU USAGE',
                      value: '${m.cpuUsage.toStringAsFixed(0)}%',
                      sub: '8 Cores • 60 FPS',
                      indicatorColor: const Color(0xFFFF453A),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: _buildAppleCard(
                      label: 'MEMORY',
                      value: '${m.ramUsedGb.toStringAsFixed(1)} GB',
                      sub: '${m.ramUsagePercent.toStringAsFixed(0)}% of 8.0 GB',
                      indicatorColor: const Color(0xFF30D158),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: _buildAppleCard(
                      label: 'NETWORK',
                      value: '${m.downloadSpeedMbps.toStringAsFixed(0)} MB/s',
                      sub: 'Ping ${m.pingMs}ms • 5G',
                      indicatorColor: const Color(0xFF0A84FF),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: _buildAppleCard(
                      label: 'THERMALS',
                      value: '${m.batteryTemperatureC}°C',
                      sub: 'Battery ${m.batteryLevel}% • Normal',
                      indicatorColor: const Color(0xFFFFD60A),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Solid Apple White Action Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  onPressed: () async {
                    final success = await WallpaperService.setLiveWallpaper();
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          success
                              ? 'Wallpaper configured successfully!'
                              : 'Applying live hardware wallpaper...',
                        ),
                        backgroundColor: const Color(0xFF1C1C1E),
                      ),
                    );
                  },
                  child: const Text(
                    'Set as Wallpaper',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.2,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppleCard({
    required String label,
    required String value,
    required String sub,
    required Color indicatorColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF2C2C2E), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: indicatorColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            sub,
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
