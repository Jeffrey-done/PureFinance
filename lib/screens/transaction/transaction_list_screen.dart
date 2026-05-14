import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/transaction.dart';
import '../../providers/transaction_provider.dart';
import '../../providers/category_provider.dart';
import '../../providers/account_provider.dart';
import '../../widgets/category_icon_widget.dart';
import '../../widgets/empty_state_widget.dart';
import 'add_transaction_screen.dart';

class TransactionListScreen extends StatefulWidget {
  const TransactionListScreen({super.key});

  @override
  State<TransactionListScreen> createState() => _TransactionListScreenState();
}

class _TransactionListScreenState extends State<TransactionListScreen> {
  DateTimeRange? _dateFilter;
  String? _categoryFilter;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('账单'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterOptions,
          ),
        ],
      ),
      body: Consumer<TransactionProvider>(
        builder: (context, provider, _) {
          var transactions = provider.transactions;

          // Apply filters
          if (_dateFilter != null) {
            transactions = transactions.where((t) {
              return !t.date.isBefore(_dateFilter!.start) &&
                  !t.date.isAfter(_dateFilter!.end.add(const Duration(days: 1)));
            }).toList();
          }
          if (_categoryFilter != null) {
            transactions = transactions
                .where((t) => t.categoryId == _categoryFilter)
                .toList();
          }

          if (transactions.isEmpty) {
            return const EmptyStateWidget(
              icon: Icons.receipt_long_outlined,
              message: '暂无交易记录',
            );
          }

          // Group by date
          final grouped = <String, List<Transaction>>{};
          for (final txn in transactions) {
            final key = DateFormat('yyyy-MM-dd').format(txn.date);
            grouped.putIfAbsent(key, () => []).add(txn);
          }

          final sortedKeys = grouped.keys.toList()..sort((a, b) => b.compareTo(a));

          return ListView.builder(
            itemCount: sortedKeys.length,
            itemBuilder: (context, index) {
              final dateKey = sortedKeys[index];
              final dayTransactions = grouped[dateKey]!;
              final date = DateTime.parse(dateKey);

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDateHeader(context, date),
                  ...dayTransactions.map(
                    (txn) => _buildTransactionItem(context, txn),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildDateHeader(BuildContext context, DateTime date) {
    final weekdays = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];
    final weekday = weekdays[date.weekday - 1];
    final formatted = DateFormat('yyyy年M月d日').format(date);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.3),
      child: Text(
        '$formatted $weekday',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.outline,
            ),
      ),
    );
  }

  Widget _buildTransactionItem(BuildContext context, Transaction txn) {
    final categoryProvider = context.read<CategoryProvider>();
    final category = categoryProvider.categories
        .where((c) => c.id == txn.categoryId)
        .firstOrNull;

    final isExpense = txn.type == TransactionType.expense;
    final color = isExpense ? Colors.red : Colors.green;
    final sign = isExpense ? '-' : '+';

    return Dismissible(
      key: Key(txn.id),
      direction: DismissDirection.endToStart,
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (direction) async {
        return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('确认删除'),
            content: const Text('确定要删除这条交易记录吗？'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text('取消'),
              ),
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                child: const Text('删除'),
              ),
            ],
          ),
        );
      },
      onDismissed: (_) {
        final accountProvider = context.read<AccountProvider>();
        if (txn.type == TransactionType.expense) {
          accountProvider.updateBalance(txn.accountId, txn.amount);
        } else if (txn.type == TransactionType.income) {
          accountProvider.updateBalance(txn.accountId, -txn.amount);
        }
        context.read<TransactionProvider>().deleteTransaction(txn.id);
      },
      child: ListTile(
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
        subtitle: txn.notes != null && txn.notes!.isNotEmpty
            ? Text(txn.notes!, maxLines: 1, overflow: TextOverflow.ellipsis)
            : null,
        trailing: Text(
          '$sign\u00a5${txn.amount.toStringAsFixed(2)}',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
        ),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => AddTransactionScreen(transaction: txn),
            ),
          );
        },
      ),
    );
  }

  void _showFilterOptions() {
    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.date_range),
                  title: const Text('按日期筛选'),
                  subtitle: _dateFilter != null
                      ? Text(
                          '${DateFormat('M/d').format(_dateFilter!.start)} - ${DateFormat('M/d').format(_dateFilter!.end)}')
                      : null,
                  onTap: () async {
                    Navigator.pop(ctx);
                    final range = await showDateRangePicker(
                      context: context,
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2030),
                      initialDateRange: _dateFilter,
                    );
                    if (range != null) {
                      setState(() {
                        _dateFilter = range;
                      });
                    }
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.clear_all),
                  title: const Text('清除筛选'),
                  onTap: () {
                    setState(() {
                      _dateFilter = null;
                      _categoryFilter = null;
                    });
                    Navigator.pop(ctx);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
