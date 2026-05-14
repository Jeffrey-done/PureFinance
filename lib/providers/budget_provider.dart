import 'package:flutter/foundation.dart';

import '../services/database_service.dart';

class BudgetProvider extends ChangeNotifier {
  final DatabaseService _dbService = DatabaseService();
  double _totalMonthlyBudget = 0.0;
  Map<String, double> _categoryBudgets = {};

  double get totalMonthlyBudget => _totalMonthlyBudget;
  Map<String, double> get categoryBudgets => Map.unmodifiable(_categoryBudgets);

  Future<void> loadBudgets() async {
    final data = await _dbService.query('budgets');
    _categoryBudgets = {};
    _totalMonthlyBudget = 0.0;
    for (final row in data) {
      final categoryId = row['categoryId'] as String?;
      final amount = (row['amount'] as num).toDouble();
      if (categoryId == null || categoryId == '_total_') {
        _totalMonthlyBudget = amount;
      } else {
        _categoryBudgets[categoryId] = amount;
      }
    }
    notifyListeners();
  }

  Future<void> setTotalBudget(double amount) async {
    _totalMonthlyBudget = amount;
    await _dbService.insert('budgets', {
      'id': '_total_budget_',
      'categoryId': '_total_',
      'amount': amount,
    });
    notifyListeners();
  }

  Future<void> setCategoryBudget(String categoryId, double amount) async {
    _categoryBudgets[categoryId] = amount;
    await _dbService.insert('budgets', {
      'id': 'budget_$categoryId',
      'categoryId': categoryId,
      'amount': amount,
    });
    notifyListeners();
  }

  Future<void> removeCategoryBudget(String categoryId) async {
    _categoryBudgets.remove(categoryId);
    await _dbService.delete(
      'budgets',
      where: 'categoryId = ?',
      whereArgs: [categoryId],
    );
    notifyListeners();
  }

  double getBudgetProgress(double currentSpending) {
    if (_totalMonthlyBudget <= 0) return 0.0;
    return currentSpending / _totalMonthlyBudget;
  }

  bool isOverBudget(double currentSpending) {
    if (_totalMonthlyBudget <= 0) return false;
    return currentSpending > _totalMonthlyBudget;
  }
}
