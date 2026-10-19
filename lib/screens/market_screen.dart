import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../game/store.dart';
import '../game/models.dart';
import '../game/format.dart';
import '../widgets/charts.dart';

class MarketScreen extends StatelessWidget {
  const MarketScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = context.watch<GameStore>();
    final s = store.state!;
    final accent = const Color(0xFF00E5FF);

    final allPhones = <Phone>[];
    for (final c in s.companies) {
      allPhones.addAll(c.phones);
    }
    allPhones.sort((a, b) => b.sold.compareTo(a.sold));

    final ranked = s.companies.toList()
      ..sort((a, b) => b.valuation.compareTo(a.valuation));

    String ownerName(String id) =>
        s.companies.firstWhere((c) => c.id == id).name;
    Color ownerColor(String id) =>
        Color(s.companies.firstWhere((c) => c.id == id).color);

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
                    Text('${fmtUnits(s.marketSize.toInt())} phones / month',
                        style: TextStyle(
                            fontSize: 12, color: Colors.grey[400])),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SectionTitle(title: 'Top selling phones'),
        if (allPhones.isEmpty)
          const Padding(
            padding: EdgeInsets.all(24),
            child: Text('No phones on the market yet.',
                textAlign: TextAlign.center),
          ),
        for (int i = 0; i < allPhones.length; i++)
          Builder(builder: (_) {
            final ph = allPhones[i];
            final maxSold =
                allPhones.isEmpty ? 1 : allPhones.first.sold;
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
                      width: 26,
                      child: Text('#${i + 1}',
                          style: TextStyle(
                              fontWeight: FontWeight.w900,
                              color: i == 0
                                  ? Colors.amber
                                  : Colors.grey[500])),
                    ),
                    Container(
                      width: 10,
                      height: 36,
                      decoration: BoxDecoration(
                        color: ownerColor(ph.companyId),
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(ph.name,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14)),
                          Text(
                              '${ownerName(ph.companyId)} • ${fmtMoney(ph.price)} • ★ ${ph.rating.toStringAsFixed(1)}',
                              style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey[500])),
                          const SizedBox(height: 4),
                          LinearProgressIndicator(
                            value: maxSold > 0
                                ? ph.sold / maxSold
                                : 0,
                            color: ownerColor(ph.companyId),
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
        const SectionTitle(title: 'Company standings'),
        for (final c in ranked)
          Card(
            color: c.isPlayer
                ? const Color(0xFF1A2E35)
                : const Color(0xFF1E1E1E),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: c.isPlayer
                  ? const BorderSide(color: Color(0xFF00E5FF), width: 1)
                  : BorderSide.none,
            ),
            margin: const EdgeInsets.only(bottom: 8),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                        color: Color(c.color),
                        shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(c.name,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                            if (c.bankrupt)
                              const Padding(
                                padding: EdgeInsets.only(left: 6),
                                child: Text('BANKRUPT',
                                    style: TextStyle(
                                        color: Colors.redAccent,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold)),
                              ),
                          ],
                        ),
                        Text(
                            'Tech ${c.tech.fold<int>(0, (a, b) => a + b)}/50 • ${c.phones.length} phones • ${fmtPct(c.awareness)} buzz',
                            style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey[500])),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(fmtMoney(c.valuation),
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13)),
                      Text('${fmtPct(c.marketShare)} share',
                          style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[500])),
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
