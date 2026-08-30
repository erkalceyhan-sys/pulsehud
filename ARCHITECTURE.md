# ARCHITECTURE.md - PulseHUD Architecture & Implementation

## Overview
PulseHUD transforms dynamic hardware metrics (CPU load, RAM usage, live network throughput, battery temperature, storage status) into a high-performance, GPU-accelerated HUD visualizer.

## Architecture Layers
1. **Presentation (Flutter Canvas & WidgetKit):**
   - 4 High-fidelity themes: Cyberpunk Neon, Apple Obsidian Minimalist, Matrix Terminal, Arc Reactor Sci-Fi.
   - 60 FPS custom canvas painters (`CyberpunkPainter`, `ObsidianPainter`, `MatrixPainter`, `ReactorPainter`).
2. **Telemetry Service (`SystemMonitorService`):**
   - Continuous periodic sampling (1000ms interval).
   - CPU % calculation, memory pressure checks, and ping monitoring.
3. **Native Bridge (`WallpaperService`):**
   - **Android:** Native `WallpaperService` & `Engine` integration for interactive live wallpapers.
   - **iOS:** `WidgetKit` lock screen widgets and `ActivityKit` Live Activities integration.
4. **Monetization (`AdService`):**
   - Rewarded ads for unlocking themes.
   - Pro tier single-time purchase simulation.
