import 'package:flutter/foundation.dart';

enum AccountType { cash, bank, creditCard, investment }

@immutable
class Account {
  final String id;
  final String name;
  final AccountType type;
  final double balance;
  final String currency;
  final String? icon;
  final String? color;

  const Account({
    required this.id,
    required this.name,
    required this.type,
    required this.balance,
    required this.currency,
    this.icon,
    this.color,
  });

  factory Account.fromJson(Map<String, dynamic> json) {
    final typeStr = json['type'] as String;
    final type = AccountType.values.firstWhere(
      (e) => e.name == typeStr || e.toString() == typeStr,
    );

    return Account(
      id: json['id'] as String,
      name: json['name'] as String,
      type: type,
      balance: (json['balance'] as num).toDouble(),
      currency: json['currency'] as String,
      icon: json['icon'] as String?,
      color: json['color'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type.name,
      'balance': balance,
      'currency': currency,
      'icon': icon,
      'color': color,
    };
  }

  Account copyWith({
    String? id,
    String? name,
    AccountType? type,
    double? balance,
    String? currency,
    String? icon,
    String? color,
  }) {
    return Account(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      balance: balance ?? this.balance,
      currency: currency ?? this.currency,
      icon: icon ?? this.icon,
      color: color ?? this.color,
    );
  }
}
