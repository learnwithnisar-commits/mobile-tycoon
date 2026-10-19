import 'package:flutter/foundation.dart';
import 'game.dart';

class GameStore extends ChangeNotifier {
  Game? _game;
  Game? get game => _game;
  bool get hasGame => _game != null;

  void newGame(String name, int color) {
    _game = Game(name, color);
    notifyListeners();
  }

  void nextMonth() {
    _game?.tick();
    notifyListeners();
  }

  String? launchPhone(String name, int quality, double price) {
    final err = _game?.launchPhone(name, quality, price);
    if (err == null) notifyListeners();
    return err;
  }

  void discontinue(String id) {
    _game?.discontinue(id);
    notifyListeners();
  }

  void abandon() {
    _game = null;
    notifyListeners();
  }
}
