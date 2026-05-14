import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../models/transaction.dart';
import '../services/database_service.dart';

class TransactionProvider extends ChangeNotifier {
  final DatabaseService _dbService = DatabaseService();
  List<Transaction> _transactions = [];

  List<Transaction> get transactions => _transactions;

  Future<void> loadTransactions() async {
    final data = await _dbService.query('transactions', orderBy: 'date DESC');
    _transactions = data.map((map) {
      final jsonMap = Map<String, dynamic>.from(map);
      // Convert tags from JSON string to List
      if (jsonMap['tags'] != null && jsonMap['tags'] is String) {
        jsonMap['tags'] = jsonDecode(jsonMap['tags'] as String);
      }
      // Convert isRecurring from int to bool
      jsonMap['isRecurring'] = jsonMap['isRecurring'] == 1;
      return Transaction.fromJson(jsonMap);
    }).toList();
    notifyListeners();
  }

  Future<void> addTransaction(Transaction transaction) async {
    final map = transaction.toJson();
    // Convert tags list to JSON string for storage
    if (map['tags'] != null) {
      map['tags'] = jsonEncode(map['tags']);
    }
    // Convert bool to int for sqlite
    map['isRecurring'] = transaction.isRecurring ? 1 : 0;
    await _dbService.insert('transactions', map);
    _transactions.insert(0, transaction);
    notifyListeners();
  }

  Future<void> updateTransaction(Transaction transaction) async {
    final map = transaction.toJson();
    if (map['tags'] != null) {
      map['tags'] = jsonEncode(map['tags']);
    }
    map['isRecurring'] = transaction.isRecurring ? 1 : 0;
    await _dbService.update(
      'transactions',
      map,
      where: 'id = ?',
      whereArgs: [transaction.id],
    );
    final index = _transactions.indexWhere((t) => t.id == transaction.id);
    if (index != -1) {
      _transactions[index] = transaction;
      notifyListeners();
    }
  }

  Future<void> deleteTransaction(String id) async {
    await _dbService.delete('transactions', where: 'id = ?', whereArgs: [id]);
    _transactions.removeWhere((t) => t.id == id);
    notifyListeners();
  }

  List<Transaction> getTransactionsByDateRange(DateTime start, DateTime end) {
    return _transactions.where((t) {
      return !t.date.isBefore(start) && !t.date.isAfter(end);
    }).toList();
  }

  List<Transaction> getTransactionsByCategory(String categoryId) {
    return _transactions.where((t) => t.categoryId == categoryId).toList();
  }

  List<Transaction> getTransactionsByAccount(String accountId) {
    return _transactions.where((t) => t.accountId == accountId).toList();
  }

  double getTotalExpense(DateTime month) {
    final startOfMonth = DateTime(month.year, month.month, 1);
    final endOfMonth = DateTime(month.year, month.month + 1, 0, 23, 59, 59);
    return _transactions
        .where((t) =>
            t.type == TransactionType.expense &&
            !t.date.isBefore(startOfMonth) &&
            !t.date.isAfter(endOfMonth))
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  double getTotalIncome(DateTime month) {
    final startOfMonth = DateTime(month.year, month.month, 1);
    final endOfMonth = DateTime(month.year, month.month + 1, 0, 23, 59, 59);
    return _transactions
        .where((t) =>
            t.type == TransactionType.income &&
            !t.date.isBefore(startOfMonth) &&
            !t.date.isAfter(endOfMonth))
        .fold(0.0, (sum, t) => sum + t.amount);
  }
}
