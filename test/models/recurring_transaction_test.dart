import 'package:flutter_test/flutter_test.dart';
import 'package:pure_finance/models/recurring_transaction.dart';

void main() {
  group('RecurringTransaction', () {
    final sampleJson = {
      'id': 'rec-001',
      'name': 'Netflix',
      'amount': 15.99,
      'currency': 'CNY',
      'startDate': '2024-01-01T00:00:00.000',
      'nextDueDate': '2024-04-01T00:00:00.000',
      'frequency': 'Frequency.monthly',
      'categoryId': 'cat-005',
      'accountId': 'acc-001',
      'notes': 'Streaming subscription',
      'status': 'SubscriptionStatus.active',
      'remindBeforeDays': 3,
    };

    final sampleRecurring = RecurringTransaction(
      id: 'rec-001',
      name: 'Netflix',
      amount: 15.99,
      currency: 'CNY',
      startDate: DateTime.parse('2024-01-01T00:00:00.000'),
      nextDueDate: DateTime.parse('2024-04-01T00:00:00.000'),
      frequency: Frequency.monthly,
      categoryId: 'cat-005',
      accountId: 'acc-001',
      notes: 'Streaming subscription',
      status: SubscriptionStatus.active,
      remindBeforeDays: 3,
    );

    test('fromJson creates correct object with all fields', () {
      final recurring = RecurringTransaction.fromJson(sampleJson);

      expect(recurring.id, 'rec-001');
      expect(recurring.name, 'Netflix');
      expect(recurring.amount, 15.99);
      expect(recurring.currency, 'CNY');
      expect(recurring.startDate, DateTime.parse('2024-01-01T00:00:00.000'));
      expect(recurring.nextDueDate, DateTime.parse('2024-04-01T00:00:00.000'));
      expect(recurring.frequency, Frequency.monthly);
      expect(recurring.categoryId, 'cat-005');
      expect(recurring.accountId, 'acc-001');
      expect(recurring.notes, 'Streaming subscription');
      expect(recurring.status, SubscriptionStatus.active);
      expect(recurring.remindBeforeDays, 3);
    });

    test('toJson produces correct map', () {
      final json = sampleRecurring.toJson();

      expect(json['id'], 'rec-001');
      expect(json['name'], 'Netflix');
      expect(json['amount'], 15.99);
      expect(json['currency'], 'CNY');
      expect(json['startDate'], '2024-01-01T00:00:00.000');
      expect(json['nextDueDate'], '2024-04-01T00:00:00.000');
      expect(json['frequency'], 'Frequency.monthly');
      expect(json['categoryId'], 'cat-005');
      expect(json['accountId'], 'acc-001');
      expect(json['notes'], 'Streaming subscription');
      expect(json['status'], 'SubscriptionStatus.active');
      expect(json['remindBeforeDays'], 3);
    });

    test('fromJson -> toJson roundtrip preserves all data', () {
      final recurring = RecurringTransaction.fromJson(sampleJson);
      final outputJson = recurring.toJson();

      expect(outputJson['id'], sampleJson['id']);
      expect(outputJson['name'], sampleJson['name']);
      expect(outputJson['amount'], sampleJson['amount']);
      expect(outputJson['currency'], sampleJson['currency']);
      expect(outputJson['startDate'], sampleJson['startDate']);
      expect(outputJson['nextDueDate'], sampleJson['nextDueDate']);
      expect(outputJson['frequency'], sampleJson['frequency']);
      expect(outputJson['categoryId'], sampleJson['categoryId']);
      expect(outputJson['accountId'], sampleJson['accountId']);
      expect(outputJson['notes'], sampleJson['notes']);
      expect(outputJson['status'], sampleJson['status']);
      expect(outputJson['remindBeforeDays'], sampleJson['remindBeforeDays']);
    });

    test('all Frequency enum values parse correctly', () {
      for (final freq in Frequency.values) {
        final json = Map<String, dynamic>.from(sampleJson);
        json['frequency'] = freq.toString();
        final recurring = RecurringTransaction.fromJson(json);
        expect(recurring.frequency, freq);
      }
    });

    test('Frequency has monthly, quarterly, yearly, custom', () {
      expect(Frequency.values, contains(Frequency.monthly));
      expect(Frequency.values, contains(Frequency.quarterly));
      expect(Frequency.values, contains(Frequency.yearly));
      expect(Frequency.values, contains(Frequency.custom));
      expect(Frequency.values.length, 4);
    });

    test('all SubscriptionStatus enum values parse correctly', () {
      for (final status in SubscriptionStatus.values) {
        final json = Map<String, dynamic>.from(sampleJson);
        json['status'] = status.toString();
        final recurring = RecurringTransaction.fromJson(json);
        expect(recurring.status, status);
      }
    });

    test('SubscriptionStatus has active, paused, cancelled', () {
      expect(SubscriptionStatus.values, contains(SubscriptionStatus.active));
      expect(SubscriptionStatus.values, contains(SubscriptionStatus.paused));
      expect(SubscriptionStatus.values, contains(SubscriptionStatus.cancelled));
      expect(SubscriptionStatus.values.length, 3);
    });

    test('default values: status defaults to active', () {
      final recurring = RecurringTransaction(
        id: 'rec-002',
        name: 'Gym',
        amount: 50.0,
        currency: 'CNY',
        startDate: DateTime(2024, 1, 1),
        nextDueDate: DateTime(2024, 2, 1),
        frequency: Frequency.monthly,
        categoryId: 'cat-001',
        accountId: 'acc-001',
      );

      expect(recurring.status, SubscriptionStatus.active);
    });

    test('default values: remindBeforeDays defaults to 3', () {
      final recurring = RecurringTransaction(
        id: 'rec-002',
        name: 'Gym',
        amount: 50.0,
        currency: 'CNY',
        startDate: DateTime(2024, 1, 1),
        nextDueDate: DateTime(2024, 2, 1),
        frequency: Frequency.monthly,
        categoryId: 'cat-001',
        accountId: 'acc-001',
      );

      expect(recurring.remindBeforeDays, 3);
    });

    test('copyWith updates fields correctly', () {
      final updated = sampleRecurring.copyWith(
        name: 'Spotify',
        amount: 9.99,
        frequency: Frequency.yearly,
      );

      expect(updated.name, 'Spotify');
      expect(updated.amount, 9.99);
      expect(updated.frequency, Frequency.yearly);
      // Preserved fields
      expect(updated.id, sampleRecurring.id);
      expect(updated.currency, sampleRecurring.currency);
      expect(updated.startDate, sampleRecurring.startDate);
      expect(updated.nextDueDate, sampleRecurring.nextDueDate);
      expect(updated.categoryId, sampleRecurring.categoryId);
      expect(updated.accountId, sampleRecurring.accountId);
      expect(updated.notes, sampleRecurring.notes);
      expect(updated.status, sampleRecurring.status);
      expect(updated.remindBeforeDays, sampleRecurring.remindBeforeDays);
    });

    test('copyWith can change status', () {
      final paused = sampleRecurring.copyWith(
        status: SubscriptionStatus.paused,
      );
      expect(paused.status, SubscriptionStatus.paused);
    });

    test('notes field can be null', () {
      final json = Map<String, dynamic>.from(sampleJson);
      json['notes'] = null;

      final recurring = RecurringTransaction.fromJson(json);
      expect(recurring.notes, isNull);
    });
  });
}
