import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../game/store.dart';
import '../game/models.dart';
import '../game/engine.dart';
import '../game/format.dart';
import '../widgets/charts.dart';

const List<IconData> _techIconData = [
  Icons.memory,
  Icons.photo_camera,
  Icons.battery_charging_full,
  Icons.stay_current_portrait,
  Icons.palette,
];

class ResearchScreen extends StatelessWidget {
  const ResearchScreen({super.key});

  void _research(BuildContext context, int category) {
    final err = context.read<GameStore>().startResearch(category);
    if (err != null && context.mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(err)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<GameStore>();
    final s = store.state!;
    final p = s.player;
    final accent = const Color(0xFF00E5FF);

    Research? activeFor(int cat) {
      for (final r in p.rdQueue) {
        if (r.category == cat) return r;
      }
      return null;
    }

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
                Icon(Icons.science, color: accent, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Higher tech = better phones = higher prices. Research takes months — plan ahead.',
                    style: TextStyle(fontSize: 13, color: Colors.grey[400]),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SectionTitle(title: 'Technology'),
        for (int i = 0; i < 5; i++)
          Builder(builder: (_) {
            final level = p.tech[i];
            final active = activeFor(i);
            final nextCost = level < 10
                ? Engine.researchCost(level, s.rdMult)
                : 0.0;
            final nextMonths =
                level < 10 ? Engine.researchMonths(level) : 0;
            return Card(
              color: const Color(0xFF1E1E1E),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
              margin: const EdgeInsets.only(bottom: 10),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(_techIconData[i], color: accent, size: 22),
                        const SizedBox(width: 10),
                        Text(techNames[i],
                            style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold)),
                        const Spacer(),
                        Text('Lv $level',
                            style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w900,
                                color: accent)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        for (int l = 1; l <= 10; l++)
                          Expanded(
                            child: Container(
                              height: 8,
                              margin: const EdgeInsets.only(right: 3),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(4),
                                color: l <= level
                                    ? accent
                                    : Colors.grey[800],
                              ),
                            ),
                          ),
                      ],
                    ),
                    if (active != null) ...[
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: LinearProgressIndicator(
                              value: 1 -
                                  active.monthsLeft /
                                      active.totalMonths,
                              color: Colors.amber,
                              backgroundColor: Colors.grey[800],
                              minHeight: 6,
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text('${active.monthsLeft} mo left',
                              style: const TextStyle(fontSize: 12)),
                        ],
                      ),
                    ] else if (level < 10) ...[
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: accent,
                            side: BorderSide(color: accent),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                          ),
                          onPressed: p.cash >= nextCost
                              ? () => _research(context, i)
                              : null,
                          child: Text(
                              'Research Lv ${level + 1} — ${fmtMoney(nextCost)} • $nextMonths mo'),
                        ),
                      ),
                    ] else ...[
                      const SizedBox(height: 8),
                      const Text('MAX LEVEL',
                          style: TextStyle(
                              color: Colors.amber,
                              fontWeight: FontWeight.bold,
                              fontSize: 12)),
                    ],
                  ],
                ),
              ),
            );
          }),
        const SizedBox(height: 24),
      ],
    );
  }
}
