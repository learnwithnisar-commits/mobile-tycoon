import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../store.dart';
import 'home.dart';
import 'phones.dart';
import 'market.dart';
import 'title.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  int _tab = 0;

  static const List<Widget> _tabs = [
    HomeScreen(),
    PhonesScreen(),
    MarketScreen(),
  ];

  void _nextMonth() {
    final store = context.read<GameStore>();
    store.nextMonth();
    final g = store.game;
    if (g != null && g.gameOver) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          backgroundColor: const Color(0xFF1E1E1E),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          title: Row(
            children: [
              Icon(g.won ? Icons.emoji_events : Icons.warning_amber,
                  color: g.won ? Colors.amber : Colors.red, size: 30),
              const SizedBox(width: 10),
              Text(g.won ? 'VICTORY!' : 'GAME OVER',
                  style: const TextStyle(fontWeight: FontWeight.w900)),
            ],
          ),
          content: Text('${g.endReason}\n\nSurvived ${g.totalMonths} months.'),
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
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<GameStore>();
    final g = store.game;
    if (g == null) {
      return const Scaffold(body: Center(child: Text('No active game')));
    }
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                  color: Color(g.player.color), shape: BoxShape.circle),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(g.player.name,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 4),
              child: Text(g.dateLabel,
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
              onPressed: g.gameOver ? null : _nextMonth,
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
              icon: Icon(Icons.dashboard), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.smartphone), label: 'Phones'),
          BottomNavigationBarItem(
              icon: Icon(Icons.store), label: 'Market'),
        ],
      ),
    );
  }
}
