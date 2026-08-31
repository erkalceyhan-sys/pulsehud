import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:battery_plus/battery_plus.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:home_widget/home_widget.dart';
import '../../features/hud/models/hud_metrics.dart';

class SystemMonitorService extends ChangeNotifier {
  late Timer _timer;
  final Random _rnd = Random();
  final Battery _battery = Battery();
  final Connectivity _connectivity = Connectivity();

  int _realBatteryLevel = 88;
  bool _isCharging = false;
  bool _isOffline = false;
  String _connectionType = '5G';

  StreamSubscription? _batterySub;
  StreamSubscription? _connectivitySub;

  HudMetrics _metrics = HudMetrics(
    cpuUsage: 18.5,
    cpuFrequencyGhz: 2.45,
    ramUsedGb: 4.1,
    ramTotalGb: 8.0,
    downloadSpeedMbps: 0.0,
    uploadSpeedMbps: 0.0,
    pingMs: 14,
    batteryLevel: 88,
    isCharging: false,
    batteryTemperatureC: 30.8,
    storageUsedPercent: 54.0,
    storageFreeGb: 58.4,
    currentFps: 60,
    isOffline: false,
    connectionType: '5G',
  );

  HudMetrics get metrics => _metrics;

  SystemMonitorService() {
    _initSensors();
    _startMonitoring();
  }

  Future<void> _initSensors() async {
    try {
      // 1. Initial Battery
      final level = await _battery.batteryLevel;
      final state = await _battery.batteryState;
      _realBatteryLevel = level.clamp(0, 100);
      _isCharging =
          state == BatteryState.charging || state == BatteryState.full;

      _batterySub = _battery.onBatteryStateChanged.listen((state) async {
        try {
          final l = await _battery.batteryLevel;
          _realBatteryLevel = l.clamp(0, 100);
          _isCharging =
              state == BatteryState.charging || state == BatteryState.full;
          notifyListeners();
        } catch (_) {}
      });
    } catch (_) {}

    try {
      // 2. Initial Connectivity
      final results = await _connectivity.checkConnectivity();
      _updateConnectivityState(results);

      _connectivitySub = _connectivity.onConnectivityChanged.listen((results) {
        _updateConnectivityState(results);
        notifyListeners();
      });
    } catch (_) {}
  }

  void _updateConnectivityState(List<ConnectivityResult> results) {
    if (results.isEmpty || results.contains(ConnectivityResult.none)) {
      _isOffline = true;
      _connectionType = 'Offline (Airplane Mode)';
    } else if (results.contains(ConnectivityResult.wifi)) {
      _isOffline = false;
      _connectionType = 'Wi-Fi';
    } else if (results.contains(ConnectivityResult.mobile)) {
      _isOffline = false;
      _connectionType = '5G / Cellular';
    } else if (results.contains(ConnectivityResult.ethernet)) {
      _isOffline = false;
      _connectionType = 'Ethernet';
    } else {
      _isOffline = true;
      _connectionType = 'Offline';
    }
  }

  void _startMonitoring() {
    _timer = Timer.periodic(const Duration(milliseconds: 1000), (timer) {
      double newCpu = (_metrics.cpuUsage + (_rnd.nextDouble() * 8.0 - 4.0))
          .clamp(6.0, 85.0);
      double newRam = (_metrics.ramUsedGb + (_rnd.nextDouble() * 0.1 - 0.05))
          .clamp(3.8, 5.2);

      double dlSpeed = 0.0;
      double ulSpeed = 0.0;
      int ping = 0;

      if (!_isOffline) {
        dlSpeed =
            (_metrics.downloadSpeedMbps + (_rnd.nextDouble() * 12.0 - 6.0))
                .clamp(12.0, 160.0);
        ulSpeed = (_metrics.uploadSpeedMbps + (_rnd.nextDouble() * 4.0 - 2.0))
            .clamp(4.0, 48.0);
        ping = (_metrics.pingMs + (_rnd.nextInt(3) - 1)).clamp(11, 28);
      }

      double newTemp = 30.5 + (newCpu / 100.0) * 4.2;

      _metrics = HudMetrics(
        cpuUsage: double.parse(newCpu.toStringAsFixed(1)),
        cpuFrequencyGhz: 2.3 + (newCpu / 100.0) * 0.9,
        ramUsedGb: double.parse(newRam.toStringAsFixed(2)),
        ramTotalGb: 8.0,
        downloadSpeedMbps: double.parse(dlSpeed.toStringAsFixed(1)),
        uploadSpeedMbps: double.parse(ulSpeed.toStringAsFixed(1)),
        pingMs: ping,
        batteryLevel: _realBatteryLevel,
        isCharging: _isCharging,
        batteryTemperatureC: double.parse(newTemp.toStringAsFixed(1)),
        storageUsedPercent: 54.0,
        storageFreeGb: 58.4,
        currentFps: 60,
        isOffline: _isOffline,
        connectionType: _connectionType,
      );

      notifyListeners();
      _syncToWidgets();
    });
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
    _batterySub?.cancel();
    _connectivitySub?.cancel();
    super.dispose();
  }
}
