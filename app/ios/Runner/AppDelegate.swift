import Flutter
import UIKit
import MachO
import SystemConfiguration

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  private var prevCpuInfo: host_cpu_load_info?

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    UIDevice.current.isBatteryMonitoringEnabled = true

    let controller: FlutterViewController = window?.rootViewController as! FlutterViewController
    let metricsChannel = FlutterMethodChannel(
      name: "com.erkalceyhan.pulsehud/system_metrics",
      binaryMessenger: controller.binaryMessenger
    )

    metricsChannel.setMethodCallHandler { [weak self] (call, result) in
      guard let self = self else { return }
      if call.method == "getRealMetrics" {
        result(self.collectRealSystemMetrics())
      } else {
        result(FlutterMethodNotImplemented)
      }
    }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
  }

  private func collectRealSystemMetrics() -> [String: Any] {
    // 1. Real Mach CPU Load
    let cpuUsage = getRealCpuUsage()

    // 2. Real Mach RAM Load
    let (ramUsedGb, ramTotalGb) = getRealMemoryUsage()

    // 3. Real Disk Storage
    let (storageFreeGb, storageTotalGb) = getRealStorageUsage()

    // 4. Real Battery
    let batteryLevel = Int(max(0, UIDevice.current.batteryLevel * 100))
    let isCharging = UIDevice.current.batteryState == .charging || UIDevice.current.batteryState == .full

    // 5. Hardware Info
    let coreCount = ProcessInfo.processInfo.activeProcessorCount

    return [
      "cpuUsage": cpuUsage,
      "coreCount": coreCount,
      "ramUsedGb": ramUsedGb,
      "ramTotalGb": ramTotalGb,
      "storageFreeGb": storageFreeGb,
      "storageTotalGb": storageTotalGb,
      "batteryLevel": batteryLevel >= 0 ? batteryLevel : 100,
      "isCharging": isCharging
    ]
  }

  private func getRealCpuUsage() -> Double {
    var cpuInfo = host_cpu_load_info()
    var count = mach_msg_type_number_t(MemoryLayout<host_cpu_load_info>.size / MemoryLayout<integer_t>.size)
    
    let kerr = withUnsafeMutablePointer(to: &cpuInfo) {
      $0.withMemoryRebound(to: integer_t.self, capacity: Int(count)) {
        host_statistics(mach_host_self(), HOST_CPU_LOAD_INFO, $0, &count)
      }
    }

    guard kerr == KERN_SUCCESS else { return 0.0 }

    guard let prev = prevCpuInfo else {
      prevCpuInfo = cpuInfo
      return 0.0
    }

    let user = Double(cpuInfo.cpu_ticks.0 - prev.cpu_ticks.0)
    let system = Double(cpuInfo.cpu_ticks.1 - prev.cpu_ticks.1)
    let idle = Double(cpuInfo.cpu_ticks.2 - prev.cpu_ticks.2)
    let nice = Double(cpuInfo.cpu_ticks.3 - prev.cpu_ticks.3)

    prevCpuInfo = cpuInfo

    let total = user + system + idle + nice
    if total <= 0 { return 0.0 }

    let used = user + system + nice
    return (used / total) * 100.0
  }

  private func getRealMemoryUsage() -> (Double, Double) {
    var stats = vm_statistics64()
    var count = mach_msg_type_number_t(MemoryLayout<vm_statistics64>.size / MemoryLayout<integer_t>.size)

    let kerr = withUnsafeMutablePointer(to: &stats) {
      $0.withMemoryRebound(to: integer_t.self, capacity: Int(count)) {
        host_statistics64(mach_host_self(), HOST_VM_INFO64, $0, &count)
      }
    }

    let totalBytes = Double(ProcessInfo.processInfo.physicalMemory)
    let totalGb = totalBytes / (1024 * 1024 * 1024)

    guard kerr == KERN_SUCCESS else { return (0.0, totalGb) }

    let pageSize = Double(vm_kernel_page_size)
    let active = Double(stats.active_count) * pageSize
    let wire = Double(stats.wire_count) * pageSize
    let compressed = Double(stats.compressor_page_count) * pageSize
    let usedBytes = active + wire + compressed
    let usedGb = usedBytes / (1024 * 1024 * 1024)

    return (usedGb, totalGb)
  }

  private func getRealStorageUsage() -> (Double, Double) {
    do {
      let url = URL(fileURLWithPath: NSHomeDirectory())
      let values = try url.resourceValues(forKeys: [.volumeAvailableCapacityForImportantUsageKey, .volumeTotalCapacityKey])
      let freeBytes = Double(values.volumeAvailableCapacityForImportantUsage ?? 0)
      let totalBytes = Double(values.volumeTotalCapacity ?? 0)

      let freeGb = freeBytes / (1024 * 1024 * 1024)
      let totalGb = totalBytes / (1024 * 1024 * 1024)
      return (freeGb, totalGb)
    } catch {
      return (0.0, 0.0)
    }
  }
}
