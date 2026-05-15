import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/category.dart';
import '../../providers/budget_provider.dart';
import '../../providers/category_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../widgets/category_icon_widget.dart';
import '../../widgets/empty_state_widget.dart';

class BudgetScreen extends StatelessWidget {
  const BudgetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('预算'),
      ),
      body: Consumer3<BudgetProvider, TransactionProvider, CategoryProvider>(
        builder: (context, budgetProvider, txnProvider, categoryProvider, _) {
          final now = DateTime.now();
          final totalExpense = txnProvider.getTotalExpense(now);
          final totalBudget = budgetProvider.totalMonthlyBudget;
          final progress = totalBudget > 0 ? totalExpense / totalBudget : 0.0;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildTotalBudgetCard(context, totalExpense, totalBudget, progress),
              const SizedBox(height: 16),
              _buildSetBudgetButton(context, budgetProvider, totalBudget),
              const SizedBox(height: 24),
              _buildCategoryBudgets(
                context,
                budgetProvider,
                txnProvider,
                categoryProvider,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTotalBudgetCard(
    BuildContext context,
    double spent,
    double budget,
    double progress,
  ) {
    final clampedProgress = progress.clamp(0.0, 1.0);
    final color = progress < 0.7
        ? Colors.green
        : progress < 0.9
            ? Colors.orange
            : Colors.red;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            SizedBox(
              width: 120,
              height: 120,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CircularProgressIndicator(
                    value: clampedProgress,
                    strokeWidth: 10,
                    backgroundColor: color.withValues(alpha: 0.2),
                    color: color,
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${(progress * 100).toStringAsFixed(0)}%',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: color,
                            ),
                      ),
                      Text(
                        '已使用',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '\u00a5${spent.toStringAsFixed(2)} / \u00a5${budget.toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            if (budget > 0)
              Text(
                '剩余 \u00a5${(budget - spent).clamp(0, double.infinity).toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.outline,
                    ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSetBudgetButton(
    BuildContext context,
    BudgetProvider provider,
    double currentBudget,
  ) {
    return Center(
      child: OutlinedButton.icon(
        onPressed: () => _showBudgetDialog(context, provider, currentBudget),
        icon: const Icon(Icons.edit),
        label: Text(currentBudget > 0 ? '修改月度预算' : '设置月度预算'),
      ),
    );
  }

  Widget _buildCategoryBudgets(
    BuildContext context,
    BudgetProvider budgetProvider,
    TransactionProvider txnProvider,
    CategoryProvider categoryProvider,
  ) {
    final categoryBudgets = budgetProvider.categoryBudgets;
    final expenseCategories = categoryProvider.getExpenseCategories();

    final budgetedCategories = expenseCategories
        .where((c) => categoryBudgets.containsKey(c.id))
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('分类预算', style: Theme.of(context).textTheme.titleMedium),
            TextButton.icon(
              onPressed: () => _showAddCategoryBudgetDialog(
                context,
                budgetProvider,
                expenseCategories,
                categoryBudgets,
              ),
              icon: const Icon(Icons.add, size: 16),
              label: const Text('添加'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (budgetedCategories.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: EmptyStateWidget(
              icon: Icons.pie_chart_outline,
              message: '暂未设置分类预算',
            ),
          )
        else
          ...budgetedCategories.map((category) {
            final budget = categoryBudgets[category.id] ?? 0;
            final now = DateTime.now();
            final categoryTxns = txnProvider.getTransactionsByCategory(category.id);
            final startOfMonth = DateTime(now.year, now.month, 1);
            final endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
            final spent = categoryTxns
                .where((t) =>
                    !t.date.isBefore(startOfMonth) && !t.date.isAfter(endOfMonth))
                .fold(0.0, (sum, t) => sum + t.amount);
            final progress = budget > 0 ? spent / budget : 0.0;
            final clampedProgress = progress.clamp(0.0, 1.0);
            final color = progress < 0.7
                ? Colors.green
                : progress < 0.9
                    ? Colors.orange
                    : Colors.red;

            return Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: CategoryIconWidget(
                  iconCode: category.icon,
                  colorHex: category.color,
                ),
                title: Text(category.name),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: clampedProgress,
                        backgroundColor: color.withValues(alpha: 0.2),
                        color: color,
                        minHeight: 6,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '\u00a5${spent.toStringAsFixed(2)} / \u00a5${budget.toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
                onTap: () => _showEditCategoryBudgetDialog(
                  context,
                  budgetProvider,
                  category,
                  budget,
                ),
              ),
            );
          }),
      ],
    );
  }

  void _showBudgetDialog(BuildContext context, BudgetProvider provider, double current) {
    final controller = TextEditingController(
      text: current > 0 ? current.toStringAsFixed(2) : '',
    );
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('设置月度预算'),
          content: TextField(
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: '预算金额',
              prefixText: '\u00a5 ',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('取消'),
            ),
            FilledButton(
              onPressed: () {
                final amount = double.tryParse(controller.text);
                if (amount != null && amount > 0) {
                  provider.setTotalBudget(amount);
                }
                Navigator.pop(ctx);
              },
              child: const Text('保存'),
            ),
          ],
        );
      },
    );
  }

  void _showAddCategoryBudgetDialog(
    BuildContext context,
    BudgetProvider provider,
    List<Category> categories,
    Map<String, double> existingBudgets,
  ) {
    final available = categories.where((c) => !existingBudgets.containsKey(c.id)).toList();
    if (available.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('所有分类已设置预算')),
      );
      return;
    }

    String? selectedId = available.first.id;
    final amountController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('添加分类预算'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    value: selectedId,
                    decoration: const InputDecoration(labelText: '分类'),
                    items: available.map((c) {
                      return DropdownMenuItem(value: c.id, child: Text(c.name));
                    }).toList(),
                    onChanged: (value) {
                      setDialogState(() {
                        selectedId = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: amountController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: '预算金额',
                      prefixText: '\u00a5 ',
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('取消'),
                ),
                FilledButton(
                  onPressed: () {
                    final amount = double.tryParse(amountController.text);
                    if (selectedId != null && amount != null && amount > 0) {
                      provider.setCategoryBudget(selectedId!, amount);
                    }
                    Navigator.pop(ctx);
                  },
                  child: const Text('保存'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showEditCategoryBudgetDialog(
    BuildContext context,
    BudgetProvider provider,
    Category category,
    double currentBudget,
  ) {
    final controller = TextEditingController(text: currentBudget.toStringAsFixed(2));
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text('${category.name} 预算'),
          content: TextField(
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: '预算金额',
              prefixText: '\u00a5 ',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                provider.removeCategoryBudget(category.id);
                Navigator.pop(ctx);
              },
              child: const Text('删除', style: TextStyle(color: Colors.red)),
            ),
            FilledButton(
              onPressed: () {
                final amount = double.tryParse(controller.text);
                if (amount != null && amount > 0) {
                  provider.setCategoryBudget(category.id, amount);
                }
                Navigator.pop(ctx);
              },
              child: const Text('保存'),
            ),
          ],
        );
      },
    );
  }
}
