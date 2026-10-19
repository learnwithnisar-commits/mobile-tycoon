import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../store.dart';
import 'game.dart';

const List<int> brandColors = [
  0xFF00E5FF,
  0xFF2979FF,
  0xFF7C4DFF,
  0xFFFF4081,
  0xFFFF6E40,
  0xFF76FF03,
  0xFFFFD740,
  0xFF18FFFF,
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
            const SizedBox(height: 24),
            const Card(
              color: Color(0xFF1E1E1E),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'You start with \$10M.\nRival: VoltEdge (AI) — it launches a new phone every 4 months.\nReach \$100M cash to win. Go bankrupt and it\'s over.',
                  style: TextStyle(fontSize: 13),
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
