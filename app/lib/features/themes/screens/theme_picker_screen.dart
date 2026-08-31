import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/services/ad_service.dart';
import '../../hud/models/hud_theme_config.dart';

class ThemePickerScreen extends StatelessWidget {
  const ThemePickerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final adService = Provider.of<AdService>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('HUD THEMES',
            style: TextStyle(letterSpacing: 2.0, fontSize: 16)),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: HudThemeConfig.availableThemes.length,
        itemBuilder: (context, index) {
          final theme = HudThemeConfig.availableThemes[index];
          final isUnlocked = adService.isThemeUnlocked(theme.id);

          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: const Color(0xFF121B2F),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: theme.primaryAccent.withValues(alpha: 0.5),
                  width: 1.5),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: theme.backgroundColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: theme.primaryAccent, width: 2),
                ),
                child: Icon(Icons.speed, color: theme.primaryAccent),
              ),
              title: Text(
                theme.title,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  theme.description,
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                ),
              ),
              trailing: isUnlocked
                  ? ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.primaryAccent,
                        foregroundColor: Colors.black,
                      ),
                      onPressed: () => Navigator.pop(context, theme),
                      child: const Text('SELECT',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    )
                  : OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFFFD700),
                        side: const BorderSide(color: Color(0xFFFFD700)),
                      ),
                      icon: const Icon(Icons.play_circle_outline, size: 16),
                      label: const Text('UNLOCK'),
                      onPressed: () {
                        adService.unlockThemeWithReward(theme.id);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content:
                                Text('${theme.title} unlocked for 24 hours!'),
                            backgroundColor: const Color(0xFF101B2B),
                          ),
                        );
                      },
                    ),
            ),
          );
        },
      ),
    );
  }
}
