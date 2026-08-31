import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import '../../features/hud/models/hud_metrics.dart';

class SystemMonitorService extends ChangeNotifier {
  late Timer _timer;
  final Random _rnd = Random();

  HudMetrics _metrics = HudMetrics(
    cpuUsage: 28.5,
    cpuFrequencyGhz: 2.84,
    ramUsedGb: 4.2,
    ramTotalGb: 8.0,
    downloadSpeedMbps: 84.5,
    uploadSpeedMbps: 22.1,
    pingMs: 16,
    batteryLevel: 88,
    batteryTemperatureC: 31.2,
    storageUsedPercent: 64.0,
    currentFps: 60,
  );

  HudMetrics get metrics => _metrics;

  SystemMonitorService() {
    _startMonitoring();
  }

  void _startMonitoring() {
    _timer = Timer.periodic(const Duration(milliseconds: 1000), (timer) {
      // Realistic live fluctuation
      double newCpu = (_metrics.cpuUsage + (_rnd.nextDouble() * 14.0 - 7.0))
          .clamp(8.0, 96.0);
      double newRam = (_metrics.ramUsedGb + (_rnd.nextDouble() * 0.2 - 0.1))
          .clamp(2.5, 7.6);
      double newDl =
          (_metrics.downloadSpeedMbps + (_rnd.nextDouble() * 20.0 - 10.0))
              .clamp(5.0, 240.0);
      double newUl =
          (_metrics.uploadSpeedMbps + (_rnd.nextDouble() * 6.0 - 3.0))
              .clamp(2.0, 80.0);
      int newPing = (_metrics.pingMs + (_rnd.nextInt(5) - 2)).clamp(9, 45);
      double newTemp =
          (_metrics.batteryTemperatureC + (_rnd.nextDouble() * 0.2 - 0.1))
              .clamp(28.0, 42.0);

      _metrics = HudMetrics(
        cpuUsage: double.parse(newCpu.toStringAsFixed(1)),
        cpuFrequencyGhz: 2.4 + (newCpu / 100.0) * 0.8,
        ramUsedGb: double.parse(newRam.toStringAsFixed(2)),
        ramTotalGb: 8.0,
        downloadSpeedMbps: double.parse(newDl.toStringAsFixed(1)),
        uploadSpeedMbps: double.parse(newUl.toStringAsFixed(1)),
        pingMs: newPing,
        batteryLevel: _metrics.batteryLevel,
        batteryTemperatureC: double.parse(newTemp.toStringAsFixed(1)),
        storageUsedPercent: 64.0,
        currentFps: 60,
      );

      notifyListeners();
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }
}
