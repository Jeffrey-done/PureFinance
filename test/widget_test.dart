import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:pure_finance/main.dart';

void main() {
  testWidgets('App renders home page', (WidgetTester tester) async {
    await tester.pumpWidget(const PureFinanceApp());

    expect(find.text('PureFinance'), findsOneWidget);
    expect(find.text('Welcome to PureFinance'), findsOneWidget);
    expect(find.byIcon(Icons.add), findsOneWidget);
  });
}
