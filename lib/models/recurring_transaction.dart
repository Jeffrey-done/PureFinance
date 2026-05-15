import 'package:flutter/foundation.dart';

enum Frequency { monthly, quarterly, yearly, custom }

enum SubscriptionStatus { active, paused, cancelled }

@immutable
class RecurringTransaction {
  final String id;
  final String name;
  final double amount;
  final String currency;
  final DateTime startDate;
  final DateTime nextDueDate;
  final Frequency frequency;
  final String categoryId;
  final String accountId;
  final String? notes;
  final SubscriptionStatus status;
  final int remindBeforeDays;

  const RecurringTransaction({
    required this.id,
    required this.name,
    required this.amount,
    required this.currency,
    required this.startDate,
    required this.nextDueDate,
    required this.frequency,
    required this.categoryId,
    required this.accountId,
    this.notes,
    this.status = SubscriptionStatus.active,
    this.remindBeforeDays = 3,
  });

  factory RecurringTransaction.fromJson(Map<String, dynamic> json) {
    final freqStr = json['frequency'] as String;
    final frequency = Frequency.values.firstWhere(
      (e) => e.name == freqStr || e.toString() == freqStr,
    );

    final statusStr = json['status'] as String;
    final status = SubscriptionStatus.values.firstWhere(
      (e) => e.name == statusStr || e.toString() == statusStr,
    );

    return RecurringTransaction(
      id: json['id'] as String,
      name: json['name'] as String,
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String,
      startDate: DateTime.parse(json['startDate'] as String),
      nextDueDate: DateTime.parse(json['nextDueDate'] as String),
      frequency: frequency,
      categoryId: json['categoryId'] as String,
      accountId: json['accountId'] as String,
      notes: json['notes'] as String?,
      status: status,
      remindBeforeDays: json['remindBeforeDays'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'amount': amount,
      'currency': currency,
      'startDate': startDate.toIso8601String(),
      'nextDueDate': nextDueDate.toIso8601String(),
      'frequency': frequency.name,
      'categoryId': categoryId,
      'accountId': accountId,
      'notes': notes,
      'status': status.name,
      'remindBeforeDays': remindBeforeDays,
    };
  }

  RecurringTransaction copyWith({
    String? id,
    String? name,
    double? amount,
    String? currency,
    DateTime? startDate,
    DateTime? nextDueDate,
    Frequency? frequency,
    String? categoryId,
    String? accountId,
    String? notes,
    SubscriptionStatus? status,
    int? remindBeforeDays,
  }) {
    return RecurringTransaction(
      id: id ?? this.id,
      name: name ?? this.name,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      startDate: startDate ?? this.startDate,
      nextDueDate: nextDueDate ?? this.nextDueDate,
      frequency: frequency ?? this.frequency,
      categoryId: categoryId ?? this.categoryId,
      accountId: accountId ?? this.accountId,
      notes: notes ?? this.notes,
      status: status ?? this.status,
      remindBeforeDays: remindBeforeDays ?? this.remindBeforeDays,
    );
  }
}
