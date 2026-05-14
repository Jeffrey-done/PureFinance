import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/account.dart';
import '../../providers/account_provider.dart';
import '../../widgets/empty_state_widget.dart';
import 'add_account_screen.dart';

class AccountListScreen extends StatelessWidget {
  const AccountListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('账户管理'),
      ),
      body: Consumer<AccountProvider>(
        builder: (context, provider, _) {
          final accounts = provider.accounts;

          if (accounts.isEmpty) {
            return const EmptyStateWidget(
              icon: Icons.account_balance_wallet_outlined,
              message: '暂无账户\n点击右下角按钮添加账户',
            );
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildSummaryCard(context, provider),
              const SizedBox(height: 16),
              ...accounts.map((account) => _buildAccountCard(context, account)),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const AddAccountScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSummaryCard(BuildContext context, AccountProvider provider) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _SummaryItem(
              label: '总资产',
              value: '\u00a5${provider.getTotalAssets.toStringAsFixed(2)}',
              color: Colors.green,
            ),
            _SummaryItem(
              label: '总负债',
              value: '\u00a5${provider.getTotalLiabilities.toStringAsFixed(2)}',
              color: Colors.red,
            ),
            _SummaryItem(
              label: '净资产',
              value: '\u00a5${provider.getNetWorth.toStringAsFixed(2)}',
              color: Colors.blue,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountCard(BuildContext context, Account account) {
    final typeLabels = {
      AccountType.cash: '现金',
      AccountType.bank: '银行卡',
      AccountType.creditCard: '信用卡',
      AccountType.investment: '投资',
    };

    final typeIcons = {
      AccountType.cash: Icons.money,
      AccountType.bank: Icons.account_balance,
      AccountType.creditCard: Icons.credit_card,
      AccountType.investment: Icons.trending_up,
    };

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _parseColor(account.color) ??
              Theme.of(context).colorScheme.primaryContainer,
          child: Icon(
            typeIcons[account.type] ?? Icons.account_balance_wallet,
            color: Colors.white,
            size: 20,
          ),
        ),
        title: Text(
          account.name,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w500,
              ),
        ),
        subtitle: Text(typeLabels[account.type] ?? ''),
        trailing: Text(
          '\u00a5${account.balance.toStringAsFixed(2)}',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: account.balance >= 0 ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold,
              ),
        ),
        onTap: () {
          // Navigate to transactions filtered by this account
          // This can be expanded later
        },
        onLongPress: () {
          _showAccountMenu(context, account);
        },
      ),
    );
  }

  void _showAccountMenu(BuildContext context, Account account) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('编辑'),
                onTap: () {
                  Navigator.pop(ctx);
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => AddAccountScreen(account: account),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('删除', style: TextStyle(color: Colors.red)),
                onTap: () async {
                  Navigator.pop(ctx);
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (dCtx) => AlertDialog(
                      title: const Text('确认删除'),
                      content: const Text('确定要删除这个账户吗？相关交易将保留。'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(dCtx).pop(false),
                          child: const Text('取消'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(dCtx).pop(true),
                          child: const Text('删除'),
                        ),
                      ],
                    ),
                  );
                  if (confirm == true && context.mounted) {
                    context.read<AccountProvider>().deleteAccount(account.id);
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Color? _parseColor(String? hex) {
    if (hex == null || hex.isEmpty) return null;
    final hexStr = hex.replaceFirst('#', '');
    if (hexStr.length == 6) {
      return Color(int.parse('FF$hexStr', radix: 16));
    }
    return null;
  }
}

class _SummaryItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _SummaryItem({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.outline,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
        ),
      ],
    );
  }
}
