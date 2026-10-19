/// Data models for Mobile Tycoon. All JSON-serializable for save/load.

const List<String> techNames = [
  'Processor',
  'Camera',
  'Battery',
  'Display',
  'Design',
];

const List<String> techIcons = ['cpu', 'camera', 'battery', 'display', 'design'];

/// Relative importance of each tech category in phone attractiveness.
const List<double> techWeights = [3.0, 2.5, 2.0, 2.0, 1.5];

class Research {
  int category; // 0..4
  int targetLevel; // 1..10
  int monthsLeft;
  int totalMonths;
  double cost;

  Research({
    required this.category,
    required this.targetLevel,
    required this.monthsLeft,
    required this.totalMonths,
    required this.cost,
  });

  Map<String, dynamic> toJson() => {
        'category': category,
        'targetLevel': targetLevel,
        'monthsLeft': monthsLeft,
        'totalMonths': totalMonths,
        'cost': cost,
      };

  factory Research.fromJson(Map<String, dynamic> j) => Research(
        category: (j['category'] as num).toInt(),
        targetLevel: (j['targetLevel'] as num).toInt(),
        monthsLeft: (j['monthsLeft'] as num).toInt(),
        totalMonths: (j['totalMonths'] as num).toInt(),
        cost: (j['cost'] as num).toDouble(),
      );
}

class Phone {
  String id;
  String name;
  String companyId;
  List<int> specs; // 5 tech levels
  double price;
  double unitCost;
  int sold; // units sold last month
  double rating; // 0..5
  int age; // months on market

  Phone({
    required this.id,
    required this.name,
    required this.companyId,
    required this.specs,
    required this.price,
    required this.unitCost,
    this.sold = 0,
    this.rating = 3.0,
    this.age = 0,
  });

  double get margin => price - unitCost;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'companyId': companyId,
        'specs': specs,
        'price': price,
        'unitCost': unitCost,
        'sold': sold,
        'rating': rating,
        'age': age,
      };

  factory Phone.fromJson(Map<String, dynamic> j) => Phone(
        id: j['id'] as String,
        name: j['name'] as String,
        companyId: j['companyId'] as String,
        specs: (j['specs'] as List).map((e) => (e as num).toInt()).toList(),
        price: (j['price'] as num).toDouble(),
        unitCost: (j['unitCost'] as num).toDouble(),
        sold: (j['sold'] as num).toInt(),
        rating: (j['rating'] as num).toDouble(),
        age: (j['age'] as num).toInt(),
      );
}

class Company {
  String id;
  String name;
  int color; // ARGB int
  bool isPlayer;
  String personality; // 'player', 'premium', 'budget', 'innovator'
  double cash;
  List<int> tech; // 5 levels, 1..10
  double awareness; // 0..100
  List<Phone> phones;
  int capacity; // factory units per month
  int workers;
  List<Research> rdQueue;
  bool bankrupt;
  int monthsSincePhone;
  int phoneSerial;
  // last-month finance
  double lastRevenue;
  double lastCost;
  double lastProfit;
  int lastUnits;
  double marketShare; // 0..100 last month
  double valuation;

  Company({
    required this.id,
    required this.name,
    required this.color,
    required this.isPlayer,
    required this.personality,
    required this.cash,
    required this.tech,
    this.awareness = 10,
    List<Phone>? phones,
    this.capacity = 200000,
    this.workers = 150,
    List<Research>? rdQueue,
    this.bankrupt = false,
    this.monthsSincePhone = 0,
    this.phoneSerial = 1,
    this.lastRevenue = 0,
    this.lastCost = 0,
    this.lastProfit = 0,
    this.lastUnits = 0,
    this.marketShare = 0,
    this.valuation = 0,
  })  : phones = phones ?? [],
        rdQueue = rdQueue ?? [];

  int get effectiveCapacity {
    final byWorkers = workers * 1000;
    return capacity < byWorkers ? capacity : byWorkers;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'color': color,
        'isPlayer': isPlayer,
        'personality': personality,
        'cash': cash,
        'tech': tech,
        'awareness': awareness,
        'phones': phones.map((p) => p.toJson()).toList(),
        'capacity': capacity,
        'workers': workers,
        'rdQueue': rdQueue.map((r) => r.toJson()).toList(),
        'bankrupt': bankrupt,
        'monthsSincePhone': monthsSincePhone,
        'phoneSerial': phoneSerial,
        'lastRevenue': lastRevenue,
        'lastCost': lastCost,
        'lastProfit': lastProfit,
        'lastUnits': lastUnits,
        'marketShare': marketShare,
        'valuation': valuation,
      };

  factory Company.fromJson(Map<String, dynamic> j) => Company(
        id: j['id'] as String,
        name: j['name'] as String,
        color: (j['color'] as num).toInt(),
        isPlayer: j['isPlayer'] as bool,
        personality: j['personality'] as String,
        cash: (j['cash'] as num).toDouble(),
        tech: (j['tech'] as List).map((e) => (e as num).toInt()).toList(),
        awareness: (j['awareness'] as num).toDouble(),
        phones: (j['phones'] as List)
            .map((e) => Phone.fromJson(e as Map<String, dynamic>))
            .toList(),
        capacity: (j['capacity'] as num).toInt(),
        workers: (j['workers'] as num).toInt(),
        rdQueue: (j['rdQueue'] as List)
            .map((e) => Research.fromJson(e as Map<String, dynamic>))
            .toList(),
        bankrupt: j['bankrupt'] as bool,
        monthsSincePhone: (j['monthsSincePhone'] as num).toInt(),
        phoneSerial: (j['phoneSerial'] as num).toInt(),
        lastRevenue: (j['lastRevenue'] as num).toDouble(),
        lastCost: (j['lastCost'] as num).toDouble(),
        lastProfit: (j['lastProfit'] as num).toDouble(),
        lastUnits: (j['lastUnits'] as num?)?.toInt() ?? 0,
        marketShare: (j['marketShare'] as num).toDouble(),
        valuation: (j['valuation'] as num).toDouble(),
      );
}

class GameState {
  int totalMonths;
  int year;
  int monthOfYear; // 1..12
  List<Company> companies;
  double marketSize; // units per month
  List<String> log; // recent event messages, newest last
  List<double> revenueHist; // player monthly revenue history
  List<double> shareHist; // player market share history
  double costMult; // modifier: unit cost multiplier
  int costMultMonths;
  double demandMult; // modifier: market demand multiplier
  int demandMultMonths;
  double rdMult; // modifier: research cost multiplier
  int rdMultMonths;
  bool gameOver;
  bool won;
  String endReason;

  GameState({
    required this.totalMonths,
    required this.year,
    required this.monthOfYear,
    required this.companies,
    required this.marketSize,
    List<String>? log,
    List<double>? revenueHist,
    List<double>? shareHist,
    this.costMult = 1.0,
    this.costMultMonths = 0,
    this.demandMult = 1.0,
    this.demandMultMonths = 0,
    this.rdMult = 1.0,
    this.rdMultMonths = 0,
    this.gameOver = false,
    this.won = false,
    this.endReason = '',
  })  : log = log ?? [],
        revenueHist = revenueHist ?? [],
        shareHist = shareHist ?? [];

  Company get player => companies.firstWhere((c) => c.isPlayer);

  Map<String, dynamic> toJson() => {
        'totalMonths': totalMonths,
        'year': year,
        'monthOfYear': monthOfYear,
        'companies': companies.map((c) => c.toJson()).toList(),
        'marketSize': marketSize,
        'log': log,
        'revenueHist': revenueHist,
        'shareHist': shareHist,
        'costMult': costMult,
        'costMultMonths': costMultMonths,
        'demandMult': demandMult,
        'demandMultMonths': demandMultMonths,
        'rdMult': rdMult,
        'rdMultMonths': rdMultMonths,
        'gameOver': gameOver,
        'won': won,
        'endReason': endReason,
      };

  factory GameState.fromJson(Map<String, dynamic> j) => GameState(
        totalMonths: (j['totalMonths'] as num).toInt(),
        year: (j['year'] as num).toInt(),
        monthOfYear: (j['monthOfYear'] as num).toInt(),
        companies: (j['companies'] as List)
            .map((e) => Company.fromJson(e as Map<String, dynamic>))
            .toList(),
        marketSize: (j['marketSize'] as num).toDouble(),
        log: (j['log'] as List).map((e) => e as String).toList(),
        revenueHist:
            (j['revenueHist'] as List).map((e) => (e as num).toDouble()).toList(),
        shareHist:
            (j['shareHist'] as List).map((e) => (e as num).toDouble()).toList(),
        costMult: (j['costMult'] as num).toDouble(),
        costMultMonths: (j['costMultMonths'] as num).toInt(),
        demandMult: (j['demandMult'] as num).toDouble(),
        demandMultMonths: (j['demandMultMonths'] as num).toInt(),
        rdMult: (j['rdMult'] as num).toDouble(),
        rdMultMonths: (j['rdMultMonths'] as num).toInt(),
        gameOver: j['gameOver'] as bool,
        won: j['won'] as bool,
        endReason: j['endReason'] as String,
      );
}
