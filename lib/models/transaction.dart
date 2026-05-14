import 'package:flutter/foundation.dart';

enum TransactionType { expense, income, transfer }

@immutable
class Transaction {
  final String id;
  final TransactionType type;
  final double amount;
  final String currency;
  final DateTime date;
  final String categoryId;
  final String accountId;
  final String? notes;
  final List<String>? tags;
  final bool isRecurring;
  final String? recurringId;

  const Transaction({
    required this.id,
    required this.type,
    required this.amount,
    required this.currency,
    required this.date,
    required this.categoryId,
    required this.accountId,
    this.notes,
    this.tags,
    this.isRecurring = false,
    this.recurringId,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'] as String,
      type: TransactionType.values.firstWhere(
        (e) => e.toString() == json['type'],
      ),
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String,
      date: DateTime.parse(json['date'] as String),
      categoryId: json['categoryId'] as String,
      accountId: json['accountId'] as String,
      notes: json['notes'] as String?,
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e.toString()).toList(),
      isRecurring: json['isRecurring'] as bool,
      recurringId: json['recurringId'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.toString(),
      'amount': amount,
      'currency': currency,
      'date': date.toIso8601String(),
      'categoryId': categoryId,
      'accountId': accountId,
      'notes': notes,
      'tags': tags,
      'isRecurring': isRecurring,
      'recurringId': recurringId,
    };
  }

  Transaction copyWith({
    String? id,
    TransactionType? type,
    double? amount,
    String? currency,
    DateTime? date,
    String? categoryId,
    String? accountId,
    String? notes,
    List<String>? tags,
    bool? isRecurring,
    String? recurringId,
  }) {
    return Transaction(
      id: id ?? this.id,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      date: date ?? this.date,
      categoryId: categoryId ?? this.categoryId,
      accountId: accountId ?? this.accountId,
      notes: notes ?? this.notes,
      tags: tags ?? this.tags,
      isRecurring: isRecurring ?? this.isRecurring,
      recurringId: recurringId ?? this.recurringId,
    );
  }
}
