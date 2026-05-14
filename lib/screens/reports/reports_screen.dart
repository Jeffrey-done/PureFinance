import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/transaction.dart';
import '../../providers/transaction_provider.dart';
import '../../providers/category_provider.dart';
import '../../widgets/empty_state_widget.dart';

enum TimeRange { week, month, year }

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  TimeRange _selectedRange = TimeRange.month;

  DateTimeRange get _dateRange {
    final now = DateTime.now();
    switch (_selectedRange) {
      case TimeRange.week:
        final start = now.subtract(Duration(days: now.weekday - 1));
        return DateTimeRange(
          start: DateTime(start.year, start.month, start.day),
          end: now,
        );
      case TimeRange.month:
        return DateTimeRange(
          start: DateTime(now.year, now.month, 1),
          end: now,
        );
      case TimeRange.year:
        return DateTimeRange(
          start: DateTime(now.year, 1, 1),
          end: now,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('报表'),
      ),
      body: Consumer2<TransactionProvider, CategoryProvider>(
        builder: (context, txnProvider, categoryProvider, _) {
          final range = _dateRange;
          final transactions = txnProvider.getTransactionsByDateRange(range.start, range.end);

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildTimeRangeSelector(),
              const SizedBox(height: 8),
              Text(
                '${DateFormat('M月d日').format(range.start)} - ${DateFormat('M月d日').format(range.end)}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.outline,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              _buildExpenseTrendCard(context, transactions),
              const SizedBox(height: 16),
              _buildCategoryBreakdownCard(context, transactions, categoryProvider),
              const SizedBox(height: 16),
              _buildIncomeVsExpenseCard(context, txnProvider),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTimeRangeSelector() {
    return SegmentedButton<TimeRange>(
      segments: const [
        ButtonSegment(value: TimeRange.week, label: Text('本周')),
        ButtonSegment(value: TimeRange.month, label: Text('本月')),
        ButtonSegment(value: TimeRange.year, label: Text('本年')),
      ],
      selected: {_selectedRange},
      onSelectionChanged: (selected) {
        setState(() {
          _selectedRange = selected.first;
        });
      },
    );
  }

  Widget _buildExpenseTrendCard(BuildContext context, List<Transaction> transactions) {
    final expenses = transactions.where((t) => t.type == TransactionType.expense).toList();

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('支出趋势', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),
            if (expenses.isEmpty)
              const SizedBox(
                height: 200,
                child: EmptyStateWidget(
                  icon: Icons.show_chart,
                  message: '暂无数据',
                ),
              )
            else
              SizedBox(
                height: 200,
                child: _ExpenseTrendChart(
                  expenses: expenses,
                  range: _selectedRange,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryBreakdownCard(
    BuildContext context,
    List<Transaction> transactions,
    CategoryProvider categoryProvider,
  ) {
    final expenses = transactions.where((t) => t.type == TransactionType.expense).toList();
    final categoryTotals = <String, double>{};
    for (final txn in expenses) {
      categoryTotals[txn.categoryId] = (categoryTotals[txn.categoryId] ?? 0) + txn.amount;
    }

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('分类占比', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),
            if (categoryTotals.isEmpty)
              const SizedBox(
                height: 200,
                child: EmptyStateWidget(
                  icon: Icons.pie_chart_outline,
                  message: '暂无数据',
                ),
              )
            else
              SizedBox(
                height: 200,
                child: _CategoryPieChart(
                  categoryTotals: categoryTotals,
                  categoryProvider: categoryProvider,
                ),
              ),
            if (categoryTotals.isNotEmpty) ...[
              const SizedBox(height: 16),
              _buildLegend(context, categoryTotals, categoryProvider),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildLegend(
    BuildContext context,
    Map<String, double> categoryTotals,
    CategoryProvider categoryProvider,
  ) {
    final total = categoryTotals.values.fold(0.0, (sum, v) => sum + v);
    final sorted = categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Column(
      children: sorted.take(5).map((entry) {
        final category = categoryProvider.categories
            .where((c) => c.id == entry.key)
            .firstOrNull;
        final percentage = total > 0 ? (entry.value / total * 100) : 0;
        final color = _parseColor(category?.color);

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 8),
              Expanded(child: Text(category?.name ?? '未知')),
              Text(
                '${percentage.toStringAsFixed(1)}%',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(width: 8),
              Text(
                '\u00a5${entry.value.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildIncomeVsExpenseCard(BuildContext context, TransactionProvider provider) {
    final now = DateTime.now();
    final months = <DateTime>[];
    for (int i = 5; i >= 0; i--) {
      months.add(DateTime(now.year, now.month - i, 1));
    }

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('收支对比', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: _IncomeExpenseBarChart(
                provider: provider,
                months: months,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _parseColor(String? hex) {
    if (hex == null || hex.isEmpty) return Colors.grey;
    final hexStr = hex.replaceFirst('#', '');
    if (hexStr.length == 6) {
      return Color(int.parse('FF$hexStr', radix: 16));
    }
    return Colors.grey;
  }
}

class _ExpenseTrendChart extends StatelessWidget {
  final List<Transaction> expenses;
  final TimeRange range;

  const _ExpenseTrendChart({required this.expenses, required this.range});

  @override
  Widget build(BuildContext context) {
    final dailyTotals = <int, double>{};
    for (final txn in expenses) {
      final day = txn.date.day;
      dailyTotals[day] = (dailyTotals[day] ?? 0) + txn.amount;
    }

    if (dailyTotals.isEmpty) {
      return const Center(child: Text('暂无数据'));
    }

    final spots = dailyTotals.entries
        .map((e) => FlSpot(e.key.toDouble(), e.value))
        .toList()
      ..sort((a, b) => a.x.compareTo(b.x));

    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: false),
        titlesData: FlTitlesData(
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (value, meta) {
                return Text(
                  '${value.toInt()}',
                  style: const TextStyle(fontSize: 10),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: Colors.red,
            barWidth: 2,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: Colors.red.withOpacity(0.1),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryPieChart extends StatelessWidget {
  final Map<String, double> categoryTotals;
  final CategoryProvider categoryProvider;

  const _CategoryPieChart({
    required this.categoryTotals,
    required this.categoryProvider,
  });

  @override
  Widget build(BuildContext context) {
    final total = categoryTotals.values.fold(0.0, (sum, v) => sum + v);
    final sections = categoryTotals.entries.map((entry) {
      final category = categoryProvider.categories
          .where((c) => c.id == entry.key)
          .firstOrNull;
      final color = _parseColor(category?.color);
      final percentage = total > 0 ? entry.value / total * 100 : 0;

      return PieChartSectionData(
        value: entry.value,
        color: color,
        title: '${percentage.toStringAsFixed(0)}%',
        titleStyle: const TextStyle(fontSize: 10, color: Colors.white),
        radius: 60,
      );
    }).toList();

    return PieChart(
      PieChartData(
        sections: sections,
        centerSpaceRadius: 30,
        sectionsSpace: 2,
      ),
    );
  }

  Color _parseColor(String? hex) {
    if (hex == null || hex.isEmpty) return Colors.grey;
    final hexStr = hex.replaceFirst('#', '');
    if (hexStr.length == 6) {
      return Color(int.parse('FF$hexStr', radix: 16));
    }
    return Colors.grey;
  }
}

class _IncomeExpenseBarChart extends StatelessWidget {
  final TransactionProvider provider;
  final List<DateTime> months;

  const _IncomeExpenseBarChart({required this.provider, required this.months});

  @override
  Widget build(BuildContext context) {
    final barGroups = <BarChartGroupData>[];
    for (int i = 0; i < months.length; i++) {
      final month = months[i];
      final expense = provider.getTotalExpense(month);
      final income = provider.getTotalIncome(month);
      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: income,
              color: Colors.green,
              width: 8,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
            ),
            BarChartRodData(
              toY: expense,
              color: Colors.red,
              width: 8,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
            ),
          ],
        ),
      );
    }

    return BarChart(
      BarChartData(
        gridData: const FlGridData(show: false),
        titlesData: FlTitlesData(
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final idx = value.toInt();
                if (idx < 0 || idx >= months.length) return const Text('');
                return Text(
                  '${months[idx].month}月',
                  style: const TextStyle(fontSize: 10),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        barGroups: barGroups,
      ),
    );
  }
}
