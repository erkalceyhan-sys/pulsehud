import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/services/system_monitor_service.dart';
import '../../../core/services/wallpaper_service.dart';
import '../models/hud_theme_config.dart';
import '../painters/cyberpunk_painter.dart';
import '../painters/obsidian_painter.dart';
import '../painters/matrix_painter.dart';
import '../painters/reactor_painter.dart';
import '../../themes/screens/theme_picker_screen.dart';
import '../../settings/screens/settings_screen.dart';

class HudLiveScreen extends StatefulWidget {
  const HudLiveScreen({super.key});

  @override
  State<HudLiveScreen> createState() => _HudLiveScreenState();
}

class _HudLiveScreenState extends State<HudLiveScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  HudThemeConfig _currentTheme = HudThemeConfig.availableThemes.first;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Widget _buildPainter(HudThemeConfig theme, dynamic metrics) {
    switch (theme.type) {
      case HudThemeType.cyberpunkNeon:
        return CustomPaint(
          painter: CyberpunkPainter(metrics: metrics, animationValue: _animController.value),
          size: Size.infinite,
        );
      case HudThemeType.obsidianMinimalist:
        return CustomPaint(
          painter: ObsidianPainter(metrics: metrics, animationValue: _animController.value),
          size: Size.infinite,
        );
      case HudThemeType.matrixTerminal:
        return CustomPaint(
          painter: MatrixPainter(metrics: metrics, animationValue: _animController.value),
          size: Size.infinite,
        );
      case HudThemeType.sciFiReactor:
        return CustomPaint(
          painter: ReactorPainter(metrics: metrics, animationValue: _animController.value),
          size: Size.infinite,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final monitor = Provider.of<SystemMonitorService>(context);
    final m = monitor.metrics;

    return Scaffold(
      backgroundColor: _currentTheme.backgroundColor,
      body: AnimatedBuilder(
        animation: _animController,
        builder: (context, child) {
          return Stack(
            children: [
              // 1. Live Canvas HUD Animation
              Positioned.fill(
                child: _buildPainter(_currentTheme, m),
              ),

              // 2. Top Header Telemetry
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'PULSE // HUD',
                                style: TextStyle(
                                  color: _currentTheme.primaryAccent,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 2.0,
                                ),
                              ),
                              Text(
                                '${_currentTheme.title.toUpperCase()} MODE',
                                style: TextStyle(
                                  color: _currentTheme.secondaryAccent,
                                  fontSize: 10,
                                  letterSpacing: 1.5,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              IconButton(
                                icon: Icon(Icons.palette_outlined, color: _currentTheme.primaryAccent),
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
                                icon: Icon(Icons.settings_outlined, color: _currentTheme.primaryAccent),
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
                      const SizedBox(height: 20),

                      // Metrics Cards
                      _buildMetricRow('CPU LOAD', '${m.cpuUsage}%', '${m.cpuFrequencyGhz.toStringAsFixed(2)} GHz', _currentTheme.primaryAccent),
                      const SizedBox(height: 8),
                      _buildMetricRow('RAM USED', '${m.ramUsagePercent.toStringAsFixed(1)}%', '${m.ramUsedGb} / ${m.ramTotalGb} GB', _currentTheme.secondaryAccent),
                      const SizedBox(height: 8),
                      _buildMetricRow('NETWORK', '${m.downloadSpeedMbps} MB/s', 'PING ${m.pingMs}ms', const Color(0xFF00FF9D)),
                      const SizedBox(height: 8),
                      _buildMetricRow('BATTERY', '${m.batteryLevel}%', '${m.batteryTemperatureC}°C', const Color(0xFFFFE600)),
                    ],
                  ),
                ),
              ),

              // 3. Bottom Action Bar (Apply to Wallpaper)
              Positioned(
                bottom: 30,
                left: 20,
                right: 20,
                child: SafeArea(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _currentTheme.primaryAccent,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 8,
                    ),
                    onPressed: () async {
                      final success = await WallpaperService.setLiveWallpaper();
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            success
                                ? 'Wallpaper applied successfully!'
                                : 'Applying live wallpaper to system background...',
                          ),
                          backgroundColor: _currentTheme.cardColorDark(),
                        ),
                      );
                    },
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.wallpaper, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'SET AS LIVE WALLPAPER',
                          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMetricRow(String label, String value, String sub, Color accent) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF101726).withOpacity(0.6),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: accent.withOpacity(0.3), width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11, letterSpacing: 1.2)),
          Row(
            children: [
              Text(value, style: TextStyle(color: accent, fontSize: 13, fontWeight: FontWeight.bold)),
              const SizedBox(width: 8),
              Text('($sub)', style: const TextStyle(color: Colors.white38, fontSize: 10)),
            ],
          ),
        ],
      ),
    );
  }
}

extension ThemeColorExt on HudThemeConfig {
  Color cardColorDark() => const Color(0xFF141E33);
}
