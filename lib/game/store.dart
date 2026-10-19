import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'models.dart';
import 'engine.dart';

const String _saveKey = 'mobile_tycoon_save_v1';

/// App-wide game state holder.
class GameStore extends ChangeNotifier {
  GameState? _state;
  bool _loaded = false;

  GameState? get state => _state;
  bool get hasGame => _state != null;
  bool get loaded => _loaded;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_saveKey);
    if (raw != null) {
      try {
        _state = GameState.fromJson(
            jsonDecode(raw) as Map<String, dynamic>);
      } catch (_) {
        _state = null;
      }
    }
    _loaded = true;
    notifyListeners();
  }

  Future<void> _persist() async {
    final s = _state;
    if (s == null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_saveKey, jsonEncode(s.toJson()));
  }

  Future<void> clearSave() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_saveKey);
  }

  void newGame(String name, int color) {
    _state = Engine.newGame(name, color);
    _persist();
    notifyListeners();
  }

  void _refresh() {
    _persist();
    notifyListeners();
  }

  // ---- actions ----

  String? nextMonth() {
    final s = _state;
    if (s == null || s.gameOver) return null;
    Engine.tick(s);
    _refresh();
    return null;
  }

  String? startResearch(int category) {
    final s = _state;
    if (s == null) return 'No game';
    final err = Engine.startResearch(s, category);
    if (err == null) _refresh();
    return err;
  }

  String? releasePhone(String name, List<int> specs, double price) {
    final s = _state;
    if (s == null) return 'No game';
    final err = Engine.releasePhone(s, name, specs, price);
    if (err == null) _refresh();
    return err;
  }

  String? runCampaign(Campaign camp) {
    final s = _state;
    if (s == null) return 'No game';
    final err = Engine.runCampaign(s, camp);
    if (err == null) _refresh();
    return err;
  }

  String? hireWorkers(int n) {
    final s = _state;
    if (s == null) return 'No game';
    final err = Engine.hireWorkers(s, n);
    if (err == null) _refresh();
    return err;
  }

  String? upgradeFactory() {
    final s = _state;
    if (s == null) return 'No game';
    final err = Engine.upgradeFactory(s);
    if (err == null) _refresh();
    return err;
  }

  void discontinuePhone(String phoneId) {
    final s = _state;
    if (s == null) return;
    Engine.discontinuePhone(s, phoneId);
    _refresh();
  }

  void abandonRun() {
    _state = null;
    clearSave();
    notifyListeners();
  }
}
