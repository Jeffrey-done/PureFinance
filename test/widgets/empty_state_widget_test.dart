import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pure_finance/widgets/empty_state_widget.dart';

void main() {
  group('EmptyStateWidget', () {
    testWidgets('renders icon and message text', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyStateWidget(
              icon: Icons.receipt_long,
              message: 'No transactions yet',
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.receipt_long), findsOneWidget);
      expect(find.text('No transactions yet'), findsOneWidget);
    });

    testWidgets('renders with different icon and message', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyStateWidget(
              icon: Icons.account_balance_wallet,
              message: 'No accounts found',
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.account_balance_wallet), findsOneWidget);
      expect(find.text('No accounts found'), findsOneWidget);
    });

    testWidgets('does not show action button when no action provided', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyStateWidget(
              icon: Icons.category,
              message: 'Empty',
            ),
          ),
        ),
      );

      expect(find.byType(FilledButton), findsNothing);
    });

    testWidgets('shows action button when action is provided', (WidgetTester tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyStateWidget(
              icon: Icons.add,
              message: 'Add something',
              actionLabel: 'Add Now',
              onAction: () => tapped = true,
            ),
          ),
        ),
      );

      expect(find.text('Add Now'), findsOneWidget);
      expect(find.byType(FilledButton), findsOneWidget);

      await tester.tap(find.byType(FilledButton));
      expect(tapped, true);
    });

    testWidgets('icon has size 64', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyStateWidget(
              icon: Icons.info,
              message: 'Test',
            ),
          ),
        ),
      );

      final icon = tester.widget<Icon>(find.byIcon(Icons.info));
      expect(icon.size, 64);
    });

    testWidgets('message text is centered', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyStateWidget(
              icon: Icons.info,
              message: 'Centered text',
            ),
          ),
        ),
      );

      final textWidget = tester.widget<Text>(find.text('Centered text'));
      expect(textWidget.textAlign, TextAlign.center);
    });
  });
}
