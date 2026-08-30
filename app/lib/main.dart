import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/services/system_monitor_service.dart';
import 'core/services/ad_service.dart';
import 'core/theme/app_theme.dart';
import 'features/hud/screens/hud_live_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const PulseHudApp());
}

class PulseHudApp extends StatelessWidget {
  const PulseHudApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SystemMonitorService()),
        ChangeNotifierProvider(create: (_) => AdService()),
      ],
      child: MaterialApp(
        title: 'PulseHUD',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark(),
        home: const HudLiveScreen(),
      ),
    );
  }
}
