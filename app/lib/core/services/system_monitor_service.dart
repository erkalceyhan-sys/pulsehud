import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:home_widget/home_widget.dart';
import '../../features/hud/models/hud_metrics.dart';

class SystemMonitorService extends ChangeNotifier {
  static const MethodChannel _channel =
      MethodChannel('com.erkalceyhan.pulsehud/system_metrics');

  late Timer _timer;
  final Connectivity _connectivity = Connectivity();

  bool _isOffline = false;
  String _connectionType = '5G';
  StreamSubscription? _connectivitySub;

  HudMetrics _metrics = HudMetrics(
    cpuUsage: 0.0,
    cpuFrequencyGhz: 2.40,
    ramUsedGb: 4.0,
    ramTotalGb: 8.0,
    downloadSpeedMbps: 0.0,
    uploadSpeedMbps: 0.0,
    pingMs: 0,
    batteryLevel: 100,
    isCharging: false,
    thermalState: 'Nominal • Cool',
    storageUsedPercent: 50.0,
    storageFreeGb: 50.0,
    storageTotalGb: 128.0,
    currentFps: 60,
    isOffline: false,
    connectionType: '5G',
  );

  HudMetrics get metrics => _metrics;

  SystemMonitorService() {
    _initConnectivity();
    _startNativePolling();
  }

  Future<void> _initConnectivity() async {
    try {
      final results = await _connectivity.checkConnectivity();
      _updateConnectivity(results);

      _connectivitySub = _connectivity.onConnectivityChanged.listen((results) {
        _updateConnectivity(results);
        notifyListeners();
      });
    } catch (_) {}
  }

  void _updateConnectivity(List<ConnectivityResult> results) {
    if (results.isEmpty || results.contains(ConnectivityResult.none)) {
      _isOffline = true;
      _connectionType = 'Offline (Airplane Mode)';
    } else if (results.contains(ConnectivityResult.wifi)) {
      _isOffline = false;
      _connectionType = 'Wi-Fi';
    } else if (results.contains(ConnectivityResult.mobile)) {
      _isOffline = false;
      _connectionType = 'Cellular';
    } else if (results.contains(ConnectivityResult.ethernet)) {
      _isOffline = false;
      _connectionType = 'Ethernet';
    } else {
      _isOffline = true;
      _connectionType = 'Offline';
    }
  }

  void _startNativePolling() {
    _fetchRealNativeMetrics();
    _timer = Timer.periodic(const Duration(milliseconds: 1000), (timer) {
      _fetchRealNativeMetrics();
    });
  }

  Future<void> _fetchRealNativeMetrics() async {
    double realCpu = _metrics.cpuUsage;
    double realRamUsed = _metrics.ramUsedGb;
    double realRamTotal = _metrics.ramTotalGb;
    double realStorageFree = _metrics.storageFreeGb;
    double realStorageTotal = _metrics.storageTotalGb;
    int realBattery = _metrics.batteryLevel;
    bool realCharging = _metrics.isCharging;
    String realThermal = _metrics.thermalState;
    double realNetworkMbps = 0.0;

    try {
      final res =
          await _channel.invokeMethod<Map<dynamic, dynamic>>('getRealMetrics');
      if (res != null) {
        if (res['cpuUsage'] != null) {
          realCpu = (res['cpuUsage'] as num).toDouble().clamp(0.0, 100.0);
        }
        if (res['ramUsedGb'] != null) {
          realRamUsed = (res['ramUsedGb'] as num).toDouble();
        }
        if (res['ramTotalGb'] != null) {
          realRamTotal = (res['ramTotalGb'] as num).toDouble();
        }
        if (res['storageFreeGb'] != null) {
          realStorageFree = (res['storageFreeGb'] as num).toDouble();
        }
        if (res['storageTotalGb'] != null) {
          realStorageTotal = (res['storageTotalGb'] as num).toDouble();
        }
        if (res['batteryLevel'] != null) {
          realBattery = (res['batteryLevel'] as num).toInt();
        }
        if (res['isCharging'] != null) {
          realCharging = res['isCharging'] as bool;
        }
        if (res['thermalState'] != null) {
          realThermal = res['thermalState'] as String;
        }
        if (res['networkMbps'] != null && !_isOffline) {
          realNetworkMbps = (res['networkMbps'] as num).toDouble();
        }
      }
    } catch (_) {}

    double storageUsedPct = 50.0;
    if (realStorageTotal > 0) {
      storageUsedPct =
          ((realStorageTotal - realStorageFree) / realStorageTotal) * 100.0;
    }

    _metrics = HudMetrics(
      cpuUsage: double.parse(realCpu.toStringAsFixed(1)),
      cpuFrequencyGhz: 2.2 + (realCpu / 100.0) * 1.0,
      ramUsedGb: double.parse(realRamUsed.toStringAsFixed(2)),
      ramTotalGb: double.parse(realRamTotal.toStringAsFixed(1)),
      downloadSpeedMbps:
          _isOffline ? 0.0 : double.parse(realNetworkMbps.toStringAsFixed(2)),
      uploadSpeedMbps: 0.0,
      pingMs: _isOffline ? 0 : 12,
      batteryLevel: realBattery,
      isCharging: realCharging,
      thermalState: realThermal,
      storageUsedPercent: double.parse(storageUsedPct.toStringAsFixed(1)),
      storageFreeGb: double.parse(realStorageFree.toStringAsFixed(1)),
      storageTotalGb: double.parse(realStorageTotal.toStringAsFixed(1)),
      currentFps: 60,
      isOffline: _isOffline,
      connectionType: _connectionType,
    );

    notifyListeners();
    _syncToWidgets();
  }

  Future<void> _syncToWidgets() async {
    try {
      await HomeWidget.saveWidgetData<String>(
          'cpuUsage', '${_metrics.cpuUsage.toInt()}%');
      await HomeWidget.saveWidgetData<String>(
          'ramUsage', '${_metrics.ramUsagePercent.toInt()}%');
      await HomeWidget.saveWidgetData<String>(
          'batteryLevel', '${_metrics.batteryLevel}%');
      await HomeWidget.saveWidgetData<String>('connectionType',
          _metrics.isOffline ? 'Offline' : _metrics.connectionType);
      await HomeWidget.saveWidgetData<String>(
          'networkSpeed',
          _metrics.isOffline
              ? '0.0 KB/s'
              : '${_metrics.downloadSpeedMbps.toStringAsFixed(1)} MB/s');
      await HomeWidget.saveWidgetData<String>('storageFree',
          '${_metrics.storageFreeGb.toStringAsFixed(1)} GB Free');
      await HomeWidget.updateWidget(
        iOSName: 'PulseHudWidget',
        androidName: 'PulseHudWidget',
      );
    } catch (_) {}
  }

  @override
  void dispose() {
    _timer.cancel();
    _connectivitySub?.cancel();
    super.dispose();
  }
}
