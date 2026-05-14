import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/transaction.dart';
import '../models/category.dart' as app;
import 'category_icon_widget.dart';

class TransactionTile extends StatelessWidget {
  final Transaction transaction;
  final app.Category? category;
  final VoidCallback? onTap;
  final VoidCallback? onDismissed;

  const TransactionTile({
    super.key,
    required this.transaction,
    this.category,
    this.onTap,
    this.onDismissed,
  });

  @override
  Widget build(BuildContext context) {
    final isExpense = transaction.type == TransactionType.expense;
    final color = isExpense ? Colors.red : Colors.green;
    final sign = isExpense ? '-' : '+';

    return ListTile(
      leading: CategoryIconWidget(
        iconCode: category?.icon,
        colorHex: category?.color,
      ),
      title: Text(
        category?.name ?? '未分类',
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w500,
            ),
      ),
      subtitle: transaction.notes != null && transaction.notes!.isNotEmpty
          ? Text(
              transaction.notes!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            )
          : Text(
              DateFormat('HH:mm').format(transaction.date),
              style: Theme.of(context).textTheme.bodySmall,
            ),
      trailing: Text(
        '$sign\u00a5${transaction.amount.toStringAsFixed(2)}',
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
      ),
      onTap: onTap,
    );
  }
}
