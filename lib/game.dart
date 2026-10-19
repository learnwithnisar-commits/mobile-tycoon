import 'dart:math';

final _rnd = Random();
int _idSeq = 0;
String _uid(String p) => '$p${_idSeq++}';

const List<String> monthNames = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];

String fmtMoney(double v) {
  final neg = v < 0;
  final a = v.abs();
  final s = a >= 1e9
      ? '\$${(a / 1e9).toStringAsFixed(2)}B'
      : a >= 1e6
          ? '\$${(a / 1e6).toStringAsFixed(2)}M'
          : a >= 1e3
              ? '\$${(a / 1e3).toStringAsFixed(1)}K'
              : '\$${a.toStringAsFixed(0)}';
  return neg ? '-$s' : s;
}

String fmtUnits(int v) => v >= 1000000
    ? '${(v / 1000000).toStringAsFixed(1)}M'
    : v >= 1000
        ? '${(v / 1000).toStringAsFixed(0)}K'
        : '$v';

double unitCostFor(int quality) => 50 + pow(quality, 1.8) * 8;

class Phone {
  final String id;
  final String name;
  final String ownerId;
  final int quality; // 1..10
  double price;
  final double unitCost;
  int sold = 0;

  Phone({
    required this.id,
    required this.name,
    required this.ownerId,
    required this.quality,
    required this.price,
    required this.unitCost,
  });

  double get margin => price - unitCost;
}

class Company {
  final String id;
  final String name;
  final int color;
  final bool isPlayer;
  double cash;
  final List<Phone> phones = [];
  double share = 0;
  double lastRevenue = 0;
  double lastProfit = 0;
  int lastUnits = 0;
  int monthsSinceLaunch = 0;

  Company({
    required this.id,
    required this.name,
    required this.color,
    required this.isPlayer,
    required this.cash,
  });
}

class Game {
  int year = 2026;
  int month = 10;
  int totalMonths = 0;
  late final Company player;
  late final Company ai;
  final List<String> log = [];
  bool gameOver = false;
  bool won = false;
  String endReason = '';
  double marketSize = 150000;

  Game(String playerName, int color) {
    player = Company(
        id: 'p', name: playerName, color: color, isPlayer: true, cash: 1e7);
    ai = Company(
        id: 'ai',
        name: 'VoltEdge',
        color: 0xFFB388FF,
        isPlayer: false,
        cash: 1e7);
    _aiLaunch(initial: true);
    _addLog('Welcome! Build phones, beat VoltEdge.');
  }

  String get dateLabel => '${monthNames[month - 1]} $year';

  void _addLog(String msg) {
    log.add('$dateLabel — $msg');
    if (log.length > 60) log.removeRange(0, log.length - 60);
  }

  double _attract(Phone ph) =>
      ph.quality * 12 / pow(ph.price / 300, 1.5).toDouble();

  void _aiLaunch({bool initial = false}) {
    final q = min(8, 3 + totalMonths ~/ 12);
    final cost = unitCostFor(q);
    final price = ((cost * 1.5 / 10).round() * 10 - 1).toDouble();
    ai.monthsSinceLaunch = 0;
    final n = ai.phones.length + 1;
    ai.phones.add(Phone(
        id: _uid('a'),
        name: 'Volt V$n',
        ownerId: ai.id,
        quality: q,
        price: price,
        unitCost: cost));
    if (ai.phones.length > 3) ai.phones.removeAt(0);
    if (!initial) _addLog('VoltEdge launched Volt V$n at ${fmtMoney(price)}.');
  }

  void _aiAct() {
    ai.monthsSinceLaunch++;
    for (final ph in ai.phones) {
      if (_rnd.nextDouble() < 0.3) {
        final target = ph.unitCost * 1.5;
        ph.price = ph.price + (target - ph.price) * 0.4;
      }
    }
    if (ai.monthsSinceLaunch >= 4) _aiLaunch();
  }

  void tick() {
    if (gameOver) return;
    totalMonths++;
    month++;
    if (month > 12) {
      month = 1;
      year++;
    }
    _aiAct();

    final all = [...player.phones, ...ai.phones];
    if (all.isEmpty) {
      for (final c in [player, ai]) {
        c.lastRevenue = 0;
        c.lastProfit = 0;
        c.lastUnits = 0;
        c.share = 0;
      }
    } else {
      final scores = <String, double>{};
      double total = 0;
      for (final ph in all) {
        final s = _attract(ph);
        scores[ph.id] = s;
        total += s;
      }
      int totalUnits = 0;
      final unitsOf = <String, int>{};
      for (final ph in all) {
        final u = (scores[ph.id]! / total * marketSize).toInt();
        unitsOf[ph.id] = u;
        totalUnits += u;
      }
      for (final c in [player, ai]) {
        double rev = 0, cost = 0;
        int units = 0;
        for (final ph in c.phones) {
          final u = unitsOf[ph.id] ?? 0;
          ph.sold = u;
          rev += u * ph.price;
          cost += u * ph.unitCost;
          units += u;
        }
        c.lastRevenue = rev;
        c.lastProfit = rev - cost;
        c.lastUnits = units;
        c.cash += c.lastProfit;
        c.share = totalUnits > 0 ? units / totalUnits * 100 : 0.0;
      }
    }
    marketSize *= 1.003;

    if (player.cash >= 1e8) {
      gameOver = true;
      won = true;
      endReason = 'You built a \$100M company!';
      _addLog('VICTORY! ${player.name} is worth ${fmtMoney(player.cash)}.');
    } else if (player.cash < 0) {
      gameOver = true;
      won = false;
      endReason = 'Your company went bankrupt.';
    }
  }

  String? launchPhone(String name, int quality, double price) {
    if (name.trim().isEmpty) return 'Name your phone';
    final cost = unitCostFor(quality);
    if (price < cost * 1.05) return 'Price below cost (${fmtMoney(cost)})';
    if (player.cash < 50000) return 'Need ${fmtMoney(50000)} launch cost';
    player.cash -= 50000;
    player.phones.add(Phone(
        id: _uid('p'),
        name: name.trim(),
        ownerId: player.id,
        quality: quality,
        price: price,
        unitCost: cost));
    _addLog('${player.name} launched ${name.trim()} at ${fmtMoney(price)}!');
    return null;
  }

  void discontinue(String id) =>
      player.phones.removeWhere((p) => p.id == id);
}
