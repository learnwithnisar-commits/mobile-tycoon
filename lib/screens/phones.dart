import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../store.dart';
import '../game.dart';

class PhonesScreen extends StatelessWidget {
  const PhonesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = context.watch<GameStore>();
    final g = store.game!;
    final p = g.player;
    const accent = Color(0xFF00E5FF);

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: accent,
        foregroundColor: Colors.black,
        icon: const Icon(Icons.add),
        label: const Text('NEW PHONE',
            style: TextStyle(fontWeight: FontWeight.bold)),
        onPressed: () => showDialog(
          context: context,
          builder: (_) => const _DesignerDialog(),
        ),
      ),
      body: p.phones.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.smartphone,
                        size: 64, color: Colors.grey[700]),
                    const SizedBox(height: 16),
                    Text('No phones yet',
                        style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[400])),
                    const SizedBox(height: 8),
                    Text(
                      'Design your first phone and hit Next Month to sell.\nVoltEdge already sells phones!',
                      textAlign: TextAlign.center,
                      style:
                          TextStyle(fontSize: 13, color: Colors.grey[600])),
                  ],
                ),
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                for (final ph in p.phones)
                  Card(
                    color: const Color(0xFF1E1E1E),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    margin: const EdgeInsets.only(bottom: 10),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(ph.name,
                              style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text(
                            'Quality ${ph.quality}/10  •  ${fmtMoney(ph.price)}  •  cost ${fmtMoney(ph.unitCost)}',
                            style: TextStyle(
                                fontSize: 12, color: Colors.grey[400]),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Text(
                                'Sold ${fmtUnits(ph.sold)}  •  Profit ${fmtMoney(ph.sold * ph.margin)}',
                                style: const TextStyle(fontSize: 12),
                              ),
                              const Spacer(),
                              TextButton(
                                onPressed: () =>
                                    context.read<GameStore>().discontinue(ph.id),
                                child: const Text('Discontinue',
                                    style: TextStyle(
                                        color: Colors.redAccent,
                                        fontSize: 12)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(height: 90),
              ],
            ),
    );
  }
}

class _DesignerDialog extends StatefulWidget {
  const _DesignerDialog();

  @override
  State<_DesignerDialog> createState() => _DesignerDialogState();
}

class _DesignerDialogState extends State<_DesignerDialog> {
  final _nameCtrl = TextEditingController();
  int _quality = 5;
  double _price = 499;

  @override
  void initState() {
    super.initState();
    final n = context.read<GameStore>().game!.player.phones.length + 1;
    _nameCtrl.text = 'Model $n';
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const accent = Color(0xFF00E5FF);
    final cost = unitCostFor(_quality);
    final margin = _price - cost;

    return AlertDialog(
      backgroundColor: const Color(0xFF1E1E1E),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18)),
      title: const Text('Design phone',
          style: TextStyle(fontWeight: FontWeight.bold)),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nameCtrl,
              maxLength: 20,
              decoration: InputDecoration(
                labelText: 'Phone name',
                filled: true,
                fillColor: const Color(0xFF2A2A2A),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Text('Quality', style: TextStyle(fontSize: 13)),
                const Spacer(),
                Text('$_quality/10',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: accent)),
              ],
            ),
            Slider(
              value: _quality.toDouble(),
              min: 1,
              max: 10,
              divisions: 9,
              activeColor: accent,
              onChanged: (v) => setState(() => _quality = v.round()),
            ),
            Row(
              children: [
                const Text('Price', style: TextStyle(fontSize: 13)),
                const Spacer(),
                Text(fmtMoney(_price),
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: accent)),
              ],
            ),
            Slider(
              value: _price,
              min: 99,
              max: 1999,
              activeColor: accent,
              onChanged: (v) => setState(() => _price = v.roundToDouble()),
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Unit cost', style: TextStyle(fontSize: 13)),
                Text(fmtMoney(cost), style: const TextStyle(fontSize: 13)),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Margin', style: TextStyle(fontSize: 13)),
                Text(fmtMoney(margin),
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: margin >= 0
                            ? Colors.greenAccent
                            : Colors.redAccent)),
              ],
            ),
            Text('Launch cost: ${fmtMoney(50000)}',
                style: TextStyle(fontSize: 12, color: Colors.grey[500])),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('CANCEL'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: accent,
            foregroundColor: Colors.black,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)),
          ),
          onPressed: margin < 0
              ? null
              : () {
                  final err = context.read<GameStore>().launchPhone(
                      _nameCtrl.text, _quality, _price);
                  if (err != null && context.mounted) {
                    ScaffoldMessenger.of(context)
                        .showSnackBar(SnackBar(content: Text(err)));
                  } else {
                    Navigator.of(context).pop();
                  }
                },
          child: const Text('LAUNCH',
              style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}
