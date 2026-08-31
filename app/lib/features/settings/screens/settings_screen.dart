import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/ad_service.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final adService = Provider.of<AdService>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('SETTINGS & PRO',
            style: TextStyle(letterSpacing: 2.0, fontSize: 16)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Pro Upgrade Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF00F0FF), Color(0xFFFF007A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.workspace_premium,
                        color: Colors.white, size: 28),
                    SizedBox(width: 8),
                    Text(
                      'PULSEHUD PRO',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.5),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Unlock all futuristic HUD themes forever, 120 FPS ultra-smooth renderer, and zero ads.',
                  style:
                      TextStyle(color: Colors.white, fontSize: 13, height: 1.4),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () {
                      adService.upgradeToPro();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Upgraded to PulseHUD Pro! Thank you.'),
                          backgroundColor: Color(0xFF101B2B),
                        ),
                      );
                    },
                    child: Text(
                      adService.isProUser
                          ? 'PRO ACTIVATED'
                          : 'GET PRO - \$4.99 (ONE TIME)',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, letterSpacing: 1.2),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // About Section
          const Text('SYSTEM & LEGAL',
              style: TextStyle(
                  color: Colors.white54, fontSize: 11, letterSpacing: 1.5)),
          const SizedBox(height: 8),
          const ListTile(
            title: Text('Version'),
            trailing: Text(
                '${AppConstants.appVersion} (${AppConstants.buildNumber})',
                style: TextStyle(color: Colors.white54)),
          ),
          const ListTile(
            title: Text('Privacy Policy'),
            trailing: Icon(Icons.arrow_forward_ios, size: 14),
          ),
          const ListTile(
            title: Text('Terms of Service'),
            trailing: Icon(Icons.arrow_forward_ios, size: 14),
          ),
        ],
      ),
    );
  }
}
