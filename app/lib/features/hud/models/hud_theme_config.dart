import 'package:flutter/material.dart';

enum HudThemeType {
  cyberpunkNeon,
  obsidianMinimalist,
  matrixTerminal,
  sciFiReactor,
}

class HudThemeConfig {
  final String id;
  final String title;
  final String description;
  final HudThemeType type;
  final bool isPremium;
  final Color primaryAccent;
  final Color secondaryAccent;
  final Color backgroundColor;

  const HudThemeConfig({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    this.isPremium = false,
    required this.primaryAccent,
    required this.secondaryAccent,
    required this.backgroundColor,
  });

  static const List<HudThemeConfig> availableThemes = [
    HudThemeConfig(
      id: 'cyberpunk_neon',
      title: 'Cyberpunk Neon',
      description: 'Futuristic glowing neon HUD with high-frequency waveforms.',
      type: HudThemeType.cyberpunkNeon,
      isPremium: false,
      primaryAccent: Color(0xFF00F0FF),
      secondaryAccent: Color(0xFFFF007A),
      backgroundColor: Color(0xFF070B14),
    ),
    HudThemeConfig(
      id: 'obsidian_minimalist',
      title: 'Obsidian Minimalist',
      description: 'Pure Apple-grade OLED black with subtle high-contrast gauges.',
      type: HudThemeType.obsidianMinimalist,
      isPremium: false,
      primaryAccent: Color(0xFFFFFFFF),
      secondaryAccent: Color(0xFF8E8E93),
      backgroundColor: Color(0xFF000000),
    ),
    HudThemeConfig(
      id: 'matrix_terminal',
      title: 'Matrix Terminal',
      description: 'Cascading digital rain with raw real-time Linux kernel telemetry.',
      type: HudThemeType.matrixTerminal,
      isPremium: true,
      primaryAccent: Color(0xFF00FF66),
      secondaryAccent: Color(0xFF008F11),
      backgroundColor: Color(0xFF020D04),
    ),
    HudThemeConfig(
      id: 'scifi_reactor',
      title: 'Arc Reactor Sci-Fi',
      description: 'Central rotating energy core reacting dynamically to CPU load.',
      type: HudThemeType.sciFiReactor,
      isPremium: true,
      primaryAccent: Color(0xFF00E5FF),
      secondaryAccent: Color(0xFFFF9100),
      backgroundColor: Color(0xFF050E18),
    ),
  ];
}
