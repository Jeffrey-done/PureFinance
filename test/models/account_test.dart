import 'package:flutter_test/flutter_test.dart';
import 'package:pure_finance/models/account.dart';

void main() {
  group('Account', () {
    final sampleJson = {
      'id': 'acc-001',
      'name': 'Main Checking',
      'type': 'AccountType.bank',
      'balance': 15000.50,
      'currency': 'CNY',
      'icon': '0xe0af',
      'color': '#4CAF50',
    };

    final sampleAccount = Account(
      id: 'acc-001',
      name: 'Main Checking',
      type: AccountType.bank,
      balance: 15000.50,
      currency: 'CNY',
      icon: '0xe0af',
      color: '#4CAF50',
    );

    test('fromJson creates correct object', () {
      final account = Account.fromJson(sampleJson);

      expect(account.id, 'acc-001');
      expect(account.name, 'Main Checking');
      expect(account.type, AccountType.bank);
      expect(account.balance, 15000.50);
      expect(account.currency, 'CNY');
      expect(account.icon, '0xe0af');
      expect(account.color, '#4CAF50');
    });

    test('toJson produces correct map', () {
      final json = sampleAccount.toJson();

      expect(json['id'], 'acc-001');
      expect(json['name'], 'Main Checking');
      expect(json['type'], 'AccountType.bank');
      expect(json['balance'], 15000.50);
      expect(json['currency'], 'CNY');
      expect(json['icon'], '0xe0af');
      expect(json['color'], '#4CAF50');
    });

    test('fromJson -> toJson roundtrip preserves all data', () {
      final account = Account.fromJson(sampleJson);
      final outputJson = account.toJson();

      expect(outputJson['id'], sampleJson['id']);
      expect(outputJson['type'], sampleJson['type']);
      expect(outputJson['name'], sampleJson['name']);
      expect(outputJson['balance'], sampleJson['balance']);
      expect(outputJson['currency'], sampleJson['currency']);
      expect(outputJson['icon'], sampleJson['icon']);
      expect(outputJson['color'], sampleJson['color']);
    });

    test('all AccountType enum values parse correctly', () {
      for (final type in AccountType.values) {
        final json = Map<String, dynamic>.from(sampleJson);
        json['type'] = type.toString();
        final account = Account.fromJson(json);
        expect(account.type, type);
      }
    });

    test('AccountType has cash, bank, creditCard, investment', () {
      expect(AccountType.values, contains(AccountType.cash));
      expect(AccountType.values, contains(AccountType.bank));
      expect(AccountType.values, contains(AccountType.creditCard));
      expect(AccountType.values, contains(AccountType.investment));
      expect(AccountType.values.length, 4);
    });

    test('copyWith updates fields correctly', () {
      final updated = sampleAccount.copyWith(
        name: 'Savings',
        balance: 20000.0,
      );

      expect(updated.name, 'Savings');
      expect(updated.balance, 20000.0);
      // Preserved fields
      expect(updated.id, sampleAccount.id);
      expect(updated.type, sampleAccount.type);
      expect(updated.currency, sampleAccount.currency);
      expect(updated.icon, sampleAccount.icon);
      expect(updated.color, sampleAccount.color);
    });

    test('copyWith with type changes account type', () {
      final updated = sampleAccount.copyWith(type: AccountType.creditCard);
      expect(updated.type, AccountType.creditCard);
      expect(updated.name, sampleAccount.name);
    });

    test('nullable fields handle null correctly', () {
      final json = Map<String, dynamic>.from(sampleJson);
      json['icon'] = null;
      json['color'] = null;

      final account = Account.fromJson(json);
      expect(account.icon, isNull);
      expect(account.color, isNull);

      final outputJson = account.toJson();
      expect(outputJson['icon'], isNull);
      expect(outputJson['color'], isNull);
    });
  });
}
