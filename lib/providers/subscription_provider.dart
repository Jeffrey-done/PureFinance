import 'package:flutter/foundation.dart';

import '../models/recurring_transaction.dart';
import '../services/database_service.dart';

class SubscriptionProvider extends ChangeNotifier {
  final DatabaseService _dbService = DatabaseService();
  List<RecurringTransaction> _subscriptions = [];

  List<RecurringTransaction> get subscriptions => _subscriptions;

  Future<void> loadSubscriptions() async {
    final data = await _dbService.query('recurring_transactions');
    _subscriptions = data
        .map((map) => RecurringTransaction.fromJson(Map<String, dynamic>.from(map)))
        .toList();
    notifyListeners();
  }

  Future<void> addSubscription(RecurringTransaction subscription) async {
    await _dbService.insert('recurring_transactions', subscription.toJson());
    _subscriptions.add(subscription);
    notifyListeners();
  }

  Future<void> updateSubscription(RecurringTransaction subscription) async {
    await _dbService.update(
      'recurring_transactions',
      subscription.toJson(),
      where: 'id = ?',
      whereArgs: [subscription.id],
    );
    final index = _subscriptions.indexWhere((s) => s.id == subscription.id);
    if (index != -1) {
      _subscriptions[index] = subscription;
      notifyListeners();
    }
  }

  Future<void> deleteSubscription(String id) async {
    await _dbService.delete('recurring_transactions', where: 'id = ?', whereArgs: [id]);
    _subscriptions.removeWhere((s) => s.id == id);
    notifyListeners();
  }

  List<RecurringTransaction> getActiveSubscriptions() {
    return _subscriptions
        .where((s) => s.status == SubscriptionStatus.active)
        .toList();
  }

  List<RecurringTransaction> getPausedSubscriptions() {
    return _subscriptions
        .where((s) => s.status == SubscriptionStatus.paused)
        .toList();
  }

  List<RecurringTransaction> getCancelledSubscriptions() {
    return _subscriptions
        .where((s) => s.status == SubscriptionStatus.cancelled)
        .toList();
  }

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

  List<RecurringTransaction> checkDueSubscriptions(DateTime today) {
    return _subscriptions.where((s) {
      if (s.status != SubscriptionStatus.active) return false;
      final dueDate = s.nextDueDate;
      final reminderDate = dueDate.subtract(Duration(days: s.remindBeforeDays));
      return !today.isBefore(reminderDate) && !today.isAfter(dueDate);
    }).toList();
  }
}
