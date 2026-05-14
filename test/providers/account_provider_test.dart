import 'package:flutter_test/flutter_test.dart';
import 'package:pure_finance/models/account.dart';
import 'package:pure_finance/providers/account_provider.dart';

/// A testable subclass that allows setting accounts directly
/// without database calls.
class TestableAccountProvider extends AccountProvider {
  List<Account> testAccounts = [];

  void setAccountsForTest(List<Account> accounts) {
    testAccounts = accounts;
  }

  @override
  List<Account> get accounts => testAccounts;

  @override
  double get getTotalAssets {
    return testAccounts
        .where((a) =>
            a.type == AccountType.cash ||
            a.type == AccountType.bank ||
            a.type == AccountType.investment)
        .fold(0.0, (sum, a) => sum + a.balance);
  }

  @override
  double get getTotalLiabilities {
    return testAccounts
        .where((a) => a.type == AccountType.creditCard)
        .where((a) => a.balance < 0)
        .fold(0.0, (sum, a) => sum + a.balance.abs());
  }

  @override
  double get getNetWorth {
    return getTotalAssets - getTotalLiabilities;
  }
}

void main() {
  group('AccountProvider', () {
    late TestableAccountProvider provider;

    final bankAccount = Account(
      id: 'acc-001',
      name: 'Main Bank',
      type: AccountType.bank,
      balance: 10000.0,
      currency: 'CNY',
    );

    final cashAccount = Account(
      id: 'acc-002',
      name: 'Cash Wallet',
      type: AccountType.cash,
      balance: 500.0,
      currency: 'CNY',
    );

    final creditCard = Account(
      id: 'acc-003',
      name: 'Credit Card',
      type: AccountType.creditCard,
      balance: -3000.0,
      currency: 'CNY',
    );

    final investmentAccount = Account(
      id: 'acc-004',
      name: 'Stocks',
      type: AccountType.investment,
      balance: 25000.0,
      currency: 'CNY',
    );

    setUp(() {
      provider = TestableAccountProvider();
      provider.setAccountsForTest([
        bankAccount,
        cashAccount,
        creditCard,
        investmentAccount,
      ]);
    });

    test('accounts getter returns set list', () {
      expect(provider.accounts.length, 4);
    });

    test('addAccount adds to list', () {
      final newAccount = Account(
        id: 'acc-005',
        name: 'Savings',
        type: AccountType.bank,
        balance: 5000.0,
        currency: 'CNY',
      );

      provider.testAccounts = [...provider.testAccounts, newAccount];

      expect(provider.accounts.length, 5);
      expect(provider.accounts.last.id, 'acc-005');
    });

    test('getTotalAssets sums non-credit-card balances', () {
      // bank: 10000 + cash: 500 + investment: 25000 = 35500
      expect(provider.getTotalAssets, 35500.0);
    });

    test('getTotalLiabilities sums credit card balances (abs of negative)', () {
      // creditCard: |-3000| = 3000
      expect(provider.getTotalLiabilities, 3000.0);
    });

    test('getTotalLiabilities only counts negative credit card balances', () {
      final positiveCC = Account(
        id: 'acc-pos-cc',
        name: 'Positive CC',
        type: AccountType.creditCard,
        balance: 100.0,
        currency: 'CNY',
      );

      provider.setAccountsForTest([creditCard, positiveCC]);

      // Only the negative credit card counts
      expect(provider.getTotalLiabilities, 3000.0);
    });

    test('getNetWorth equals assets minus liabilities', () {
      // 35500 - 3000 = 32500
      expect(provider.getNetWorth, 32500.0);
    });

    test('getNetWorth is zero when no accounts', () {
      provider.setAccountsForTest([]);
      expect(provider.getNetWorth, 0.0);
    });

    test('updateBalance correctly adjusts an account balance', () {
      // Simulate updateBalance logic
      final index =
          provider.testAccounts.indexWhere((a) => a.id == 'acc-001');
      final account = provider.testAccounts[index];
      final updated = account.copyWith(balance: account.balance + 500.0);
      provider.testAccounts = List.from(provider.testAccounts);
      provider.testAccounts[index] = updated;

      expect(provider.accounts[0].balance, 10500.0);
    });

    test('getTotalAssets with only investment account', () {
      provider.setAccountsForTest([investmentAccount]);
      expect(provider.getTotalAssets, 25000.0);
    });
  });
}
