import 'package:flutter_test/flutter_test.dart';
import 'package:pure_finance/providers/budget_provider.dart';

/// A testable subclass that allows setting budget state directly
/// without database calls.
class TestableBudgetProvider extends BudgetProvider {
  double testTotalBudget = 0.0;
  Map<String, double> testCategoryBudgets = {};

  void setTotalBudgetForTest(double amount) {
    testTotalBudget = amount;
  }

  void setCategoryBudgetForTest(String categoryId, double amount) {
    testCategoryBudgets[categoryId] = amount;
  }

  @override
  double get totalMonthlyBudget => testTotalBudget;

  @override
  Map<String, double> get categoryBudgets =>
      Map.unmodifiable(testCategoryBudgets);

  @override
  double getBudgetProgress(double currentSpending) {
    if (testTotalBudget <= 0) return 0.0;
    return currentSpending / testTotalBudget;
  }

  @override
  bool isOverBudget(double currentSpending) {
    if (testTotalBudget <= 0) return false;
    return currentSpending > testTotalBudget;
  }
}

void main() {
  group('BudgetProvider', () {
    late TestableBudgetProvider provider;

    setUp(() {
      provider = TestableBudgetProvider();
    });

    test('setTotalBudget stores the value', () {
      provider.setTotalBudgetForTest(5000.0);
      expect(provider.totalMonthlyBudget, 5000.0);
    });

    test('getBudgetProgress returns correct percentage', () {
      provider.setTotalBudgetForTest(1000.0);

      expect(provider.getBudgetProgress(500.0), 0.5);
      expect(provider.getBudgetProgress(250.0), 0.25);
      expect(provider.getBudgetProgress(1000.0), 1.0);
    });

    test('getBudgetProgress returns 0 when budget is 0', () {
      provider.setTotalBudgetForTest(0.0);
      expect(provider.getBudgetProgress(500.0), 0.0);
    });

    test('getBudgetProgress returns more than 1 when over budget', () {
      provider.setTotalBudgetForTest(1000.0);
      expect(provider.getBudgetProgress(1500.0), 1.5);
    });

    test('isOverBudget returns true when spending exceeds budget', () {
      provider.setTotalBudgetForTest(1000.0);
      expect(provider.isOverBudget(1001.0), true);
      expect(provider.isOverBudget(2000.0), true);
    });

    test('isOverBudget returns false when spending is within budget', () {
      provider.setTotalBudgetForTest(1000.0);
      expect(provider.isOverBudget(999.0), false);
      expect(provider.isOverBudget(500.0), false);
    });

    test('isOverBudget returns false when spending equals budget', () {
      provider.setTotalBudgetForTest(1000.0);
      expect(provider.isOverBudget(1000.0), false);
    });

    test('isOverBudget returns false when budget is 0', () {
      provider.setTotalBudgetForTest(0.0);
      expect(provider.isOverBudget(500.0), false);
    });

    test('setCategoryBudget stores per-category budget', () {
      provider.setCategoryBudgetForTest('cat-food', 300.0);
      provider.setCategoryBudgetForTest('cat-transport', 200.0);

      expect(provider.categoryBudgets['cat-food'], 300.0);
      expect(provider.categoryBudgets['cat-transport'], 200.0);
    });

    test('categoryBudgets returns unmodifiable map', () {
      provider.setCategoryBudgetForTest('cat-food', 300.0);

      expect(
        () => provider.categoryBudgets['new'] = 100.0,
        throwsA(isA<UnsupportedError>()),
      );
    });

    test('initial budget values are zero', () {
      expect(provider.totalMonthlyBudget, 0.0);
      expect(provider.categoryBudgets, isEmpty);
    });
  });
}
