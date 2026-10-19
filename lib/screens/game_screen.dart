import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../game/store.dart';
import '../game/format.dart';
import 'dashboard_screen.dart';
import 'research_screen.dart';
import 'factory_screen.dart';
import 'phones_screen.dart';
import 'market_screen.dart';
import 'title_screen.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  int _tab = 0;

  static const List<Widget> _tabs = [
    DashboardScreen(),
    ResearchScreen(),
    FactoryScreen(),
    PhonesScreen(),
    MarketScreen(),
  ];

  void _nextMonth() {
    final store = context.read<GameStore>();
    store.nextMonth();
    final s = store.state;
    if (s != null && s.gameOver) {
      _showEndDialog(s.won, s.endReason);
    }
  }

  void _showEndDialog(bool won, String reason) {
    final store = context.read<GameStore>();
    final months = store.state?.totalMonths ?? 0;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Row(
          children: [
            Icon(won ? Icons.emoji_events : Icons.warning_amber,
                color: won ? Colors.amber : Colors.red, size: 30),
            const SizedBox(width: 10),
            Text(won ? 'VICTORY!' : 'GAME OVER',
                style: const TextStyle(fontWeight: FontWeight.w900)),
          ],
        ),
        content: Text('$reason\n\nSurvived $months months.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const TitleScreen()),
                (r) => false,
              );
            },
            child: const Text('NEW GAME'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<GameStore>();
    final s = store.state;
    if (s == null) {
      return const Scaffold(
          body: Center(child: Text('No active game')));
    }
    final p = s.player;
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                  color: Color(p.color), shape: BoxShape.circle),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(p.name,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 4),
              child: Text(fmtDate(s.year, s.monthOfYear),
                  style: TextStyle(color: Colors.grey[400], fontSize: 13)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ElevatedButton.icon(
              icon: const Icon(Icons.fast_forward, size: 18),
              label: const Text('Next Month'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00E5FF),
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: s.gameOver ? null : _nextMonth,
            ),
          ),
        ],
      ),
      body: _tabs[_tab],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _tab,
        onTap: (i) => setState(() => _tab = i),
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFF161616),
        selectedItemColor: const Color(0xFF00E5FF),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.dashboard), label: 'Dashboard'),
          BottomNavigationBarItem(
              icon: Icon(Icons.science), label: 'R&D'),
          BottomNavigationBarItem(
              icon: Icon(Icons.factory), label: 'Factory'),
          BottomNavigationBarItem(
              icon: Icon(Icons.smartphone), label: 'Phones'),
          BottomNavigationBarItem(
              icon: Icon(Icons.store), label: 'Market'),
        ],
      ),
    );
  }
}
