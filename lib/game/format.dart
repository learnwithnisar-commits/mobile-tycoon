String fmtMoney(double v) {
  final neg = v < 0;
  final a = v.abs();
  String s;
  if (a >= 1e9) {
    s = '\$${(a / 1e9).toStringAsFixed(2)}B';
  } else if (a >= 1e6) {
    s = '\$${(a / 1e6).toStringAsFixed(2)}M';
  } else if (a >= 1e3) {
    s = '\$${(a / 1e3).toStringAsFixed(1)}K';
  } else {
    s = '\$${a.toStringAsFixed(0)}';
  }
  return neg ? '-$s' : s;
}

String fmtUnits(int v) {
  if (v >= 1000000) return '${(v / 1000000).toStringAsFixed(1)}M';
  if (v >= 1000) return '${(v / 1000).toStringAsFixed(0)}K';
  return '$v';
}

String fmtPct(double v) => '${v.toStringAsFixed(1)}%';

const List<String> monthNames = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];

String fmtDate(int year, int monthOfYear) =>
    '${monthNames[(monthOfYear - 1) % 12]} $year';
