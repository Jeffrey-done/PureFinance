import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/recurring_transaction.dart';
import '../../providers/subscription_provider.dart';
import '../../widgets/empty_state_widget.dart';
import 'add_subscription_screen.dart';

class SubscriptionListScreen extends StatelessWidget {
  const SubscriptionListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('订阅管理'),
      ),
      body: Consumer<SubscriptionProvider>(
        builder: (context, provider, _) {
          final subscriptions = provider.subscriptions;

          if (subscriptions.isEmpty) {
            return const EmptyStateWidget(
              icon: Icons.subscriptions_outlined,
              message: '暂无订阅\n点击右下角按钮添加订阅',
            );
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildSummaryCard(context, provider),
              const SizedBox(height: 16),
              ...subscriptions.map((sub) => _buildSubscriptionCard(context, sub)),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const AddSubscriptionScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSummaryCard(BuildContext context, SubscriptionProvider provider) {
    final active = provider.getActiveSubscriptions();
    final monthlyTotal = provider.getMonthlyTotal();

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Column(
              children: [
                Text(
                  '月度订阅总额',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  '\u00a5${monthlyTotal.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                ),
              ],
            ),
            Column(
              children: [
                Text(
                  '活跃订阅',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${active.length}',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubscriptionCard(BuildContext context, RecurringTransaction sub) {
    final frequencyLabels = {
      Frequency.monthly: '月付',
      Frequency.quarterly: '季付',
      Frequency.yearly: '年付',
      Frequency.custom: '自定义',
    };

    final statusColors = {
      SubscriptionStatus.active: Colors.green,
      SubscriptionStatus.paused: Colors.orange,
      SubscriptionStatus.cancelled: Colors.red,
    };

    return Dismissible(
      key: Key(sub.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        color: Colors.orange,
        child: const Icon(Icons.pause, color: Colors.white),
      ),
      confirmDismiss: (direction) async {
        return await _showPauseDialog(context, sub);
      },
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.only(bottom: 8),
        child: ListTile(
          leading: Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: statusColors[sub.status],
              shape: BoxShape.circle,
            ),
          ),
          title: Text(
            sub.name,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
          ),
          subtitle: Text(
            '下次扣费: ${DateFormat('yyyy年M月d日').format(sub.nextDueDate)}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '\u00a5${sub.amount.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  frequencyLabels[sub.frequency] ?? '',
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ),
            ],
          ),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => AddSubscriptionScreen(subscription: sub),
              ),
            );
          },
        ),
      ),
    );
  }

  Future<bool> _showPauseDialog(BuildContext context, RecurringTransaction sub) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('暂停订阅'),
          content: Text('确定要暂停"${sub.name}"吗？'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () {
                context.read<SubscriptionProvider>().updateSubscription(
                      sub.copyWith(status: SubscriptionStatus.paused),
                    );
                Navigator.pop(ctx, false);
              },
              child: const Text('暂停'),
            ),
          ],
        );
      },
    );
    return result ?? false;
  }
}
