class HudMetrics {
  final double cpuUsage; // 0.0 to 100.0 %
  final double cpuFrequencyGhz;
  final double ramUsedGb;
  final double ramTotalGb;
  final double downloadSpeedMbps;
  final double uploadSpeedMbps;
  final int pingMs;
  final int batteryLevel; // 0 to 100
  final bool isCharging;
  final double batteryTemperatureC;
  final double storageUsedPercent;
  final double storageFreeGb;
  final int currentFps;
  final bool isOffline;
  final String connectionType;

  HudMetrics({
    required this.cpuUsage,
    required this.cpuFrequencyGhz,
    required this.ramUsedGb,
    required this.ramTotalGb,
    required this.downloadSpeedMbps,
    required this.uploadSpeedMbps,
    required this.pingMs,
    required this.batteryLevel,
    this.isCharging = false,
    required this.batteryTemperatureC,
    required this.storageUsedPercent,
    this.storageFreeGb = 45.8,
    required this.currentFps,
    this.isOffline = false,
    this.connectionType = '5G',
  });

  double get ramUsagePercent => (ramUsedGb / ramTotalGb) * 100.0;
}
