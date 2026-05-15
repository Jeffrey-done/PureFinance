import 'package:flutter/foundation.dart';

import '../models/recurring_transaction.dart';
import '../services/database_service.dart';

class SubscriptionProvider extends ChangeNotifier {
  final DatabaseService _dbService = DatabaseService();
  List<RecurringTransaction> _subscriptions = [];
  bool _isLoading = false;
  String? _error;

  List<RecurringTransaction> get subscriptions => _subscriptions;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadSubscriptions() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final data = await _dbService.query('recurring_transactions');
      _subscriptions = data
          .map((map) => RecurringTransaction.fromJson(Map<String, dynamic>.from(map)))
          .toList();
    } catch (e) {
      debugPrint('SubscriptionProvider.loadSubscriptions failed: $e');
      _error = '加载订阅失败: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addSubscription(RecurringTransaction subscription) async {
    try {
      await _dbService.insert('recurring_transactions', subscription.toJson());
      _subscriptions.add(subscription);
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('SubscriptionProvider.addSubscription failed: $e');
      _error = '添加订阅失败: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateSubscription(RecurringTransaction subscription) async {
    try {
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
      return true;
    } catch (e) {
      debugPrint('SubscriptionProvider.updateSubscription failed: $e');
      _error = '更新订阅失败: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteSubscription(String id) async {
    try {
      await _dbService.delete('recurring_transactions', where: 'id = ?', whereArgs: [id]);
      _subscriptions.removeWhere((s) => s.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('SubscriptionProvider.deleteSubscription failed: $e');
      _error = '删除订阅失败: $e';
      notifyListeners();
      return false;
    }
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
          // Unknown period: don't pretend it's monthly. Skip from monthly
          // total so we don't over-report active subscription cost.
          break;
      }
    }
    return total;
  }

  List<RecurringTransaction> checkDueSubscriptions(DateTime today) {
    // Compare on calendar-day boundaries so a subscription due "today" is
    // included regardless of the time component on either date.
    final todayDay = DateTime(today.year, today.month, today.day);
    return _subscriptions.where((s) {
      if (s.status != SubscriptionStatus.active) return false;
      final dueDay = DateTime(
        s.nextDueDate.year,
        s.nextDueDate.month,
        s.nextDueDate.day,
      );
      final reminderDay = dueDay.subtract(Duration(days: s.remindBeforeDays));
      return !todayDay.isBefore(reminderDay) && !todayDay.isAfter(dueDay);
    }).toList();
  }
}
