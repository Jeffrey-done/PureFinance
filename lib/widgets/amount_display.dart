import 'package:flutter/material.dart';

class AmountDisplay extends StatelessWidget {
  final double amount;
  final String currency;
  final bool showSign;
  final TextStyle? style;
  final bool isExpense;

  const AmountDisplay({
    super.key,
    required this.amount,
    this.currency = 'CNY',
    this.showSign = true,
    this.style,
    this.isExpense = true,
  });

  @override
  Widget build(BuildContext context) {
    final color = isExpense ? Colors.red : Colors.green;
    final sign = showSign ? (isExpense ? '-' : '+') : '';
    final symbol = _getCurrencySymbol(currency);

    return Text(
      '$sign$symbol${amount.toStringAsFixed(2)}',
      style: (style ?? Theme.of(context).textTheme.bodyLarge)?.copyWith(
        color: color,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  String _getCurrencySymbol(String currency) {
    switch (currency) {
      case 'CNY':
        return '\u00a5';
      case 'USD':
        return '\$';
      case 'EUR':
        return '\u20ac';
      default:
        return '\u00a5';
    }
  }
}
