import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pure_finance/widgets/amount_display.dart';

void main() {
  group('AmountDisplay', () {
    testWidgets('renders formatted amount text for expense', (WidgetTester tester) async {
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

    testWidgets('renders formatted amount text for income', (WidgetTester tester) async {
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

    testWidgets('expense amount shows red color', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AmountDisplay(
              amount: 42.00,
              isExpense: true,
            ),
          ),
        ),
      );

      final textWidget = tester.widget<Text>(find.text('-\u00a542.00'));
      expect(textWidget.style?.color, Colors.red);
    });

    testWidgets('income amount shows green color', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AmountDisplay(
              amount: 1000.00,
              isExpense: false,
            ),
          ),
        ),
      );

      final textWidget = tester.widget<Text>(find.text('+\u00a51000.00'));
      expect(textWidget.style?.color, Colors.green);
    });

    testWidgets('formats amount with two decimal places', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AmountDisplay(
              amount: 7.5,
              isExpense: true,
            ),
          ),
        ),
      );

      expect(find.text('-\u00a57.50'), findsOneWidget);
    });

    testWidgets('uses USD symbol for USD currency', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AmountDisplay(
              amount: 99.99,
              currency: 'USD',
              isExpense: true,
            ),
          ),
        ),
      );

      expect(find.text('-\$99.99'), findsOneWidget);
    });

    testWidgets('uses EUR symbol for EUR currency', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AmountDisplay(
              amount: 50.00,
              currency: 'EUR',
              isExpense: false,
            ),
          ),
        ),
      );

      expect(find.text('+\u20ac50.00'), findsOneWidget);
    });

    testWidgets('hides sign when showSign is false', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AmountDisplay(
              amount: 100.00,
              isExpense: true,
              showSign: false,
            ),
          ),
        ),
      );

      expect(find.text('\u00a5100.00'), findsOneWidget);
    });
  });
}
