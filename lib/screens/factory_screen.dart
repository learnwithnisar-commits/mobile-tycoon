import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../game/store.dart';
import '../game/engine.dart';
import '../game/format.dart';
import '../widgets/charts.dart';

class FactoryScreen extends StatelessWidget {
  const FactoryScreen({super.key});

  void _act(BuildContext context, String? Function() fn) {
    final err = fn();
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
    final eff = p.effectiveCapacity;
    final utilization =
        eff > 0 ? (p.lastUnits / eff).clamp(0.0, 1.0) : 0.0;

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
                Row(
                  children: [
                    Icon(Icons.factory, color: accent, size: 26),
                    const SizedBox(width: 10),
                    const Text('Production Line',
                        style: TextStyle(
                            fontSize: 17, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Factory capacity',
                        style: TextStyle(color: Colors.grey[400])),
                    Text(fmtUnits(p.capacity),
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 15)),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Effective output',
                        style: TextStyle(color: Colors.grey[400])),
                    Text('${fmtUnits(eff)}/mo',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: accent)),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Last month utilization',
                        style: TextStyle(color: Colors.grey[400])),
                    Text(fmtPct(utilization * 100),
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 15)),
                  ],
                ),
                const SizedBox(height: 10),
                LinearProgressIndicator(
                  value: utilization,
                  color: utilization > 0.9 ? Colors.redAccent : accent,
                  backgroundColor: Colors.grey[800],
                  minHeight: 8,
                  borderRadius: BorderRadius.circular(4),
                ),
                if (utilization > 0.9)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      'Demand exceeds capacity — you are losing sales! Expand or hire.',
                      style: TextStyle(
                          color: Colors.redAccent[100], fontSize: 12),
                    ),
                  ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.add_business),
                    label: Text(
                        'Expand +${fmtUnits(factoryUpgradeUnits)} — ${fmtMoney(factoryUpgradeCost)}'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accent,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: p.cash >= factoryUpgradeCost
                        ? () => _act(context, store.upgradeFactory)
                        : null,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    'Upkeep: ${fmtMoney(p.capacity * factoryUpkeepPerUnit)}/mo',
                    style: TextStyle(
                        fontSize: 12, color: Colors.grey[500])),
                ),
              ],
            ),
          ),
        ),
        const SectionTitle(title: 'Workforce'),
        Card(
          color: const Color(0xFF1E1E1E),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(Icons.groups, color: accent, size: 26),
                    const SizedBox(width: 10),
                    Text('${p.workers} workers',
                        style: const TextStyle(
                            fontSize: 17, fontWeight: FontWeight.bold)),
                    const Spacer(),
                    Text(fmtMoney(p.workers * workerWage),
                        style: TextStyle(
                            color: Colors.grey[400], fontSize: 13)),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Each worker operates ${fmtUnits(1000)}/mo. Wages ${fmtMoney(workerWage)}/worker/mo.',
                  style:
                      TextStyle(fontSize: 12, color: Colors.grey[500])),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.remove),
                        label: const Text('Fire 10'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.redAccent,
                          side:
                              const BorderSide(color: Colors.redAccent),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: () =>
                            _act(context, () => store.hireWorkers(-10)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.add),
                        label: const Text('Hire 10'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accent,
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: () =>
                            _act(context, () => store.hireWorkers(10)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SectionTitle(title: 'Marketing'),
        for (final camp in campaigns)
          Card(
            color: const Color(0xFF1E1E1E),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14)),
            margin: const EdgeInsets.only(bottom: 10),
            child: ListTile(
              leading: Icon(Icons.campaign,
                  color: accent, size: 28),
              title: Text(camp.name,
                  style:
                      const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(
                  '${camp.desc}\n+${camp.awarenessBoost.toStringAsFixed(0)} brand awareness',
                  style: const TextStyle(fontSize: 12)),
              isThreeLine: true,
              trailing: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: accent,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: p.cash >= camp.cost
                    ? () => _act(
                        context, () => store.runCampaign(camp))
                    : null,
                child: Text(fmtMoney(camp.cost),
                    style: const TextStyle(fontSize: 12)),
              ),
            ),
          ),
        const SizedBox(height: 24),
      ],
    );
  }
}
