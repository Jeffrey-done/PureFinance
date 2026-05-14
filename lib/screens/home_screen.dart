import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/transaction.dart';
import '../providers/transaction_provider.dart';
import '../providers/category_provider.dart';
import '../widgets/category_icon_widget.dart';
import '../widgets/empty_state_widget.dart';
import 'transaction/add_transaction_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PureFinance'),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await context.read<TransactionProvider>().loadTransactions();
        },
        child: Consumer<TransactionProvider>(
          builder: (context, txnProvider, _) {
            final now = DateTime.now();
            final monthlyExpense = txnProvider.getTotalExpense(now);
            final monthlyIncome = txnProvider.getTotalIncome(now);
            final balance = monthlyIncome - monthlyExpense;

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildSummarySection(context, monthlyExpense, monthlyIncome, balance),
                const SizedBox(height: 24),
                _buildRecentTransactions(context, txnProvider),
              ],
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const AddTransactionScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSummarySection(
    BuildContext context,
    double expense,
    double income,
    double balance,
  ) {
    final monthName = DateFormat('M月').format(DateTime.now());
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$monthName概览',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _SummaryCard(
                label: '支出',
                amount: expense,
                color: Colors.red,
                icon: Icons.arrow_downward,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _SummaryCard(
                label: '收入',
                amount: income,
                color: Colors.green,
                icon: Icons.arrow_upward,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _SummaryCard(
                label: '结余',
                amount: balance,
                color: balance >= 0 ? Colors.blue : Colors.orange,
                icon: Icons.account_balance_wallet,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRecentTransactions(BuildContext context, TransactionProvider provider) {
    final recent = provider.transactions.take(5).toList();
    final categoryProvider = context.read<CategoryProvider>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '最近交易',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            if (recent.isNotEmpty)
              TextButton(
                onPressed: () {
                  // Switch to transactions tab via parent
                },
                child: const Text('查看全部'),
              ),
          ],
        ),
        const SizedBox(height: 8),
        if (recent.isEmpty)
          const EmptyStateWidget(
            icon: Icons.receipt_long_outlined,
            message: '暂无交易记录\n点击右下角按钮添加第一笔交易',
          )
        else
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: recent.length,
              separatorBuilder: (_, __) => const Divider(height: 1, indent: 72),
              itemBuilder: (context, index) {
                final txn = recent[index];
                final category = categoryProvider.categories
                    .where((c) => c.id == txn.categoryId)
                    .firstOrNull;
                return _TransactionItem(transaction: txn, category: category);
              },
            ),
          ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String label;
  final double amount;
  final Color color;
  final IconData icon;

  const _SummaryCard({
    required this.label,
    required this.amount,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 14, color: color),
                const SizedBox(width: 4),
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              '\u00a5${amount.toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _TransactionItem extends StatelessWidget {
  final Transaction transaction;
  final dynamic category;

  const _TransactionItem({required this.transaction, this.category});

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
      subtitle: Text(
        transaction.notes ?? DateFormat('HH:mm').format(transaction.date),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.bodySmall,
      ),
      trailing: Text(
        '$sign\u00a5${transaction.amount.toStringAsFixed(2)}',
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}
