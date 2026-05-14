import 'package:flutter/foundation.dart' show kIsWeb;

import 'sqlite_storage_service.dart';
import 'storage_service.dart';
import 'web_storage_service.dart';

/// Facade over a [StorageService] that picks the right implementation for the
/// running platform. On web we use `shared_preferences` (localStorage) and on
/// native we use `sqflite`. The public API stays the same as before so the
/// providers don't need to change.
class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();

  final StorageService _impl;
  bool _initialized = false;
  Future<void>? _initializing;

  DatabaseService._internal()
      : _impl = kIsWeb ? WebStorageService() : SqliteStorageService();

  factory DatabaseService() => _instance;

  Future<void> initialize() async {
    if (_initialized) return;
    final pending = _initializing;
    if (pending != null) {
      await pending;
      return;
    }
    final future = _impl.initialize();
    _initializing = future;
    try {
      await future;
      _initialized = true;
    } finally {
      _initializing = null;
    }
  }

  Future<int> insert(String table, Map<String, dynamic> data) async {
    await initialize();
    return _impl.insert(table, data);
  }

  Future<List<Map<String, dynamic>>> query(
    String table, {
    String? where,
    List<Object?>? whereArgs,
    String? orderBy,
  }) async {
    await initialize();
    return _impl.query(
      table,
      where: where,
      whereArgs: whereArgs,
      orderBy: orderBy,
    );
  }

  Future<int> update(
    String table,
    Map<String, dynamic> data, {
    String? where,
    List<Object?>? whereArgs,
  }) async {
    await initialize();
    return _impl.update(table, data, where: where, whereArgs: whereArgs);
  }

  Future<int> delete(
    String table, {
    String? where,
    List<Object?>? whereArgs,
  }) async {
    await initialize();
    return _impl.delete(table, where: where, whereArgs: whereArgs);
  }

  Future<void> batchUpdateBalances(
    String fromAccountId,
    double fromDelta,
    String toAccountId,
    double toDelta,
  ) async {
    await initialize();
    return _impl.batchUpdateBalances(
      fromAccountId,
      fromDelta,
      toAccountId,
      toDelta,
    );
  }
}
