import 'package:flutter/foundation.dart';

import '../services/database_service.dart';

class BudgetProvider extends ChangeNotifier {
  final DatabaseService _dbService = DatabaseService();
  double _totalMonthlyBudget = 0.0;
  Map<String, double> _categoryBudgets = {};
  bool _isLoading = false;
  String? _error;

  double get totalMonthlyBudget => _totalMonthlyBudget;
  Map<String, double> get categoryBudgets => Map.unmodifiable(_categoryBudgets);
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadBudgets() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
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
    } catch (e) {
      debugPrint('BudgetProvider.loadBudgets failed: $e');
      _error = '加载预算失败: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> setTotalBudget(double amount) async {
    try {
      _totalMonthlyBudget = amount;
      await _dbService.insert('budgets', {
        'id': '_total_budget_',
        'categoryId': '_total_',
        'amount': amount,
      });
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('BudgetProvider.setTotalBudget failed: $e');
      _error = '设置预算失败: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> setCategoryBudget(String categoryId, double amount) async {
    try {
      _categoryBudgets[categoryId] = amount;
      await _dbService.insert('budgets', {
        'id': 'budget_$categoryId',
        'categoryId': categoryId,
        'amount': amount,
      });
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('BudgetProvider.setCategoryBudget failed: $e');
      _error = '设置分类预算失败: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> removeCategoryBudget(String categoryId) async {
    try {
      _categoryBudgets.remove(categoryId);
      await _dbService.delete(
        'budgets',
        where: 'categoryId = ?',
        whereArgs: [categoryId],
      );
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('BudgetProvider.removeCategoryBudget failed: $e');
      _error = '删除分类预算失败: $e';
      notifyListeners();
      return false;
    }
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
