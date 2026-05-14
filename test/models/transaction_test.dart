import 'package:flutter_test/flutter_test.dart';
import 'package:pure_finance/models/transaction.dart';

void main() {
  group('Transaction', () {
    final sampleJson = {
      'id': 'txn-001',
      'type': 'TransactionType.expense',
      'amount': 42.50,
      'currency': 'CNY',
      'date': '2024-03-15T10:30:00.000',
      'categoryId': 'cat-001',
      'accountId': 'acc-001',
      'notes': 'Lunch at cafe',
      'tags': ['food', 'daily'],
      'isRecurring': false,
      'recurringId': null,
    };

    final sampleTransaction = Transaction(
      id: 'txn-001',
      type: TransactionType.expense,
      amount: 42.50,
      currency: 'CNY',
      date: DateTime.parse('2024-03-15T10:30:00.000'),
      categoryId: 'cat-001',
      accountId: 'acc-001',
      notes: 'Lunch at cafe',
      tags: ['food', 'daily'],
      isRecurring: false,
      recurringId: null,
    );

    test('fromJson creates correct object with all fields', () {
      final transaction = Transaction.fromJson(sampleJson);

      expect(transaction.id, 'txn-001');
      expect(transaction.type, TransactionType.expense);
      expect(transaction.amount, 42.50);
      expect(transaction.currency, 'CNY');
      expect(transaction.date, DateTime.parse('2024-03-15T10:30:00.000'));
      expect(transaction.categoryId, 'cat-001');
      expect(transaction.accountId, 'acc-001');
      expect(transaction.notes, 'Lunch at cafe');
      expect(transaction.tags, ['food', 'daily']);
      expect(transaction.isRecurring, false);
      expect(transaction.recurringId, isNull);
    });

    test('toJson produces correct map', () {
      final json = sampleTransaction.toJson();

      expect(json['id'], 'txn-001');
      expect(json['type'], 'TransactionType.expense');
      expect(json['amount'], 42.50);
      expect(json['currency'], 'CNY');
      expect(json['date'], '2024-03-15T10:30:00.000');
      expect(json['categoryId'], 'cat-001');
      expect(json['accountId'], 'acc-001');
      expect(json['notes'], 'Lunch at cafe');
      expect(json['tags'], ['food', 'daily']);
      expect(json['isRecurring'], false);
      expect(json['recurringId'], isNull);
    });

    test('fromJson -> toJson roundtrip preserves all data', () {
      final transaction = Transaction.fromJson(sampleJson);
      final outputJson = transaction.toJson();

      expect(outputJson['id'], sampleJson['id']);
      expect(outputJson['type'], sampleJson['type']);
      expect(outputJson['amount'], sampleJson['amount']);
      expect(outputJson['currency'], sampleJson['currency']);
      expect(outputJson['date'], sampleJson['date']);
      expect(outputJson['categoryId'], sampleJson['categoryId']);
      expect(outputJson['accountId'], sampleJson['accountId']);
      expect(outputJson['notes'], sampleJson['notes']);
      expect(outputJson['tags'], sampleJson['tags']);
      expect(outputJson['isRecurring'], sampleJson['isRecurring']);
      expect(outputJson['recurringId'], sampleJson['recurringId']);
    });

    test('all TransactionType enum values parse correctly', () {
      for (final type in TransactionType.values) {
        final json = Map<String, dynamic>.from(sampleJson);
        json['type'] = type.toString();
        final transaction = Transaction.fromJson(json);
        expect(transaction.type, type);
      }
    });

    test('TransactionType has expense, income, and transfer', () {
      expect(TransactionType.values, contains(TransactionType.expense));
      expect(TransactionType.values, contains(TransactionType.income));
      expect(TransactionType.values, contains(TransactionType.transfer));
      expect(TransactionType.values.length, 3);
    });

    test('copyWith updates fields correctly while preserving others', () {
      final updated = sampleTransaction.copyWith(
        amount: 99.99,
        notes: 'Updated note',
      );

      expect(updated.amount, 99.99);
      expect(updated.notes, 'Updated note');
      // Preserved fields
      expect(updated.id, sampleTransaction.id);
      expect(updated.type, sampleTransaction.type);
      expect(updated.currency, sampleTransaction.currency);
      expect(updated.date, sampleTransaction.date);
      expect(updated.categoryId, sampleTransaction.categoryId);
      expect(updated.accountId, sampleTransaction.accountId);
      expect(updated.tags, sampleTransaction.tags);
      expect(updated.isRecurring, sampleTransaction.isRecurring);
      expect(updated.recurringId, sampleTransaction.recurringId);
    });

    test('nullable fields handle null correctly', () {
      final json = Map<String, dynamic>.from(sampleJson);
      json['notes'] = null;
      json['tags'] = null;
      json['recurringId'] = null;

      final transaction = Transaction.fromJson(json);
      expect(transaction.notes, isNull);
      expect(transaction.tags, isNull);
      expect(transaction.recurringId, isNull);

      final outputJson = transaction.toJson();
      expect(outputJson['notes'], isNull);
      expect(outputJson['tags'], isNull);
      expect(outputJson['recurringId'], isNull);
    });

    test('copyWith with type changes transaction type', () {
      final income = sampleTransaction.copyWith(type: TransactionType.income);
      expect(income.type, TransactionType.income);
      expect(income.amount, sampleTransaction.amount);
    });

    test('copyWith with date changes date', () {
      final newDate = DateTime(2025, 1, 1);
      final updated = sampleTransaction.copyWith(date: newDate);
      expect(updated.date, newDate);
      expect(updated.id, sampleTransaction.id);
    });
  });
}
