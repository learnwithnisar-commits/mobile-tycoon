import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../game/store.dart';
import '../game/models.dart';
import '../game/engine.dart';
import '../game/format.dart';
import '../widgets/charts.dart';

class PhonesScreen extends StatelessWidget {
  const PhonesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = context.watch<GameStore>();
    final s = store.state!;
    final p = s.player;
    final accent = const Color(0xFF00E5FF);

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: accent,
        foregroundColor: Colors.black,
        icon: const Icon(Icons.add),
        label: const Text('DESIGN PHONE',
            style: TextStyle(fontWeight: FontWeight.bold)),
        onPressed: () => _showDesigner(context),
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
                    Text('No phones on the market',
                        style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[400])),
                    const SizedBox(height: 8),
                    Text(
                      'Design your first phone and start selling.\nYour rivals already launched theirs!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 13, color: Colors.grey[600])),
                  ],
                ),
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const SectionTitle(title: 'Your lineup'),
                for (final ph in p.phones) _PhoneCard(phone: ph),
                const SizedBox(height: 90),
              ],
            ),
    );
  }

  void _showDesigner(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => const _PhoneDesignerDialog(),
    );
  }
}

class _PhoneCard extends StatelessWidget {
  final Phone phone;
  const _PhoneCard({required this.phone});

  @override
  Widget build(BuildContext context) {
    final profit = phone.sold * phone.margin;
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
                Expanded(
                  child: Text(phone.name,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.amber.withOpacity( 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.star,
                          size: 13, color: Colors.amber),
                      const SizedBox(width: 3),
                      Text(phone.rating.toStringAsFixed(1),
                          style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Specs  ${phone.specs.asMap().entries.map((e) => '${techNames[e.key].substring(0, 4)}:${e.value}').join('  ')}',
              style: TextStyle(fontSize: 12, color: Colors.grey[400]),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _MiniStat('Price', fmtMoney(phone.price)),
                _MiniStat('Cost', fmtMoney(phone.unitCost)),
                _MiniStat('Margin', fmtMoney(phone.margin)),
                _MiniStat('Sold', fmtUnits(phone.sold)),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Text(
                  'Profit last mo: ${fmtMoney(profit)}',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: profit >= 0
                          ? Colors.greenAccent
                          : Colors.redAccent),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    context
                        .read<GameStore>()
                        .discontinuePhone(phone.id);
                  },
                  child: const Text('Discontinue',
                      style: TextStyle(
                          color: Colors.redAccent, fontSize: 12)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;
  const _MiniStat(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(fontSize: 10, color: Colors.grey[500])),
          Text(value,
              style: const TextStyle(
                  fontSize: 13, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class _PhoneDesignerDialog extends StatefulWidget {
  const _PhoneDesignerDialog();

  @override
  State<_PhoneDesignerDialog> createState() => _PhoneDesignerDialogState();
}

class _PhoneDesignerDialogState extends State<_PhoneDesignerDialog> {
  final _nameCtrl = TextEditingController();
  late List<int> _specs;
  double _price = 699;
  int _serial = 1;

  @override
  void initState() {
    super.initState();
    final tech =
        context.read<GameStore>().state!.player.tech;
    _specs = List<int>.from(tech);
    _serial =
        context.read<GameStore>().state!.player.phones.length + 1;
    _nameCtrl.text = 'Model $_serial';
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<GameStore>();
    final tech = store.state!.player.tech;
    final accent = const Color(0xFF00E5FF);
    final cost = Engine.unitCost(_specs);
    final margin = _price - cost;
    final rating = Engine.phoneRating(_specs, _price);

    return AlertDialog(
      backgroundColor: const Color(0xFF1E1E1E),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18)),
      title: const Text('Design new phone',
          style: TextStyle(fontWeight: FontWeight.bold)),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
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
              for (int i = 0; i < 5; i++)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(techNames[i],
                            style: const TextStyle(fontSize: 13)),
                        const Spacer(),
                        Text('Lv ${_specs[i]}',
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: accent)),
                      ],
                    ),
                    Slider(
                      value: _specs[i].toDouble(),
                      min: 1,
                      max: tech[i].toDouble(),
                      divisions: tech[i] - 1 < 1 ? 1 : tech[i] - 1,
                      activeColor: accent,
                      onChanged: (v) =>
                          setState(() => _specs[i] = v.round()),
                    ),
                  ],
                ),
              Row(
                children: [
                  const Text('Price',
                      style: TextStyle(fontSize: 13)),
                  const Spacer(),
                  Text(fmtMoney(_price),
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: accent)),
                ],
              ),
              Slider(
                value: _price,
                min: 99,
                max: 2499,
                activeColor: accent,
                onChanged: (v) => setState(() => _price = v.roundToDouble()),
              ),
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Unit cost',
                      style: TextStyle(fontSize: 13)),
                  Text(fmtMoney(cost),
                      style: const TextStyle(fontSize: 13)),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Margin / unit',
                      style: TextStyle(fontSize: 13)),
                  Text(fmtMoney(margin),
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: margin >= 0
                              ? Colors.greenAccent
                              : Colors.redAccent)),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Expected rating',
                      style: TextStyle(fontSize: 13)),
                  Row(
                    children: [
                      const Icon(Icons.star,
                          size: 14, color: Colors.amber),
                      Text(rating.toStringAsFixed(1),
                          style: const TextStyle(fontSize: 13)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text('Launch cost: ${fmtMoney(phoneLaunchCost)}',
                  style:
                      TextStyle(fontSize: 12, color: Colors.grey[500])),
            ],
          ),
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
                  final err = context.read<GameStore>().releasePhone(
                      _nameCtrl.text, _specs, _price);
                  if (err != null && context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(err)));
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
