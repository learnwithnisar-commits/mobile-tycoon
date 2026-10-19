import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../game/store.dart';
import 'game_screen.dart';

const List<int> brandColors = [
  0xFF00E5FF, // cyan
  0xFF2979FF, // blue
  0xFF7C4DFF, // purple
  0xFFFF4081, // pink
  0xFFFF6E40, // orange
  0xFF76FF03, // lime
  0xFFFFD740, // amber
  0xFF18FFFF, // teal
];

class SetupScreen extends StatefulWidget {
  const SetupScreen({super.key});

  @override
  State<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  final _nameCtrl = TextEditingController(text: 'MyPhone');
  int _color = brandColors[0];

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Found Your Company')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Company name',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            const SizedBox(height: 8),
            TextField(
              controller: _nameCtrl,
              maxLength: 18,
              decoration: InputDecoration(
                hintText: 'e.g. StarMobile',
                filled: true,
                fillColor: const Color(0xFF1E1E1E),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 20),
            const Text('Brand color',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                for (final c in brandColors)
                  GestureDetector(
                    onTap: () => setState(() => _color = c),
                    child: Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: Color(c),
                        shape: BoxShape.circle,
                        border: _color == c
                            ? Border.all(color: Colors.white, width: 3)
                            : null,
                      ),
                      child: _color == c
                          ? const Icon(Icons.check, color: Colors.black)
                          : null,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 28),
            Card(
              color: const Color(0xFF1E1E1E),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
              child: const Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Starting package',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    _SetupRow('Starting capital', '\$10.00M'),
                    _SetupRow('Tech level', '2 in all categories'),
                    _SetupRow('Factory', '200K units/month'),
                    _SetupRow('Workers', '150'),
                    _SetupRow('Rivals',
                        'VoltEdge (premium) • PocketPal (budget) • NovaLabs (R&D)'),
                  ],
                ),
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00E5FF),
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: () {
                  final name = _nameCtrl.text.trim().isEmpty
                      ? 'MyPhone'
                      : _nameCtrl.text.trim();
                  context.read<GameStore>().newGame(name, _color);
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const GameScreen()),
                    (r) => false,
                  );
                },
                child: const Text('LAUNCH COMPANY',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SetupRow extends StatelessWidget {
  final String k;
  final String v;
  const _SetupRow(this.k, this.v);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Text(k, style: TextStyle(color: Colors.grey[400], fontSize: 13)),
          const Spacer(),
          Flexible(
            child: Text(v,
                textAlign: TextAlign.right,
                style: const TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}
