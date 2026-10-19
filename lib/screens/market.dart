import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../store.dart';
import '../game.dart';

class MarketScreen extends StatelessWidget {
  const MarketScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = context.watch<GameStore>();
    final g = store.game!;
    const accent = Color(0xFF00E5FF);

    final all = [...g.player.phones, ...g.ai.phones];
    all.sort((a, b) => b.sold.compareTo(a.sold));
    final maxSold = all.isEmpty ? 1 : all.first.sold;

    String ownerName(String id) =>
        id == g.player.id ? g.player.name : g.ai.name;
    Color ownerColor(String id) =>
        Color(id == g.player.id ? g.player.color : g.ai.color);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          color: const Color(0xFF1E1E1E),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(Icons.public, color: accent, size: 26),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Global market',
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold)),
                    Text('${fmtUnits(g.marketSize.toInt())} phones / month',
                        style: TextStyle(
                            fontSize: 12, color: Colors.grey[400])),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        const Text('Top phones',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        if (all.isEmpty)
          const Padding(
            padding: EdgeInsets.all(24),
            child: Text('No phones on the market yet.',
                textAlign: TextAlign.center),
          ),
        for (int i = 0; i < all.length; i++)
          Builder(builder: (_) {
            final ph = all[i];
            return Card(
              color: const Color(0xFF1E1E1E),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              margin: const EdgeInsets.only(bottom: 8),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    SizedBox(
                      width: 28,
                      child: Text('#${i + 1}',
                          style: TextStyle(
                              fontWeight: FontWeight.w900,
                              color: i == 0
                                  ? Colors.amber
                                  : Colors.grey[500])),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(ph.name,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 14)),
                          Text(
                              '${ownerName(ph.ownerId)} • ${fmtMoney(ph.price)} • Q${ph.quality}',
                              style: TextStyle(
                                  fontSize: 11, color: Colors.grey[500])),
                          const SizedBox(height: 4),
                          LinearProgressIndicator(
                            value: maxSold > 0 ? ph.sold / maxSold : 0.0,
                            color: ownerColor(ph.ownerId),
                            backgroundColor: Colors.grey[800],
                            minHeight: 5,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(fmtUnits(ph.sold),
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 13)),
                  ],
                ),
              ),
            );
          }),
        const SizedBox(height: 12),
        const Text('Standings',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        for (final c in [g.player, g.ai])
          Card(
            color: c.isPlayer
                ? const Color(0xFF1A2E35)
                : const Color(0xFF1E1E1E),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: c.isPlayer
                  ? const BorderSide(color: accent, width: 1)
                  : BorderSide.none,
            ),
            margin: const EdgeInsets.only(bottom: 8),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                        color: Color(c.color), shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(c.name,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(fmtMoney(c.cash),
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 14)),
                      Text('${c.share.toStringAsFixed(1)}% share',
                          style: TextStyle(
                              fontSize: 11, color: Colors.grey[500])),
                    ],
                  ),
                ],
              ),
            ),
          ),
        const SizedBox(height: 24),
      ],
    );
  }
}
