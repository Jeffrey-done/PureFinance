import 'package:flutter_test/flutter_test.dart';
import 'package:pure_finance/services/web_storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('WebStorageService', () {
    late WebStorageService service;

    setUp(() async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      service = WebStorageService();
      await service.initialize();
    });

    test('insert + query returns inserted row', () async {
      await service.insert('accounts', {
        'id': 'a1',
        'name': 'Bank',
        'balance': 100.0,
      });

      final rows = await service.query('accounts');
      expect(rows.length, 1);
      expect(rows.first['id'], 'a1');
      expect(rows.first['name'], 'Bank');
      expect(rows.first['balance'], 100.0);
    });

    test('insert with existing id replaces (ConflictAlgorithm.replace)',
        () async {
      await service.insert('accounts', {'id': 'a1', 'balance': 100.0});
      await service.insert('accounts', {'id': 'a1', 'balance': 250.0});

      final rows = await service.query('accounts');
      expect(rows.length, 1);
      expect(rows.first['balance'], 250.0);
    });

    test('query honors simple equality where clause', () async {
      await service.insert('categories', {
        'id': 'c1',
        'name': 'Food',
        'parentId': null,
      });
      await service.insert('categories', {
        'id': 'c2',
        'name': 'Lunch',
        'parentId': 'c1',
      });
      await service.insert('categories', {
        'id': 'c3',
        'name': 'Transport',
        'parentId': null,
      });

      final children = await service.query(
        'categories',
        where: 'parentId = ?',
        whereArgs: ['c1'],
      );

      expect(children.length, 1);
      expect(children.first['id'], 'c2');
    });

    test('query supports AND-combined predicates', () async {
      await service.insert('transactions', {
        'id': 't1',
        'categoryId': 'food',
        'accountId': 'acc1',
      });
      await service.insert('transactions', {
        'id': 't2',
        'categoryId': 'food',
        'accountId': 'acc2',
      });

      final rows = await service.query(
        'transactions',
        where: 'categoryId = ? AND accountId = ?',
        whereArgs: ['food', 'acc2'],
      );

      expect(rows.length, 1);
      expect(rows.first['id'], 't2');
    });

    test('query orderBy DESC sorts numerically', () async {
      await service.insert('budgets', {'id': 'b1', 'amount': 10.0});
      await service.insert('budgets', {'id': 'b2', 'amount': 30.0});
      await service.insert('budgets', {'id': 'b3', 'amount': 20.0});

      final rows = await service.query('budgets', orderBy: 'amount DESC');
      expect(rows.map((r) => r['id']).toList(), ['b2', 'b3', 'b1']);
    });

    test('query orderBy defaults to ASC when direction omitted', () async {
      await service.insert('transactions', {
        'id': 't1',
        'date': '2024-03-15',
      });
      await service.insert('transactions', {
        'id': 't2',
        'date': '2024-03-10',
      });

      final rows = await service.query('transactions', orderBy: 'date');
      expect(rows.map((r) => r['id']).toList(), ['t2', 't1']);
    });

    test('update mutates rows that match where clause', () async {
      await service.insert('accounts', {'id': 'a1', 'balance': 100.0});
      await service.insert('accounts', {'id': 'a2', 'balance': 50.0});

      final changed = await service.update(
        'accounts',
        {'balance': 999.0},
        where: 'id = ?',
        whereArgs: ['a1'],
      );

      expect(changed, 1);
      final rows = await service.query('accounts');
      final a1 = rows.firstWhere((r) => r['id'] == 'a1');
      final a2 = rows.firstWhere((r) => r['id'] == 'a2');
      expect(a1['balance'], 999.0);
      expect(a2['balance'], 50.0);
    });

    test('delete removes rows matching where clause and returns count',
        () async {
      await service.insert('tags', {'id': 't1', 'name': 'one'});
      await service.insert('tags', {'id': 't2', 'name': 'two'});

      final removed = await service.delete(
        'tags',
        where: 'id = ?',
        whereArgs: ['t1'],
      );

      expect(removed, 1);
      final rows = await service.query('tags');
      expect(rows.length, 1);
      expect(rows.first['id'], 't2');
    });

    test('batchUpdateBalances applies both deltas atomically', () async {
      await service.insert('accounts', {'id': 'a1', 'balance': 100.0});
      await service.insert('accounts', {'id': 'a2', 'balance': 50.0});

      await service.batchUpdateBalances('a1', -30.0, 'a2', 30.0);

      final rows = await service.query('accounts');
      final a1 = rows.firstWhere((r) => r['id'] == 'a1');
      final a2 = rows.firstWhere((r) => r['id'] == 'a2');
      expect(a1['balance'], 70.0);
      expect(a2['balance'], 80.0);
    });

    test('query returns defensive copies so mutations do not leak', () async {
      await service.insert('accounts', {'id': 'a1', 'balance': 100.0});

      final first = await service.query('accounts');
      first.first['balance'] = 9999.0;

      final second = await service.query('accounts');
      expect(second.first['balance'], 100.0);
    });

    test('query throws on unsupported predicates', () async {
      await service.insert('accounts', {'id': 'a1', 'balance': 100.0});

      expect(
        () => service.query(
          'accounts',
          where: 'balance > ?',
          whereArgs: [50.0],
        ),
        throwsA(isA<UnsupportedError>()),
      );
    });
  });
}
