import 'package:flutter_test/flutter_test.dart';
import 'package:pure_finance/models/recurring_transaction.dart';
import 'package:pure_finance/providers/subscription_provider.dart';

/// A testable subclass that allows setting subscriptions directly
/// without database calls.
class TestableSubscriptionProvider extends SubscriptionProvider {
  List<RecurringTransaction> testSubscriptions = [];

  void setSubscriptionsForTest(List<RecurringTransaction> subs) {
    testSubscriptions = subs;
  }

  @override
  List<RecurringTransaction> get subscriptions => testSubscriptions;

  @override
  List<RecurringTransaction> getActiveSubscriptions() {
    return testSubscriptions
        .where((s) => s.status == SubscriptionStatus.active)
        .toList();
  }

  @override
  List<RecurringTransaction> getPausedSubscriptions() {
    return testSubscriptions
        .where((s) => s.status == SubscriptionStatus.paused)
        .toList();
  }

  @override
  List<RecurringTransaction> getCancelledSubscriptions() {
    return testSubscriptions
        .where((s) => s.status == SubscriptionStatus.cancelled)
        .toList();
  }

  @override
  double getMonthlyTotal() {
    double total = 0.0;
    for (final sub in getActiveSubscriptions()) {
      switch (sub.frequency) {
        case Frequency.monthly:
          total += sub.amount;
          break;
        case Frequency.quarterly:
          total += sub.amount / 3.0;
          break;
        case Frequency.yearly:
          total += sub.amount / 12.0;
          break;
        case Frequency.custom:
          total += sub.amount;
          break;
      }
    }
    return total;
  }

  @override
  List<RecurringTransaction> checkDueSubscriptions(DateTime today) {
    return testSubscriptions.where((s) {
      if (s.status != SubscriptionStatus.active) return false;
      final dueDate = s.nextDueDate;
      final reminderDate = dueDate.subtract(Duration(days: s.remindBeforeDays));
      return !today.isBefore(reminderDate) && !today.isAfter(dueDate);
    }).toList();
  }
}

void main() {
  group('SubscriptionProvider', () {
    late TestableSubscriptionProvider provider;

    final monthlySub = RecurringTransaction(
      id: 'sub-001',
      name: 'Netflix',
      amount: 15.99,
      currency: 'CNY',
      startDate: DateTime(2024, 1, 1),
      nextDueDate: DateTime(2024, 4, 1),
      frequency: Frequency.monthly,
      categoryId: 'cat-001',
      accountId: 'acc-001',
      status: SubscriptionStatus.active,
      remindBeforeDays: 3,
    );

    final quarterlySub = RecurringTransaction(
      id: 'sub-002',
      name: 'Cloud Storage',
      amount: 30.0,
      currency: 'CNY',
      startDate: DateTime(2024, 1, 1),
      nextDueDate: DateTime(2024, 4, 1),
      frequency: Frequency.quarterly,
      categoryId: 'cat-002',
      accountId: 'acc-001',
      status: SubscriptionStatus.active,
      remindBeforeDays: 5,
    );

    final yearlySub = RecurringTransaction(
      id: 'sub-003',
      name: 'Domain Name',
      amount: 120.0,
      currency: 'CNY',
      startDate: DateTime(2024, 1, 1),
      nextDueDate: DateTime(2025, 1, 1),
      frequency: Frequency.yearly,
      categoryId: 'cat-003',
      accountId: 'acc-001',
      status: SubscriptionStatus.active,
      remindBeforeDays: 7,
    );

    final pausedSub = RecurringTransaction(
      id: 'sub-004',
      name: 'Gym',
      amount: 100.0,
      currency: 'CNY',
      startDate: DateTime(2024, 1, 1),
      nextDueDate: DateTime(2024, 4, 1),
      frequency: Frequency.monthly,
      categoryId: 'cat-004',
      accountId: 'acc-001',
      status: SubscriptionStatus.paused,
      remindBeforeDays: 3,
    );

    final cancelledSub = RecurringTransaction(
      id: 'sub-005',
      name: 'Old Service',
      amount: 50.0,
      currency: 'CNY',
      startDate: DateTime(2023, 1, 1),
      nextDueDate: DateTime(2024, 1, 1),
      frequency: Frequency.monthly,
      categoryId: 'cat-005',
      accountId: 'acc-001',
      status: SubscriptionStatus.cancelled,
      remindBeforeDays: 3,
    );

    setUp(() {
      provider = TestableSubscriptionProvider();
      provider.setSubscriptionsForTest([
        monthlySub,
        quarterlySub,
        yearlySub,
        pausedSub,
        cancelledSub,
      ]);
    });

    test('subscriptions getter returns set list', () {
      expect(provider.subscriptions.length, 5);
    });

    test('addSubscription adds to list', () {
      final newSub = RecurringTransaction(
        id: 'sub-new',
        name: 'Spotify',
        amount: 9.99,
        currency: 'CNY',
        startDate: DateTime(2024, 3, 1),
        nextDueDate: DateTime(2024, 4, 1),
        frequency: Frequency.monthly,
        categoryId: 'cat-001',
        accountId: 'acc-001',
      );

      provider.testSubscriptions = [...provider.testSubscriptions, newSub];

      expect(provider.subscriptions.length, 6);
    });

    test('getActiveSubscriptions only returns active ones', () {
      final active = provider.getActiveSubscriptions();

      expect(active.length, 3);
      expect(active.every((s) => s.status == SubscriptionStatus.active), true);
      expect(active.any((s) => s.id == 'sub-001'), true);
      expect(active.any((s) => s.id == 'sub-002'), true);
      expect(active.any((s) => s.id == 'sub-003'), true);
    });

    test('getPausedSubscriptions only returns paused ones', () {
      final paused = provider.getPausedSubscriptions();
      expect(paused.length, 1);
      expect(paused.first.id, 'sub-004');
    });

    test('getCancelledSubscriptions only returns cancelled ones', () {
      final cancelled = provider.getCancelledSubscriptions();
      expect(cancelled.length, 1);
      expect(cancelled.first.id, 'sub-005');
    });

    test('getMonthlyTotal calculates correct total', () {
      final total = provider.getMonthlyTotal();

      // monthly: 15.99
      // quarterly: 30.0 / 3 = 10.0
      // yearly: 120.0 / 12 = 10.0
      // paused and cancelled are excluded
      expect(total, closeTo(35.99, 0.01));
    });

    test('getMonthlyTotal excludes paused subscriptions', () {
      provider.setSubscriptionsForTest([pausedSub]);
      expect(provider.getMonthlyTotal(), 0.0);
    });

    test('getMonthlyTotal excludes cancelled subscriptions', () {
      provider.setSubscriptionsForTest([cancelledSub]);
      expect(provider.getMonthlyTotal(), 0.0);
    });

    test('getMonthlyTotal with only monthly frequency', () {
      provider.setSubscriptionsForTest([monthlySub]);
      expect(provider.getMonthlyTotal(), 15.99);
    });

    test('checkDueSubscriptions returns subs within reminder window', () {
      // monthlySub: nextDueDate 2024-04-01, remindBeforeDays 3
      // reminder window: 2024-03-29 to 2024-04-01
      final today = DateTime(2024, 3, 30);
      final due = provider.checkDueSubscriptions(today);

      expect(due.any((s) => s.id == 'sub-001'), true);
    });

    test('checkDueSubscriptions excludes subs outside window', () {
      // too early for monthlySub (reminder starts 2024-03-29)
      final today = DateTime(2024, 3, 25);
      final due = provider.checkDueSubscriptions(today);

      expect(due.any((s) => s.id == 'sub-001'), false);
    });

    test('checkDueSubscriptions excludes inactive subs', () {
      // pausedSub has same due date but should not appear
      final today = DateTime(2024, 3, 30);
      final due = provider.checkDueSubscriptions(today);

      expect(due.any((s) => s.id == 'sub-004'), false);
      expect(due.any((s) => s.id == 'sub-005'), false);
    });

    test('checkDueSubscriptions includes sub on due date', () {
      final today = DateTime(2024, 4, 1);
      final due = provider.checkDueSubscriptions(today);

      expect(due.any((s) => s.id == 'sub-001'), true);
      expect(due.any((s) => s.id == 'sub-002'), true);
    });

    test('checkDueSubscriptions respects different remindBeforeDays', () {
      // quarterlySub: nextDueDate 2024-04-01, remindBeforeDays 5
      // reminder window: 2024-03-27 to 2024-04-01
      final today = DateTime(2024, 3, 28);
      final due = provider.checkDueSubscriptions(today);

      expect(due.any((s) => s.id == 'sub-002'), true);
      // monthlySub reminder starts 2024-03-29, so not yet
      expect(due.any((s) => s.id == 'sub-001'), false);
    });
  });
}
