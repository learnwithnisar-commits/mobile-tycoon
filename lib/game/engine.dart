import 'dart:math';
import 'models.dart';
import 'format.dart';

/// Marketing campaigns available to all companies.
class Campaign {
  final String name;
  final double cost;
  final double awarenessBoost;
  final String desc;
  const Campaign(this.name, this.cost, this.awarenessBoost, this.desc);
}

const List<Campaign> campaigns = [
  Campaign('Social Media Blitz', 100000, 4, 'Trending posts & influencer shoutouts'),
  Campaign('TV Ad Campaign', 500000, 10, 'Prime-time commercials nationwide'),
  Campaign('Global Launch Event', 2000000, 22, 'Keynote event streamed worldwide'),
];

const double workerWage = 2500; // per month
const double factoryUpkeepPerUnit = 1.0; // per capacity unit per month
const double factoryUpgradeCost = 2000000;
const int factoryUpgradeUnits = 100000;
const double phoneLaunchCost = 100000;
const double startCash = 10000000;
const double winValuation = 1e9;
const double winShare = 50.0;
const double bankruptBelow = -3000000;

/// Core simulation. All game rules live here.
class Engine {
  static final Random _rnd = Random();

  // ---------- static helpers ----------

  static double specScore(List<int> specs) {
    double s = 0;
    for (int i = 0; i < 5; i++) {
      s += specs[i] * techWeights[i];
    }
    return s; // max 110 at all level 10
  }

  static double unitCost(List<int> specs) {
    double c = 60;
    for (int i = 0; i < 5; i++) {
      c += pow(specs[i], 1.6) * 6;
    }
    return c;
  }

  static double phoneRating(List<int> specs, double price) {
    final q = specScore(specs) / 110; // 0..1
    final value = q * 900 / price;
    final r = 2.2 + q * 2.0 + (value - 1).clamp(-1.0, 1.0) * 1.2;
    return r.clamp(1.0, 5.0).toDouble();
  }

  static double researchCost(int fromLevel, double rdMult) =>
      200000 * pow(fromLevel, 1.7) * rdMult;

  static int researchMonths(int fromLevel) => 1 + fromLevel ~/ 3;

  static double attractiveness(Phone p, Company c) {
    final agePenalty = p.age > 18 ? pow(0.97, p.age - 18).toDouble() : 1.0;
    final brand = 0.5 + c.awareness / 100;
    return specScore(p.specs) * brand * agePenalty / pow(p.price / 400, 1.6);
  }

  static double valuationOf(Company c) {
    final techSum = c.tech.fold<int>(0, (a, b) => a + b);
    return c.cash +
        max(0, c.lastProfit) * 24 +
        techSum * 400000 +
        c.awareness * 150000 +
        c.phones.length * 500000;
  }

  // ---------- new game ----------

  static int _idSeq = 0;
  static String _newId(String prefix) => '$prefix${_idSeq++}_${_rnd.nextInt(99999)}';

  static Company _makeAi(String id, String name, int color, String personality,
      List<int> tech, double priceMargin, int capacity, int workers) {
    final c = Company(
      id: id,
      name: name,
      color: color,
      isPlayer: false,
      personality: personality,
      cash: startCash,
      tech: List<int>.from(tech),
      awareness: 18,
      capacity: capacity,
      workers: workers,
    );
    final specs = List<int>.from(tech);
    final cost = unitCost(specs);
    final price = (cost * priceMargin / 10).round() * 10 - 1;
    c.phones.add(Phone(
      id: _newId('ph'),
      name: '$name One',
      companyId: id,
      specs: specs,
      price: price.toDouble(),
      unitCost: cost,
      rating: phoneRating(specs, price.toDouble()),
    ));
    c.monthsSincePhone = 0;
    return c;
  }

  static GameState newGame(String playerName, int playerColor) {
    final player = Company(
      id: 'player',
      name: playerName,
      color: playerColor,
      isPlayer: true,
      personality: 'player',
      cash: startCash,
      tech: [2, 2, 2, 2, 2],
      awareness: 10,
      capacity: 200000,
      workers: 150,
    );
    final ai1 = _makeAi('ai1', 'VoltEdge', 0xFFB388FF, 'premium',
        [4, 4, 4, 4, 4], 1.9, 220000, 200);
    final ai2 = _makeAi('ai2', 'PocketPal', 0xFFFFB74D, 'budget',
        [2, 2, 2, 2, 2], 1.28, 350000, 300);
    final ai3 = _makeAi('ai3', 'NovaLabs', 0xFF4FC3F7, 'innovator',
        [3, 3, 3, 3, 3], 1.55, 180000, 160);
    final s = GameState(
      totalMonths: 0,
      year: 2026,
      monthOfYear: 10,
      companies: [player, ai1, ai2, ai3],
      marketSize: 600000,
    );
    _log(s, 'Welcome to Mobile Tycoon! Build your empire.');
    _log(s, 'VoltEdge, PocketPal and NovaLabs just launched phones.');
    return s;
  }

  // ---------- monthly tick ----------

  static void _log(GameState s, String msg) {
    s.log.add('${fmtDate(s.year, s.monthOfYear)} — $msg');
    if (s.log.length > 80) {
      s.log.removeRange(0, s.log.length - 80);
    }
  }

  static void tick(GameState s) {
    if (s.gameOver) return;
    // advance calendar
    s.totalMonths++;
    s.monthOfYear++;
    if (s.monthOfYear > 12) {
      s.monthOfYear = 1;
      s.year++;
    }
    // decay modifiers
    if (s.costMultMonths > 0) {
      s.costMultMonths--;
      if (s.costMultMonths == 0) s.costMult = 1.0;
    }
    if (s.demandMultMonths > 0) {
      s.demandMultMonths--;
      if (s.demandMultMonths == 0) s.demandMult = 1.0;
    }
    if (s.rdMultMonths > 0) {
      s.rdMultMonths--;
      if (s.rdMultMonths == 0) s.rdMult = 1.0;
    }

    // R&D progress
    for (final c in s.companies) {
      if (c.bankrupt) continue;
      final done = <Research>[];
      for (final r in c.rdQueue) {
        r.monthsLeft--;
        if (r.monthsLeft <= 0) {
          c.tech[r.category] = r.targetLevel;
          done.add(r);
          if (c.isPlayer) {
            _log(s,
                '${techNames[r.category]} reached level ${r.targetLevel}!');
          }
        }
      }
      c.rdQueue.removeWhere((r) => done.contains(r));
    }

    // AI decisions
    for (final c in s.companies) {
      if (!c.isPlayer && !c.bankrupt) _aiTurn(c, s);
    }

    // ---- market simulation ----
    final active =
        s.companies.where((c) => !c.bankrupt && c.phones.isNotEmpty).toList();
    final allPhones = <Phone>[];
    for (final c in active) {
      allPhones.addAll(c.phones);
    }
    final scores = <String, double>{};
    double totalScore = 0;
    for (final p in allPhones) {
      final c = active.firstWhere((e) => e.id == p.companyId);
      final sc = attractiveness(p, c);
      scores[p.id] = sc;
      totalScore += sc;
    }

    int totalUnits = 0;
    final demandOf = <String, double>{};
    if (totalScore > 0) {
      for (final p in allPhones) {
        demandOf[p.id] =
            scores[p.id]! / totalScore * s.marketSize * s.demandMult;
      }
    }
    for (final c in active) {
      double companyDemand = 0;
      for (final p in c.phones) {
        companyDemand += demandOf[p.id] ?? 0;
      }
      final prodCap = c.effectiveCapacity.toDouble();
      double revenue = 0, cogs = 0;
      int units = 0;
      for (final p in c.phones) {
        final d = demandOf[p.id] ?? 0;
        final alloc =
            companyDemand > 0 ? prodCap * d / companyDemand : 0;
        final sold = min(d, alloc).toInt();
        p.sold = sold;
        p.age++;
        revenue += sold * p.price;
        cogs += sold * p.unitCost * s.costMult;
        units += sold;
        totalUnits += sold;
      }
      final wages = c.workers * workerWage;
      final overhead = c.capacity * factoryUpkeepPerUnit;
      final cost = cogs + wages + overhead;
      final profit = revenue - cost;
      c.cash += profit;
      c.lastRevenue = revenue;
      c.lastCost = cost;
      c.lastProfit = profit;
      c.lastUnits = units;
      c.marketShare =
          totalUnits > 0 ? units / totalUnits * 100 : 0.0;
      // age out ancient phones for AI
      if (!c.isPlayer) {
        c.phones.removeWhere((p) => p.age > 24 && c.phones.length > 1);
      }
      c.awareness = max(0.0, c.awareness - 1.5);
      if (c.cash < bankruptBelow && !c.bankrupt) {
        c.bankrupt = true;
        _log(s, '${c.name} went BANKRUPT!');
      }
      c.valuation = valuationOf(c);
    }

    // market growth
    s.marketSize *= 1.004;

    // random event
    if (_rnd.nextDouble() < 0.25) _randomEvent(s);

    // history (player)
    final pl = s.player;
    s.revenueHist.add(pl.lastRevenue);
    s.shareHist.add(pl.marketShare);
    if (s.revenueHist.length > 24) s.revenueHist.removeAt(0);
    if (s.shareHist.length > 24) s.shareHist.removeAt(0);

    // win / lose
    if (!pl.bankrupt &&
        (pl.valuation >= winValuation || pl.marketShare >= winShare)) {
      s.gameOver = true;
      s.won = true;
      s.endReason = 'You built a \$1B empire!';
      _log(s, 'VICTORY! ${pl.name} dominates the mobile world.');
    } else if (pl.bankrupt) {
      s.gameOver = true;
      s.won = false;
      s.endReason = 'Your company went bankrupt.';
    }
  }

  // ---------- AI ----------

  static void _aiTurn(Company c, GameState s) {
    c.monthsSincePhone++;
    // R&D
    if (c.rdQueue.isEmpty) {
      final chance = c.personality == 'innovator' ? 0.7 : 0.35;
      if (_rnd.nextDouble() < chance) {
        final candidates = <int>[];
        for (int i = 0; i < 5; i++) {
          if (c.tech[i] < 10) candidates.add(i);
        }
        if (candidates.isNotEmpty) {
          final cat = candidates[_rnd.nextInt(candidates.length)];
          final cost = researchCost(c.tech[cat], s.rdMult);
          if (c.cash > cost * 2.5) {
            c.cash -= cost;
            c.rdQueue.add(Research(
              category: cat,
              targetLevel: c.tech[cat] + 1,
              monthsLeft: researchMonths(c.tech[cat]),
              totalMonths: researchMonths(c.tech[cat]),
              cost: cost,
            ));
          }
        }
      }
    }
    // new phone
    final interval =
        c.personality == 'premium' ? 7 : c.personality == 'budget' ? 5 : 6;
    if (c.monthsSincePhone >= interval && c.cash > 800000) {
      final margin = c.personality == 'premium'
          ? 1.9
          : c.personality == 'budget'
              ? 1.28
              : 1.55;
      final specs = List<int>.from(c.tech);
      final cost = unitCost(specs);
      final price = (cost * margin / 10).round() * 10 - 1;
      c.phoneSerial++;
      final series = c.personality == 'premium'
          ? 'X'
          : c.personality == 'budget'
              ? 'Go'
              : 'Nova';
      final name = '${c.name} $series${c.phoneSerial}';
      c.phones.add(Phone(
        id: _newId('ph'),
        name: name,
        companyId: c.id,
        specs: specs,
        price: price.toDouble(),
        unitCost: cost,
        rating: phoneRating(specs, price.toDouble()),
      ));
      c.monthsSincePhone = 0;
      if (c.phones.length > 4) c.phones.removeAt(0);
      _log(s, '${c.name} launched $name at ${fmtMoney(price.toDouble())}.');
    }
    // marketing
    final targetAware =
        c.personality == 'premium' ? 60 : c.personality == 'budget' ? 45 : 50;
    if (c.awareness < targetAware - 10 && c.cash > 3000000) {
      Campaign? pick;
      for (final camp in campaigns.reversed) {
        if (c.cash > camp.cost * 3) {
          pick = camp;
          break;
        }
      }
      pick ??= campaigns.first;
      c.cash -= pick.cost;
      c.awareness = min(100.0, c.awareness + pick.awarenessBoost);
    }
    // factory & workers
    final targetWorkers = c.capacity ~/ 1000;
    if (c.workers < (targetWorkers * 0.9).toInt() && c.cash > 1000000) {
      c.workers = min(targetWorkers, c.workers + 40);
    }
    if (c.cash > 5000000 && _rnd.nextDouble() < 0.25) {
      c.cash -= factoryUpgradeCost;
      c.capacity += factoryUpgradeUnits;
      c.workers += 60;
    }
    // price tweak toward margin
    final margin = c.personality == 'premium'
        ? 1.9
        : c.personality == 'budget'
            ? 1.28
            : 1.55;
    for (final p in c.phones) {
      if (_rnd.nextDouble() < 0.25) {
        final target = p.unitCost * margin;
        final np = p.price + (target - p.price) * 0.3;
        p.price = max(p.unitCost * 1.05, np);
      }
    }
  }

  // ---------- events ----------

  static void _randomEvent(GameState s) {
    final roll = _rnd.nextInt(6);
    final candidates =
        s.companies.where((c) => !c.bankrupt).toList();
    if (candidates.isEmpty) return;
    final lucky = candidates[_rnd.nextInt(candidates.length)];
    switch (roll) {
      case 0:
        lucky.awareness = min(100.0, lucky.awareness + 10);
        _log(s, 'Viral review! ${lucky.name} gains buzz (+awareness).');
        break;
      case 1:
        s.costMult = 1.2;
        s.costMultMonths = 3;
        _log(s, 'Supply shortage! Component costs +20% for 3 months.');
        break;
      case 2:
        s.rdMult = 0.7;
        s.rdMultMonths = 3;
        _log(s, 'Tech breakthrough! Research costs -30% for 3 months.');
        break;
      case 3:
        s.demandMult = 1.15;
        s.demandMultMonths = 3;
        _log(s, 'Economic boom! Market demand +15% for 3 months.');
        break;
      case 4:
        s.costMult = 0.85;
        s.costMultMonths = 3;
        _log(s, 'Component price drop! Costs -15% for 3 months.');
        break;
      case 5:
        lucky.awareness = max(0.0, lucky.awareness - 12);
        _log(s, 'Bad press hits ${lucky.name} (-awareness).');
        break;
    }
  }

  // ---------- player actions (validated) ----------

  static String? startResearch(GameState s, int category) {
    final c = s.player;
    if (c.bankrupt) return 'Bankrupt!';
    if (c.tech[category] >= 10) return 'Already max level';
    if (c.rdQueue.any((r) => r.category == category)) {
      return 'Already researching';
    }
    final cost = researchCost(c.tech[category], s.rdMult);
    if (c.cash < cost) return 'Not enough cash';
    c.cash -= cost;
    final months = researchMonths(c.tech[category]);
    c.rdQueue.add(Research(
      category: category,
      targetLevel: c.tech[category] + 1,
      monthsLeft: months,
      totalMonths: months,
      cost: cost,
    ));
    return null;
  }

  static String? releasePhone(
      GameState s, String name, List<int> specs, double price) {
    final c = s.player;
    if (c.bankrupt) return 'Bankrupt!';
    if (name.trim().isEmpty) return 'Name your phone';
    if (c.cash < phoneLaunchCost) return 'Need ${fmtMoney(phoneLaunchCost)}';
    for (int i = 0; i < 5; i++) {
      if (specs[i] > c.tech[i]) return 'Tech not researched';
      if (specs[i] < 1) return 'Invalid spec';
    }
    final cost = unitCost(specs);
    if (price < cost * 1.02) return 'Price below cost!';
    c.cash -= phoneLaunchCost;
    c.phones.add(Phone(
      id: _newId('ph'),
      name: name.trim(),
      companyId: c.id,
      specs: List<int>.from(specs),
      price: price,
      unitCost: cost,
      rating: phoneRating(specs, price),
    ));
    c.monthsSincePhone = 0;
    _log(s, '${c.name} launched $name at ${fmtMoney(price)}!');
    return null;
  }

  static String? runCampaign(GameState s, Campaign camp) {
    final c = s.player;
    if (c.bankrupt) return 'Bankrupt!';
    if (c.cash < camp.cost) return 'Not enough cash';
    c.cash -= camp.cost;
    c.awareness = min(100.0, c.awareness + camp.awarenessBoost);
    _log(s, '${c.name} ran "${camp.name}" (+${camp.awarenessBoost} awareness).');
    return null;
  }

  static String? hireWorkers(GameState s, int n) {
    final c = s.player;
    if (c.bankrupt) return 'Bankrupt!';
    if (n > 0) {
      c.workers += n;
    } else {
      if (c.workers + n < 10) return 'Keep at least 10 workers';
      c.workers += n;
    }
    return null;
  }

  static String? upgradeFactory(GameState s) {
    final c = s.player;
    if (c.bankrupt) return 'Bankrupt!';
    if (c.cash < factoryUpgradeCost) return 'Not enough cash';
    c.cash -= factoryUpgradeCost;
    c.capacity += factoryUpgradeUnits;
    _log(s, 'Factory expanded to ${fmtUnits(c.capacity)} units/month.');
    return null;
  }

  static void discontinuePhone(GameState s, String phoneId) {
    s.player.phones.removeWhere((p) => p.id == phoneId);
  }
}
