import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), cpu: "18%", ram: "4.2 GB", battery: "88%", network: "Wi-Fi • 45 MB/s", storage: "58 GB Free", thermal: "Nominal", isOffline: false, isCharging: false)
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = getCurrentEntry()
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let entry = getCurrentEntry()
        let nextUpdate = Calendar.current.date(byAdding: .second, value: 30, to: Date())!
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }

    private func getCurrentEntry() -> SimpleEntry {
        let userDefaults = UserDefaults(suiteName: "group.com.erkalceyhan.pulsehud")
        let cpu = userDefaults?.string(forKey: "cpuUsage") ?? "15%"
        let ram = userDefaults?.string(forKey: "ramUsage") ?? "4.2 GB"
        let battery = userDefaults?.string(forKey: "batteryLevel") ?? "88%"
        let conn = userDefaults?.string(forKey: "connectionType") ?? "Wi-Fi"
        let speed = userDefaults?.string(forKey: "networkSpeed") ?? "0.0 KB/s"
        let storage = userDefaults?.string(forKey: "storageFree") ?? "58 GB Free"
        let isOffline = conn.lowercased().contains("offline")
        let isCharging = userDefaults?.bool(forKey: "isCharging") ?? false

        return SimpleEntry(
            date: Date(),
            cpu: cpu,
            ram: ram,
            battery: battery,
            network: isOffline ? "Offline" : "\(conn) • \(speed)",
            storage: storage,
            thermal: "Nominal",
            isOffline: isOffline,
            isCharging: isCharging
        )
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let cpu: String
    let ram: String
    let battery: String
    let network: String
    let storage: String
    let thermal: String
    let isOffline: Bool
    let isCharging: Bool
}

struct PulseHudWidgetEntryView : View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var family

    var body: some View {
        switch family {
        case .systemSmall:
            SmallWidgetView(entry: entry)
        case .systemLarge:
            LargeWidgetView(entry: entry)
        case .systemMedium:
            MediumWidgetView(entry: entry)
        default:
            MediumWidgetView(entry: entry)
        }
    }
}

// --- Small Widget (2x2) ---
struct SmallWidgetView: View {
    var entry: Provider.Entry

    var body: some View {
        ZStack {
            Color(red: 0.08, green: 0.08, blue: 0.09)
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("PULSE")
                        .font(.system(size: 10, weight: .black, design: .rounded))
                        .foregroundColor(.gray)
                    Spacer()
                    Image(systemName: entry.isOffline ? "airplane" : "wifi")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(entry.isOffline ? .gray : .blue)
                }

                Spacer()

                VStack(alignment: .leading, spacing: 5) {
                    HStack {
                        Circle().fill(Color.red).frame(width: 6, height: 6)
                        Text("CPU \(entry.cpu)")
                            .font(.system(size: 12, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                    }
                    HStack {
                        Circle().fill(Color.green).frame(width: 6, height: 6)
                        Text("RAM \(entry.ram)")
                            .font(.system(size: 12, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                    }
                    HStack {
                        Circle().fill(Color.yellow).frame(width: 6, height: 6)
                        Text("BAT \(entry.battery)")
                            .font(.system(size: 12, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                    }
                }
            }
            .padding(14)
        }
        .containerBackground(for: .widget) { Color(red: 0.08, green: 0.08, blue: 0.09) }
    }
}

// --- Medium Widget (4x2) - Apple Obsidian ---
struct MediumWidgetView: View {
    var entry: Provider.Entry

    var body: some View {
        ZStack {
            Color(red: 0.08, green: 0.08, blue: 0.09)
            HStack(spacing: 16) {
                // Left: CPU & RAM Quick Badge
                VStack(spacing: 4) {
                    Text(entry.cpu)
                        .font(.system(size: 24, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                    Text("CPU LOAD")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundColor(.gray)
                }
                .frame(width: 75)

                Divider().background(Color(red: 0.2, green: 0.2, blue: 0.22))

                // Right: Wi-Fi, Memory, Battery
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Image(systemName: entry.isOffline ? "airplane" : "wifi")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(entry.isOffline ? .gray : .blue)
                        Text(entry.network)
                            .font(.system(size: 12, weight: .semibold, design: .rounded))
                            .foregroundColor(.white)
                            .lineLimit(1)
                    }

                    HStack {
                        Image(systemName: "memorychip")
                            .font(.system(size: 12))
                            .foregroundColor(.green)
                        Text("RAM: \(entry.ram)")
                            .font(.system(size: 12, weight: .semibold, design: .rounded))
                            .foregroundColor(.white)
                    }

                    HStack {
                        Image(systemName: entry.isCharging ? "battery.100.bolt" : "battery.100")
                            .font(.system(size: 12))
                            .foregroundColor(.yellow)
                        Text("\(entry.battery) • \(entry.storage)")
                            .font(.system(size: 12, weight: .semibold, design: .rounded))
                            .foregroundColor(.white)
                    }
                }
            }
            .padding(16)
        }
        .containerBackground(for: .widget) { Color(red: 0.08, green: 0.08, blue: 0.09) }
    }
}

// --- Large Widget (4x4) - Complete Hardware & Wi-Fi Cockpit ---
struct LargeWidgetView: View {
    var entry: Provider.Entry

    var body: some View {
        ZStack {
            Color(red: 0.08, green: 0.08, blue: 0.09)
            VStack(alignment: .leading, spacing: 12) {
                // Header: Wi-Fi Telemetry Bar
                HStack {
                    Text("SYSTEM COCKPIT")
                        .font(.system(size: 11, weight: .black, design: .rounded))
                        .foregroundColor(.gray)
                    Spacer()
                    HStack(spacing: 5) {
                        Image(systemName: entry.isOffline ? "airplane" : "wifi")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(entry.isOffline ? .gray : .blue)
                        Text(entry.isOffline ? "OFFLINE" : "WI-FI ACTIVE")
                            .font(.system(size: 10, weight: .bold, design: .rounded))
                            .foregroundColor(entry.isOffline ? .gray : .blue)
                    }
                }

                Divider().background(Color(red: 0.2, green: 0.2, blue: 0.22))

                // Mid 1: CPU & RAM Big Metrics
                HStack(spacing: 16) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(entry.cpu)
                            .font(.system(size: 28, weight: .black, design: .rounded))
                            .foregroundColor(.white)
                        Text("Processor Load")
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundColor(.gray)
                    }

                    Spacer()

                    VStack(alignment: .trailing, spacing: 2) {
                        Text(entry.ram)
                            .font(.system(size: 28, weight: .black, design: .rounded))
                            .foregroundColor(.green)
                        Text("Memory Active")
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundColor(.gray)
                    }
                }

                // Mid 2: Dedicated Network & Speed Card
                HStack {
                    HStack(spacing: 8) {
                        Image(systemName: entry.isOffline ? "airplane.circle.fill" : "antenna.radiowaves.left.and.right")
                            .font(.system(size: 16))
                            .foregroundColor(entry.isOffline ? .gray : .blue)
                        VStack(alignment: .leading, spacing: 1) {
                            Text(entry.network)
                                .font(.system(size: 12, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                            Text(entry.isOffline ? "No Internet Connection" : "Real-Time Throughput")
                                .font(.system(size: 9, weight: .medium))
                                .foregroundColor(.gray)
                        }
                    }
                    Spacer()
                }
                .padding(10)
                .background(Color(red: 0.12, green: 0.12, blue: 0.14))
                .cornerRadius(12)

                Spacer()

                // Bottom 2x2 Telemetry Chips
                HStack(spacing: 10) {
                    HStack {
                        Image(systemName: "battery.100")
                            .foregroundColor(.yellow)
                            .font(.system(size: 12))
                        Text(entry.battery)
                            .font(.system(size: 12, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(8)
                    .background(Color(red: 0.12, green: 0.12, blue: 0.14))
                    .cornerRadius(10)

                    HStack {
                        Image(systemName: "internaldrive")
                            .foregroundColor(.orange)
                            .font(.system(size: 12))
                        Text(entry.storage)
                            .font(.system(size: 12, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .lineLimit(1)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(8)
                    .background(Color(red: 0.12, green: 0.12, blue: 0.14))
                    .cornerRadius(10)
                }
            }
            .padding(16)
        }
        .containerBackground(for: .widget) { Color(red: 0.08, green: 0.08, blue: 0.09) }
    }
}

@main
struct PulseHudWidget: Widget {
    let kind: String = "PulseHudWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            PulseHudWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("PulseHUD System Monitor")
        .description("Live hardware telemetry, Wi-Fi speed, and battery status.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}
