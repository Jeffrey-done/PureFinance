import 'package:flutter/foundation.dart';

import '../models/account.dart';
import '../services/database_service.dart';

class AccountProvider extends ChangeNotifier {
  final DatabaseService _dbService = DatabaseService();
  List<Account> _accounts = [];

  List<Account> get accounts => _accounts;

  Future<void> loadAccounts() async {
    final data = await _dbService.query('accounts');
    _accounts = data.map((map) => Account.fromJson(Map<String, dynamic>.from(map))).toList();
    notifyListeners();
  }

  Future<void> addAccount(Account account) async {
    await _dbService.insert('accounts', account.toJson());
    _accounts.add(account);
    notifyListeners();
  }

  Future<void> updateAccount(Account account) async {
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
  }

  Future<void> deleteAccount(String id) async {
    await _dbService.delete('accounts', where: 'id = ?', whereArgs: [id]);
    _accounts.removeWhere((a) => a.id == id);
    notifyListeners();
  }

  Future<void> updateBalance(String accountId, double amount) async {
    final index = _accounts.indexWhere((a) => a.id == accountId);
    if (index != -1) {
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
