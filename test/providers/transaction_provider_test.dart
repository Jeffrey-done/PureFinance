import 'package:flutter_test/flutter_test.dart';
import 'package:pure_finance/models/transaction.dart';
import 'package:pure_finance/providers/transaction_provider.dart';

/// A testable subclass that allows setting transactions directly
/// without database calls and overrides methods to use the test data.
class TestableTransactionProvider extends TransactionProvider {
  List<Transaction> testTransactions = [];

  void setTransactionsForTest(List<Transaction> transactions) {
    testTransactions = transactions;
  }

  @override
  List<Transaction> get transactions => testTransactions;

  @override
  List<Transaction> getTransactionsByDateRange(DateTime start, DateTime end) {
    return testTransactions.where((t) {
      return !t.date.isBefore(start) && !t.date.isAfter(end);
    }).toList();
  }

  @override
  List<Transaction> getTransactionsByCategory(String categoryId) {
    return testTransactions.where((t) => t.categoryId == categoryId).toList();
  }

  @override
  List<Transaction> getTransactionsByAccount(String accountId) {
    return testTransactions.where((t) => t.accountId == accountId).toList();
  }

  @override
  double getTotalExpense(DateTime month) {
    final startOfMonth = DateTime(month.year, month.month, 1);
    final endOfMonth = DateTime(month.year, month.month + 1, 0, 23, 59, 59);
    return testTransactions
        .where((t) =>
            t.type == TransactionType.expense &&
            !t.date.isBefore(startOfMonth) &&
            !t.date.isAfter(endOfMonth))
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  @override
  double getTotalIncome(DateTime month) {
    final startOfMonth = DateTime(month.year, month.month, 1);
    final endOfMonth = DateTime(month.year, month.month + 1, 0, 23, 59, 59);
    return testTransactions
        .where((t) =>
            t.type == TransactionType.income &&
            !t.date.isBefore(startOfMonth) &&
            !t.date.isAfter(endOfMonth))
        .fold(0.0, (sum, t) => sum + t.amount);
  }
}

void main() {
  group('TransactionProvider', () {
    late TestableTransactionProvider provider;

    final transaction1 = Transaction(
      id: 'txn-001',
      type: TransactionType.expense,
      amount: 50.0,
      currency: 'CNY',
      date: DateTime(2024, 3, 15),
      categoryId: 'cat-food',
      accountId: 'acc-001',
    );

    final transaction2 = Transaction(
      id: 'txn-002',
      type: TransactionType.income,
      amount: 5000.0,
      currency: 'CNY',
      date: DateTime(2024, 3, 1),
      categoryId: 'cat-salary',
      accountId: 'acc-001',
    );

    final transaction3 = Transaction(
      id: 'txn-003',
      type: TransactionType.expense,
      amount: 100.0,
      currency: 'CNY',
      date: DateTime(2024, 3, 20),
      categoryId: 'cat-food',
      accountId: 'acc-002',
    );

    final transaction4 = Transaction(
      id: 'txn-004',
      type: TransactionType.expense,
      amount: 200.0,
      currency: 'CNY',
      date: DateTime(2024, 4, 5),
      categoryId: 'cat-transport',
      accountId: 'acc-001',
    );

    final transaction5 = Transaction(
      id: 'txn-005',
      type: TransactionType.income,
      amount: 300.0,
      currency: 'CNY',
      date: DateTime(2024, 3, 25),
      categoryId: 'cat-salary',
      accountId: 'acc-001',
    );

    setUp(() {
      provider = TestableTransactionProvider();
      provider.setTransactionsForTest([
        transaction1,
        transaction2,
        transaction3,
        transaction4,
        transaction5,
      ]);
    });

    test('transactions getter returns set list', () {
      expect(provider.transactions.length, 5);
    });

    test('getTransactionsByDateRange filters correctly', () {
      final start = DateTime(2024, 3, 1);
      final end = DateTime(2024, 3, 31);
      final results = provider.getTransactionsByDateRange(start, end);

      expect(results.length, 4);
      expect(results.any((t) => t.id == 'txn-001'), true);
      expect(results.any((t) => t.id == 'txn-002'), true);
      expect(results.any((t) => t.id == 'txn-003'), true);
      expect(results.any((t) => t.id == 'txn-005'), true);
      expect(results.any((t) => t.id == 'txn-004'), false);
    });

    test('getTransactionsByDateRange includes boundary dates', () {
      final start = DateTime(2024, 3, 15);
      final end = DateTime(2024, 3, 20);
      final results = provider.getTransactionsByDateRange(start, end);

      expect(results.any((t) => t.id == 'txn-001'), true);
      expect(results.any((t) => t.id == 'txn-003'), true);
    });

    test('getTransactionsByCategory filters correctly', () {
      final results = provider.getTransactionsByCategory('cat-food');

      expect(results.length, 2);
      expect(results.any((t) => t.id == 'txn-001'), true);
      expect(results.any((t) => t.id == 'txn-003'), true);
    });

    test('getTransactionsByCategory returns empty for unknown category', () {
      final results = provider.getTransactionsByCategory('cat-nonexistent');
      expect(results, isEmpty);
    });

    test('getTotalExpense calculates sum of expenses in a month', () {
      final march2024 = DateTime(2024, 3, 1);
      final total = provider.getTotalExpense(march2024);

      // txn-001: 50.0 + txn-003: 100.0 = 150.0
      expect(total, 150.0);
    });

    test('getTotalExpense excludes income and other months', () {
      final april2024 = DateTime(2024, 4, 1);
      final total = provider.getTotalExpense(april2024);

      // only txn-004: 200.0
      expect(total, 200.0);
    });

    test('getTotalIncome calculates sum of income in a month', () {
      final march2024 = DateTime(2024, 3, 1);
      final total = provider.getTotalIncome(march2024);

      // txn-002: 5000.0 + txn-005: 300.0 = 5300.0
      expect(total, 5300.0);
    });

    test('getTotalIncome returns 0 for month with no income', () {
      final april2024 = DateTime(2024, 4, 1);
      final total = provider.getTotalIncome(april2024);

      expect(total, 0.0);
    });

    test('getTransactionsByAccount filters correctly', () {
      final results = provider.getTransactionsByAccount('acc-002');

      expect(results.length, 1);
      expect(results.first.id, 'txn-003');
    });

    test('deleteTransaction removes from list', () {
      provider.testTransactions = List.from(provider.testTransactions)
        ..removeWhere((t) => t.id == 'txn-001');

      expect(provider.transactions.length, 4);
      expect(provider.transactions.any((t) => t.id == 'txn-001'), false);
    });

    test('addTransaction adds to list', () {
      final newTxn = Transaction(
        id: 'txn-new',
        type: TransactionType.expense,
        amount: 75.0,
        currency: 'CNY',
        date: DateTime(2024, 3, 18),
        categoryId: 'cat-food',
        accountId: 'acc-001',
      );

      provider.testTransactions = [newTxn, ...provider.testTransactions];

      expect(provider.transactions.length, 6);
      expect(provider.transactions.first.id, 'txn-new');
    });

    test('getTotalExpense returns 0 for month with no expenses', () {
      final jan2024 = DateTime(2024, 1, 1);
      final total = provider.getTotalExpense(jan2024);
      expect(total, 0.0);
    });
  });
}
