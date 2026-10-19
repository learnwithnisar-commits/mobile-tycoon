import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../store.dart';
import '../game.dart';
import 'title.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = context.watch<GameStore>();
    final g = store.game!;
    final p = g.player;
    const accent = Color(0xFF00E5FF);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          color: const Color(0xFF1E1E1E),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('CASH',
                    style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[500],
                        letterSpacing: 1)),
                Text(fmtMoney(p.cash),
                    style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w900,
                        color: p.cash < 0 ? Colors.redAccent : Colors.white)),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _Mini('Market share', '${p.share.toStringAsFixed(1)}%',
                        accent),
                    _Mini('Phones', '${p.phones.length}', Colors.amber),
                    _Mini('Goal', fmtMoney(1e8), Colors.greenAccent),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          color: const Color(0xFF1E1E1E),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Last month',
                    style:
                        TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                _Row('Revenue', fmtMoney(p.lastRevenue)),
                _Row('Profit', fmtMoney(p.lastProfit),
                    p.lastProfit >= 0 ? Colors.greenAccent : Colors.redAccent),
                _Row('Units sold', fmtUnits(p.lastUnits)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        const Text('News',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Card(
          color: const Color(0xFF1E1E1E),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(6),
            child: Column(
              children: [
                for (final msg in g.log.reversed.take(8))
                  ListTile(
                    dense: true,
                    leading: const Icon(Icons.fiber_manual_record,
                        size: 10, color: accent),
                    title:
                        Text(msg, style: const TextStyle(fontSize: 12.5)),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: () {
            store.abandon();
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const TitleScreen()),
              (r) => false,
            );
          },
          child: Text('Abandon company',
              style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

class _Mini extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _Mini(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(fontSize: 10, color: Colors.grey[500])),
          Text(value,
              style: TextStyle(
                  fontSize: 15, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;
  final Color? color;
  const _Row(this.label, this.value, [this.color]);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(label, style: TextStyle(color: Colors.grey[400], fontSize: 13)),
          const Spacer(),
          Text(value,
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: color ?? Colors.white)),
        ],
      ),
    );
  }
}
