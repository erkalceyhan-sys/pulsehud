class HudMetrics {
  final double cpuUsage; // 0.0 to 100.0 %
  final double cpuFrequencyGhz;
  final double ramUsedGb;
  final double ramTotalGb;
  final double downloadSpeedMbps;
  final double uploadSpeedMbps;
  final int pingMs;
  final int batteryLevel; // 0 to 100
  final double batteryTemperatureC;
  final double storageUsedPercent;
  final int currentFps;

  HudMetrics({
    required this.cpuUsage,
    required this.cpuFrequencyGhz,
    required this.ramUsedGb,
    required this.ramTotalGb,
    required this.downloadSpeedMbps,
    required this.uploadSpeedMbps,
    required this.pingMs,
    required this.batteryLevel,
    required this.batteryTemperatureC,
    required this.storageUsedPercent,
    required this.currentFps,
  });

  double get ramUsagePercent => (ramUsedGb / ramTotalGb) * 100.0;
}
