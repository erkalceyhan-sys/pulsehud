import 'package:flutter/foundation.dart';

class AdService extends ChangeNotifier {
  bool _isProUser = false;
  bool get isProUser => _isProUser;

  final Set<String> _unlockedThemeIds = {
    'cyberpunk_neon',
    'obsidian_minimalist'
  };
  Set<String> get unlockedThemeIds => _unlockedThemeIds;

  bool isThemeUnlocked(String themeId) {
    if (_isProUser) return true;
    return _unlockedThemeIds.contains(themeId);
  }

  void unlockThemeWithReward(String themeId) {
    _unlockedThemeIds.add(themeId);
    notifyListeners();
  }

  void upgradeToPro() {
    _isProUser = true;
    notifyListeners();
  }
}
