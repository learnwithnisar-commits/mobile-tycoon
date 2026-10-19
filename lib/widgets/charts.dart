import 'dart:math';
import 'package:flutter/material.dart';

/// Simple revenue line chart drawn with CustomPainter.
class RevenueChart extends StatelessWidget {
  final List<double> data;
  final Color color;
  const RevenueChart({super.key, required this.data, required this.color});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 150,
      width: double.infinity,
      child: CustomPaint(painter: _LinePainter(data, color)),
    );
  }
}

class _LinePainter extends CustomPainter {
  final List<double> data;
  final Color color;
  _LinePainter(this.data, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;
    final maxV = data.reduce(max);
    final minV = data.reduce(min);
    final range = (maxV - minV) == 0 ? 1.0 : (maxV - minV);
    final pts = <Offset>[];
    for (int i = 0; i < data.length; i++) {
      final x = data.length == 1
          ? size.width / 2
          : i / (data.length - 1) * size.width;
      final y = size.height - 8 - (data[i] - minV) / range * (size.height - 24);
      pts.add(Offset(x, y));
    }
    // area fill
    final fill = Path()..moveTo(pts.first.dx, size.height);
    for (final p in pts) {
      fill.lineTo(p.dx, p.dy);
    }
    fill.lineTo(pts.last.dx, size.height);
    fill.close();
    canvas.drawPath(
        fill, Paint()..color = color.withOpacity( 0.18));
    // line
    final path = Path()..moveTo(pts.first.dx, pts.first.dy);
    for (int i = 1; i < pts.length; i++) {
      path.lineTo(pts[i].dx, pts[i].dy);
    }
    canvas.drawPath(
        path,
        Paint()
          ..color = color
          ..strokeWidth = 2.5
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round);
    // last dot
    canvas.drawCircle(pts.last, 4, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant _LinePainter old) =>
      old.data != data || old.color != color;
}

/// Market-share donut chart.
class ShareDonut extends StatelessWidget {
  final List<double> shares; // 0..100
  final List<Color> colors;
  final List<String> labels;
  const ShareDonut(
      {super.key,
      required this.shares,
      required this.colors,
      required this.labels});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 190,
      child: Row(
        children: [
          SizedBox(
            width: 150,
            height: 150,
            child: CustomPaint(
                painter: _DonutPainter(shares, colors)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (int i = 0; i < labels.length; i++)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 3),
                    child: Row(
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: colors[i],
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(labels[i],
                              style: const TextStyle(fontSize: 12),
                              overflow: TextOverflow.ellipsis),
                        ),
                        Text('${shares[i].toStringAsFixed(1)}%',
                            style: const TextStyle(
                                fontSize: 12, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DonutPainter extends CustomPainter {
  final List<double> shares;
  final List<Color> colors;
  _DonutPainter(this.shares, this.colors);

  @override
  void paint(Canvas canvas, Size size) {
    final total = shares.fold<double>(0, (a, b) => a + b);
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 6;
    if (total <= 0) {
      canvas.drawCircle(
          center, radius, Paint()..color = Colors.grey.withOpacity( 0.3));
      return;
    }
    double start = -pi / 2;
    for (int i = 0; i < shares.length; i++) {
      final sweep = shares[i] / total * 2 * pi;
      canvas.drawArc(
          Rect.fromCircle(center: center, radius: radius),
          start,
          sweep,
          true,
          Paint()..color = colors[i]);
      start += sweep;
    }
    canvas.drawCircle(
        center, radius * 0.58, Paint()..color = const Color(0xFF121212));
  }

  @override
  bool shouldRepaint(covariant _DonutPainter old) =>
      old.shares != shares || old.colors != colors;
}

/// Small stat card used on the dashboard.
class StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color accent;
  final String? sub;
  const StatCard(
      {super.key,
      required this.label,
      required this.value,
      required this.icon,
      required this.accent,
      this.sub});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: const Color(0xFF1E1E1E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 16, color: accent),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(label,
                      style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[400],
                          fontWeight: FontWeight.w500),
                      overflow: TextOverflow.ellipsis),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(value,
                style: const TextStyle(
                    fontSize: 17, fontWeight: FontWeight.bold)),
            if (sub != null)
              Text(sub!,
                  style: TextStyle(fontSize: 11, color: Colors.grey[500])),
          ],
        ),
      ),
    );
  }
}

/// Section header with title.
class SectionTitle extends StatelessWidget {
  final String title;
  final String? action;
  const SectionTitle({super.key, required this.title, this.action});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 16, 4, 8),
      child: Row(
        children: [
          Text(title,
              style: const TextStyle(
                  fontSize: 16, fontWeight: FontWeight.bold)),
          const Spacer(),
          if (action != null)
            Text(action!,
                style: TextStyle(fontSize: 12, color: Colors.grey[500])),
        ],
      ),
    );
  }
}
