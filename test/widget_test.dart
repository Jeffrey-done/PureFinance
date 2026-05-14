import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:pure_finance/widgets/empty_state_widget.dart';
import 'package:pure_finance/widgets/category_icon_widget.dart';
import 'package:pure_finance/widgets/summary_card.dart';
import 'package:pure_finance/widgets/amount_display.dart';

void main() {
  testWidgets('EmptyStateWidget shows message and icon', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: EmptyStateWidget(
            icon: Icons.receipt_long,
            message: '暂无交易记录',
          ),
        ),
      ),
    );

    expect(find.text('暂无交易记录'), findsOneWidget);
    expect(find.byIcon(Icons.receipt_long), findsOneWidget);
  });

  testWidgets('CategoryIconWidget renders with color and icon', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: CategoryIconWidget(
            iconCode: '0xe56c',
            colorHex: '#FF6B6B',
            size: 40,
          ),
        ),
      ),
    );

    expect(find.byType(CategoryIconWidget), findsOneWidget);
  });

  testWidgets('SummaryCard displays label and value', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SummaryCard(
            label: '总资产',
            value: '\u00a510000.00',
          ),
        ),
      ),
    );

    expect(find.text('总资产'), findsOneWidget);
    expect(find.text('\u00a510000.00'), findsOneWidget);
  });

  testWidgets('AmountDisplay shows formatted expense', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AmountDisplay(
            amount: 100.50,
            isExpense: true,
          ),
        ),
      ),
    );

    expect(find.text('-\u00a5100.50'), findsOneWidget);
  });

  testWidgets('AmountDisplay shows formatted income', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AmountDisplay(
            amount: 5000.00,
            isExpense: false,
          ),
        ),
      ),
    );

    expect(find.text('+\u00a55000.00'), findsOneWidget);
  });
}
