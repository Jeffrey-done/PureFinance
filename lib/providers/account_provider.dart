import 'package:flutter/foundation.dart';

import '../models/account.dart';
import '../services/database_service.dart';

class AccountProvider extends ChangeNotifier {
  final DatabaseService _dbService = DatabaseService();
  List<Account> _accounts = [];
  bool _isLoading = false;
  String? _error;

  List<Account> get accounts => _accounts;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadAccounts() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final data = await _dbService.query('accounts');
      _accounts = data.map((map) => Account.fromJson(Map<String, dynamic>.from(map))).toList();
    } catch (e) {
      debugPrint('AccountProvider.loadAccounts failed: $e');
      _error = '加载账户失败: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addAccount(Account account) async {
    try {
      await _dbService.insert('accounts', account.toJson());
      _accounts.add(account);
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('AccountProvider.addAccount failed: $e');
      _error = '添加账户失败: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateAccount(Account account) async {
    try {
      await _dbService.update(
        'accounts',
        account.toJson(),
        where: 'id = ?',
        whereArgs: [account.id],
      );
      final index = _accounts.indexWhere((a) => a.id == account.id);
      if (index != -1) {
        _accounts[index] = account;
        notifyListeners();
      }
      return true;
    } catch (e) {
      debugPrint('AccountProvider.updateAccount failed: $e');
      _error = '更新账户失败: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteAccount(String id) async {
    try {
      await _dbService.delete('accounts', where: 'id = ?', whereArgs: [id]);
      _accounts.removeWhere((a) => a.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('AccountProvider.deleteAccount failed: $e');
      _error = '删除账户失败: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateBalance(String accountId, double amount) async {
    final index = _accounts.indexWhere((a) => a.id == accountId);
    if (index == -1) return false;
    try {
      final account = _accounts[index];
      final updated = account.copyWith(balance: account.balance + amount);
      await _dbService.update(
        'accounts',
        updated.toJson(),
        where: 'id = ?',
        whereArgs: [accountId],
      );
      _accounts[index] = updated;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('AccountProvider.updateBalance failed: $e');
      _error = '更新余额失败: $e';
      notifyListeners();
      return false;
    }
  }

  /// Atomically transfers balance between two accounts using a single database
  /// transaction to prevent inconsistent state.
  Future<bool> transferBalance(
    String fromAccountId,
    double amount,
    String toAccountId,
  ) async {
    try {
      await _dbService.batchUpdateBalances(
        fromAccountId,
        -amount,
        toAccountId,
        amount,
      );
      // Sync in-memory state
      final fromIndex = _accounts.indexWhere((a) => a.id == fromAccountId);
      if (fromIndex != -1) {
        final account = _accounts[fromIndex];
        _accounts[fromIndex] = account.copyWith(balance: account.balance - amount);
      }
      final toIndex = _accounts.indexWhere((a) => a.id == toAccountId);
      if (toIndex != -1) {
        final account = _accounts[toIndex];
        _accounts[toIndex] = account.copyWith(balance: account.balance + amount);
      }
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('AccountProvider.transferBalance failed: $e');
      _error = '转账失败: $e';
      notifyListeners();
      return false;
    }
  }

  double get getTotalAssets {
    return _accounts
        .where((a) =>
            a.type == AccountType.cash ||
            a.type == AccountType.bank ||
            a.type == AccountType.investment)
        .fold(0.0, (sum, a) => sum + a.balance);
  }

  double get getTotalLiabilities {
    return _accounts
        .where((a) => a.type == AccountType.creditCard)
        .where((a) => a.balance < 0)
        .fold(0.0, (sum, a) => sum + a.balance.abs());
  }

  double get getNetWorth {
    return getTotalAssets - getTotalLiabilities;
  }
}
