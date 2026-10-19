import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../game/store.dart';
import '../game/format.dart';
import '../game/engine.dart';
import '../widgets/charts.dart';
import 'title_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = context.watch<GameStore>();
    final s = store.state!;
    final p = s.player;
    final accent = const Color(0xFF00E5FF);

    final shares = s.companies.map((c) => c.marketShare).toList();
    final colors = s.companies.map((c) => Color(c.color)).toList();
    final labels = s.companies.map((c) => c.name).toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // cash + valuation hero
        Card(
          color: const Color(0xFF1E1E1E),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                Expanded(
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
                              fontSize: 26,
                              fontWeight: FontWeight.w900,
                              color: p.cash < 0
                                  ? Colors.redAccent
                                  : Colors.white)),
                      const SizedBox(height: 8),
                      Text('COMPANY VALUE',
                          style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[500],
                              letterSpacing: 1)),
                      Text(fmtMoney(p.valuation),
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: accent)),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('MARKET SHARE',
                        style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[500],
                            letterSpacing: 1)),
                    Text(fmtPct(p.marketShare),
                        style: const TextStyle(
                            fontSize: 26, fontWeight: FontWeight.w900)),
                    const SizedBox(height: 8),
                    Text('GOAL: ${fmtMoney(winValuation)}',
                        style: TextStyle(
                            fontSize: 11, color: Colors.grey[500])),
                    const SizedBox(height: 4),
                    SizedBox(
                      width: 120,
                      child: LinearProgressIndicator(
                        value: (p.valuation / winValuation)
                            .clamp(0.0, 1.0)
                            .toDouble(),
                        backgroundColor: Colors.grey[800],
                        color: accent,
                        minHeight: 6,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        // last month P&L
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 2.1,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          children: [
            StatCard(
                label: 'Revenue (last mo)',
                value: fmtMoney(p.lastRevenue),
                icon: Icons.trending_up,
                accent: Colors.greenAccent),
            StatCard(
                label: 'Profit (last mo)',
                value: fmtMoney(p.lastProfit),
                icon: Icons.account_balance_wallet,
                accent: p.lastProfit >= 0
                    ? Colors.greenAccent
                    : Colors.redAccent),
            StatCard(
                label: 'Units sold',
                value: fmtUnits(p.lastUnits),
                icon: Icons.shopping_cart,
                accent: Colors.amber),
            StatCard(
                label: 'Brand awareness',
                value: fmtPct(p.awareness),
                icon: Icons.campaign,
                accent: Colors.purpleAccent),
          ],
        ),
        const SectionTitle(title: 'Revenue trend'),
        Card(
          color: const Color(0xFF1E1E1E),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: RevenueChart(data: s.revenueHist, color: accent),
          ),
        ),
        const SectionTitle(title: 'Market share'),
        Card(
          color: const Color(0xFF1E1E1E),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: ShareDonut(
                shares: shares, colors: colors, labels: labels),
          ),
        ),
        const SectionTitle(title: 'Company news'),
        Card(
          color: const Color(0xFF1E1E1E),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(6),
            child: Column(
              children: [
                for (final msg in s.log.reversed.take(8))
                  ListTile(
                    dense: true,
                    leading: const Icon(Icons.fiber_manual_record,
                        size: 10, color: Color(0xFF00E5FF)),
                    title: Text(msg,
                        style: const TextStyle(fontSize: 12.5)),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        TextButton.icon(
          icon: const Icon(Icons.delete_outline, size: 16),
          label: const Text('Abandon company',
              style: TextStyle(fontSize: 12)),
          style: TextButton.styleFrom(foregroundColor: Colors.grey[600]),
          onPressed: () {
            showDialog(
              context: context,
              builder: (_) => AlertDialog(
                backgroundColor: const Color(0xFF1E1E1E),
                title: const Text('Abandon company?'),
                content: const Text(
                    'Your progress will be deleted. This cannot be undone.'),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('CANCEL')),
                  TextButton(
                    onPressed: () {
                      context.read<GameStore>().abandonRun();
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                            builder: (_) => const TitleScreen()),
                        (r) => false,
                      );
                    },
                    child: const Text('ABANDON',
                        style: TextStyle(color: Colors.redAccent)),
                  ),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}
