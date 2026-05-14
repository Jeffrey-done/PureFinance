import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'storage_service.dart';

/// Browser/web [StorageService] backed by `shared_preferences` (which uses
/// `localStorage` on the web). Each "table" is persisted as a single
/// JSON-encoded array of row objects under the key `table_<name>`.
///
/// The implementation is deliberately small: the providers in this app
/// only ever issue simple equality predicates (`id = ?`, `categoryId = ?`,
/// `parentId = ?`) optionally joined by `AND`, and a single-field
/// `orderBy`. Anything beyond that throws an [UnsupportedError] so we
/// fail loudly rather than silently returning wrong data.
class WebStorageService implements StorageService {
  static const String _tablePrefix = 'table_';
  static const List<String> _tables = <String>[
    'transactions',
    'accounts',
    'categories',
    'tags',
    'recurring_transactions',
    'budgets',
  ];

  SharedPreferences? _prefs;

  Future<SharedPreferences> get _store async {
    final existing = _prefs;
    if (existing != null) return existing;
    final prefs = await SharedPreferences.getInstance();
    _prefs = prefs;
    return prefs;
  }

  @override
  Future<void> initialize() async {
    final prefs = await _store;
    // Seed empty arrays for any table that has not been touched yet so
    // subsequent reads can deserialize without null-checks.
    for (final table in _tables) {
      final key = _tablePrefix + table;
      if (!prefs.containsKey(key)) {
        await prefs.setString(key, '[]');
      }
    }
  }

  Future<List<Map<String, dynamic>>> _readTable(String table) async {
    final prefs = await _store;
    final raw = prefs.getString(_tablePrefix + table) ?? '[]';
    final decoded = jsonDecode(raw);
    if (decoded is! List) return <Map<String, dynamic>>[];
    return decoded
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }

  Future<void> _writeTable(
    String table,
    List<Map<String, dynamic>> rows,
  ) async {
    final prefs = await _store;
    await prefs.setString(_tablePrefix + table, jsonEncode(rows));
  }

  @override
  Future<int> insert(String table, Map<String, dynamic> data) async {
    final rows = await _readTable(table);
    final id = data['id'];
    final existingIndex =
        id == null ? -1 : rows.indexWhere((r) => r['id'] == id);
    if (existingIndex >= 0) {
      // Match sqflite ConflictAlgorithm.replace semantics.
      rows[existingIndex] = Map<String, dynamic>.from(data);
    } else {
      rows.add(Map<String, dynamic>.from(data));
    }
    await _writeTable(table, rows);
    return 1;
  }

  @override
  Future<List<Map<String, dynamic>>> query(
    String table, {
    String? where,
    List<Object?>? whereArgs,
    String? orderBy,
  }) async {
    final rows = await _readTable(table);
    final filtered = _applyWhere(rows, where, whereArgs);
    if (orderBy != null && orderBy.isNotEmpty) {
      _applyOrderBy(filtered, orderBy);
    }
    // Return defensive copies so callers cannot mutate stored state.
    return filtered.map((r) => Map<String, dynamic>.from(r)).toList();
  }

  @override
  Future<int> update(
    String table,
    Map<String, dynamic> data, {
    String? where,
    List<Object?>? whereArgs,
  }) async {
    final rows = await _readTable(table);
    var changed = 0;
    for (var i = 0; i < rows.length; i++) {
      if (_matches(rows[i], where, whereArgs)) {
        rows[i] = <String, dynamic>{...rows[i], ...data};
        changed++;
      }
    }
    if (changed > 0) {
      await _writeTable(table, rows);
    }
    return changed;
  }

  @override
  Future<int> delete(
    String table, {
    String? where,
    List<Object?>? whereArgs,
  }) async {
    final rows = await _readTable(table);
    final originalLength = rows.length;
    rows.removeWhere((r) => _matches(r, where, whereArgs));
    final removed = originalLength - rows.length;
    if (removed > 0) {
      await _writeTable(table, rows);
    }
    return removed;
  }

  @override
  Future<void> batchUpdateBalances(
    String fromAccountId,
    double fromDelta,
    String toAccountId,
    double toDelta,
  ) async {
    final rows = await _readTable('accounts');
    var mutated = false;
    for (var i = 0; i < rows.length; i++) {
      final id = rows[i]['id'];
      if (id == fromAccountId) {
        final current = (rows[i]['balance'] as num).toDouble();
        rows[i] = <String, dynamic>{...rows[i], 'balance': current + fromDelta};
        mutated = true;
      } else if (id == toAccountId) {
        final current = (rows[i]['balance'] as num).toDouble();
        rows[i] = <String, dynamic>{...rows[i], 'balance': current + toDelta};
        mutated = true;
      }
    }
    if (mutated) {
      await _writeTable('accounts', rows);
    }
  }

  // ---------------------------------------------------------------------------
  // Where-clause and order-by helpers.
  //
  // We only need to support the subset of SQL that this app actually issues:
  //   * simple equality on one column: `field = ?`
  //   * multiple equality predicates joined with `AND`
  //   * single-column `orderBy` of the form `field` or `field ASC|DESC`.
  // Anything else throws so unexpected queries surface immediately.
  // ---------------------------------------------------------------------------

  List<Map<String, dynamic>> _applyWhere(
    List<Map<String, dynamic>> rows,
    String? where,
    List<Object?>? whereArgs,
  ) {
    if (where == null || where.trim().isEmpty) return List.of(rows);
    return rows.where((row) => _matches(row, where, whereArgs)).toList();
  }

  bool _matches(
    Map<String, dynamic> row,
    String? where,
    List<Object?>? whereArgs,
  ) {
    if (where == null || where.trim().isEmpty) return true;
    final args = whereArgs ?? const <Object?>[];
    final predicates = where
        .split(RegExp(r'\s+AND\s+', caseSensitive: false))
        .map((p) => p.trim())
        .where((p) => p.isNotEmpty)
        .toList();

    var argIndex = 0;
    for (final predicate in predicates) {
      final match = RegExp(r'^(\w+)\s*=\s*\?$').firstMatch(predicate);
      if (match == null) {
        throw UnsupportedError(
          'WebStorageService only supports "field = ?" predicates joined by '
          'AND, got: "$predicate"',
        );
      }
      if (argIndex >= args.length) {
        throw ArgumentError(
          'Not enough whereArgs for clause "$where" (need at least '
          '${argIndex + 1}, got ${args.length}).',
        );
      }
      final field = match.group(1)!;
      final expected = args[argIndex++];
      if (row[field] != expected) return false;
    }
    return true;
  }

  void _applyOrderBy(List<Map<String, dynamic>> rows, String orderBy) {
    final parts = orderBy.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.length > 2) {
      throw UnsupportedError(
        'WebStorageService orderBy must be "field" or "field ASC|DESC", '
        'got: "$orderBy"',
      );
    }
    final field = parts[0];
    final ascending =
        parts.length == 1 || parts[1].toUpperCase() == 'ASC';
    rows.sort((a, b) {
      final result = _compareValues(a[field], b[field]);
      return ascending ? result : -result;
    });
  }

  int _compareValues(Object? a, Object? b) {
    if (a == null && b == null) return 0;
    if (a == null) return -1;
    if (b == null) return 1;
    if (a is num && b is num) return a.compareTo(b);
    return a.toString().compareTo(b.toString());
  }
}
