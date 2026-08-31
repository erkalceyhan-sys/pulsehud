import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/services/system_monitor_service.dart';
import '../models/hud_metrics.dart';
import '../models/hud_theme_config.dart';
import '../painters/obsidian_painter.dart';
import '../painters/cyberpunk_painter.dart';
import '../painters/matrix_painter.dart';
import '../painters/reactor_painter.dart';
import '../../themes/screens/theme_picker_screen.dart';
import '../../settings/screens/settings_screen.dart';

enum WidgetPreviewSize { small, medium, large }

class HudLiveScreen extends StatefulWidget {
  const HudLiveScreen({super.key});

  @override
  State<HudLiveScreen> createState() => _HudLiveScreenState();
}

class _HudLiveScreenState extends State<HudLiveScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  HudThemeConfig _currentTheme =
      HudThemeConfig.availableThemes[1]; // Default: Apple Obsidian
  WidgetPreviewSize _previewSize = WidgetPreviewSize.medium;

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

  CustomPainter _buildPainter(HudMetrics m) {
    switch (_currentTheme.id) {
      case 'cyberpunk_neon':
        return CyberpunkPainter(
            metrics: m, animationValue: _animController.value);
      case 'matrix_digital_rain':
        return MatrixPainter(metrics: m, animationValue: _animController.value);
      case 'reactor_core':
        return ReactorPainter(
            metrics: m, animationValue: _animController.value);
      case 'obsidian_minimalist':
      default:
        return ObsidianPainter(
            metrics: m, animationValue: _animController.value);
    }
  }

  @override
  Widget build(BuildContext context) {
    final monitor = Provider.of<SystemMonitorService>(context);
    final m = monitor.metrics;

    return Scaffold(
      backgroundColor: const Color(0xFF000000),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'WIDGET STUDIO',
                        style: TextStyle(
                          color: Color(0xFF8E8E93),
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.5,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'PulseHUD',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.8,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.palette_outlined,
                            color: Colors.white),
                        onPressed: () async {
                          final selected = await Navigator.push<HudThemeConfig>(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const ThemePickerScreen()),
                          );
                          if (selected != null) {
                            setState(() => _currentTheme = selected);
                          }
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.settings_outlined,
                            color: Colors.white),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const SettingsScreen()),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Size Selector Tabs (Small, Medium, Large)
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: const Color(0xFF1C1C1E),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    _buildSizeTab('Small', WidgetPreviewSize.small),
                    _buildSizeTab('Medium', WidgetPreviewSize.medium),
                    _buildSizeTab('Large', WidgetPreviewSize.large),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Interactive Apple Live Widget Preview Container
              Center(
                child: _buildWidgetPreview(m),
              ),
              const SizedBox(height: 28),

              // Real Hardware Status Hub (Live Sensor Data)
              const Text(
                'LIVE SENSOR TELEMETRY',
                style: TextStyle(
                  color: Color(0xFF8E8E93),
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 12),

              // 2x2 Telemetry Cards
              Row(
                children: [
                  Expanded(
                    child: _buildTelemetryCard(
                      title: 'PROCESSOR',
                      value: '${m.cpuUsage.toInt()}%',
                      subvalue:
                          '${m.cpuFrequencyGhz.toStringAsFixed(2)} GHz • 8-Core',
                      accentColor: const Color(0xFFFF453A),
                      icon: Icons.memory,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildTelemetryCard(
                      title: 'MEMORY',
                      value: '${m.ramUsedGb.toStringAsFixed(1)} GB',
                      subvalue:
                          '${m.ramUsagePercent.toInt()}% of ${m.ramTotalGb.toInt()} GB',
                      accentColor: const Color(0xFF30D158),
                      icon: Icons.dns_outlined,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildTelemetryCard(
                      title: 'NETWORK',
                      value: m.isOffline
                          ? 'Offline'
                          : '${m.downloadSpeedMbps.toStringAsFixed(1)} MB/s',
                      subvalue: m.isOffline
                          ? 'Airplane Mode / No Con'
                          : '${m.connectionType} • ${m.pingMs}ms',
                      accentColor: m.isOffline
                          ? const Color(0xFF8E8E93)
                          : const Color(0xFF0A84FF),
                      icon:
                          m.isOffline ? Icons.airplanemode_active : Icons.wifi,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildTelemetryCard(
                      title: 'BATTERY & THERMAL',
                      value: '${m.batteryLevel}%',
                      subvalue: m.isCharging
                          ? 'Charging ⚡ • ${m.thermalState}'
                          : '${m.thermalState} • ${m.storageFreeGb.toStringAsFixed(0)}GB Free',
                      accentColor: const Color(0xFFFFD60A),
                      icon: m.isCharging
                          ? Icons.battery_charging_full
                          : Icons.battery_full,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),

              // How to Add to Home Screen Apple Guide Card
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFF141416),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFF2C2C2E)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color:
                                const Color(0xFF0A84FF).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.widgets_outlined,
                              color: Color(0xFF0A84FF), size: 20),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'How to Add Widgets',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    _buildGuideStep('1',
                        'Go to your iPhone Home Screen and long press any empty area.'),
                    _buildGuideStep(
                        '2', 'Tap the "+" button in the top left corner.'),
                    _buildGuideStep('3',
                        'Search for "PulseHUD" and choose your preferred size.'),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Sync Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  icon: const Icon(Icons.sync, size: 20),
                  label: const Text(
                    'Sync & Update Widgets',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.2,
                    ),
                  ),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                            'Widget telemetry data synchronized successfully.'),
                        backgroundColor: Color(0xFF1C1C1E),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSizeTab(String title, WidgetPreviewSize size) {
    final isSelected = _previewSize == size;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _previewSize = size),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF2C2C2E) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                color: isSelected ? Colors.white : const Color(0xFF8E8E93),
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWidgetPreview(HudMetrics m) {
    switch (_previewSize) {
      case WidgetPreviewSize.small:
        return _buildSmallWidget(m);
      case WidgetPreviewSize.medium:
        return _buildMediumWidget(m);
      case WidgetPreviewSize.large:
        return _buildLargeWidget(m);
    }
  }

  // --- Small Widget (2x2) ---
  Widget _buildSmallWidget(HudMetrics m) {
    return Container(
      width: 165,
      height: 165,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF141416),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF2C2C2E)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'PULSE',
                style: TextStyle(
                  color: Color(0xFF8E8E93),
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                ),
              ),
              Icon(
                m.isOffline ? Icons.airplanemode_active : Icons.bolt,
                color: m.isOffline
                    ? const Color(0xFF8E8E93)
                    : const Color(0xFFFFD60A),
                size: 14,
              ),
            ],
          ),
          Center(
            child: SizedBox(
              width: 70,
              height: 70,
              child: AnimatedBuilder(
                animation: _animController,
                builder: (context, _) => CustomPaint(
                  size: const Size(70, 70),
                  painter: _buildPainter(m),
                ),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'CPU ${m.cpuUsage.toInt()}%',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                'BAT ${m.batteryLevel}%',
                style: const TextStyle(
                  color: Color(0xFF30D158),
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- Medium Widget (4x2) - Apple Aesthetic ---
  Widget _buildMediumWidget(HudMetrics m) {
    return Container(
      width: double.infinity,
      height: 165,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF141416),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF2C2C2E)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          // Left: Activity Rings
          SizedBox(
            width: 110,
            height: 110,
            child: Stack(
              alignment: Alignment.center,
              children: [
                AnimatedBuilder(
                  animation: _animController,
                  builder: (context, _) => CustomPaint(
                    size: const Size(110, 110),
                    painter: _buildPainter(m),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${m.cpuUsage.toInt()}%',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const Text(
                      'CPU',
                      style: TextStyle(
                        color: Color(0xFF8E8E93),
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 18),

          // Right: Real Telemetry Columns
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Network Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          m.isOffline ? Icons.airplanemode_active : Icons.wifi,
                          color: m.isOffline
                              ? const Color(0xFF8E8E93)
                              : const Color(0xFF0A84FF),
                          size: 15,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          m.isOffline ? 'Offline' : m.connectionType,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      m.isOffline
                          ? '0.0 KB/s'
                          : '${m.downloadSpeedMbps.toStringAsFixed(1)} MB/s',
                      style: TextStyle(
                        color: m.isOffline
                            ? const Color(0xFF8E8E93)
                            : const Color(0xFF0A84FF),
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const Divider(color: Color(0xFF2C2C2E), height: 1),

                // RAM Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.dns_outlined,
                            color: Color(0xFF30D158), size: 15),
                        SizedBox(width: 6),
                        Text(
                          'Memory',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '${m.ramUsedGb.toStringAsFixed(1)} / ${m.ramTotalGb.toInt()} GB',
                      style: const TextStyle(
                        color: Color(0xFF30D158),
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const Divider(color: Color(0xFF2C2C2E), height: 1),

                // Battery Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          m.isCharging
                              ? Icons.battery_charging_full
                              : Icons.battery_full,
                          color: const Color(0xFFFFD60A),
                          size: 15,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          m.isCharging ? 'Battery (Charging)' : 'Battery',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '${m.batteryLevel}%',
                      style: const TextStyle(
                        color: Color(0xFFFFD60A),
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- Large Widget (4x4) ---
  Widget _buildLargeWidget(HudMetrics m) {
    return Container(
      width: double.infinity,
      height: 320,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF141416),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFF2C2C2E)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'SYSTEM COCKPIT',
                style: TextStyle(
                  color: Color(0xFF8E8E93),
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.5,
                ),
              ),
              Text(
                '${m.currentFps} FPS • 60Hz',
                style: const TextStyle(
                  color: Color(0xFF30D158),
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const Spacer(),
          SizedBox(
            width: 140,
            height: 140,
            child: Stack(
              alignment: Alignment.center,
              children: [
                AnimatedBuilder(
                  animation: _animController,
                  builder: (context, _) => CustomPaint(
                    size: const Size(140, 140),
                    painter: _buildPainter(m),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${m.cpuUsage.toInt()}%',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                      ),
                    ),
                    Text(
                      '${m.cpuFrequencyGhz.toStringAsFixed(2)} GHz',
                      style: const TextStyle(
                        color: Color(0xFF8E8E93),
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildMiniMetric('RAM', '${m.ramUsagePercent.toInt()}%',
                  const Color(0xFF30D158)),
              _buildMiniMetric(
                  'NETWORK',
                  m.isOffline ? 'Offline' : '${m.downloadSpeedMbps.toInt()}M',
                  const Color(0xFF0A84FF)),
              _buildMiniMetric(
                  'BATTERY', '${m.batteryLevel}%', const Color(0xFFFFD60A)),
              _buildMiniMetric('STORAGE', '${m.storageFreeGb.toInt()}GB',
                  const Color(0xFFFF9F0A)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniMetric(String label, String val, Color col) {
    return Column(
      children: [
        Text(
          val,
          style:
              TextStyle(color: col, fontSize: 14, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
              color: Color(0xFF8E8E93),
              fontSize: 9,
              fontWeight: FontWeight.w700),
        ),
      ],
    );
  }

  Widget _buildTelemetryCard({
    required String title,
    required String value,
    required String subvalue,
    required Color accentColor,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF141416),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2C2C2E)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xFF8E8E93),
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                ),
              ),
              Icon(icon, color: accentColor, size: 16),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subvalue,
            style: const TextStyle(
              color: Color(0xFF8E8E93),
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildGuideStep(String stepNumber, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: const BoxDecoration(
              color: Color(0xFF2C2C2E),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                stepNumber,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                  color: Color(0xFFE5E5EA), fontSize: 13, height: 1.3),
            ),
          ),
        ],
      ),
    );
  }
}
