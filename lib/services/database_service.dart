import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  static Database? _database;

  DatabaseService._internal();

  factory DatabaseService() => _instance;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'pure_finance.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    debugPrint(
      'DatabaseService: upgrading from version $oldVersion to $newVersion',
    );
    // Future migrations go here, e.g.:
    // if (oldVersion < 2) { await db.execute('ALTER TABLE ...'); }
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE transactions(
        id TEXT PRIMARY KEY,
        type TEXT NOT NULL,
        amount REAL NOT NULL,
        currency TEXT NOT NULL,
        date TEXT NOT NULL,
        categoryId TEXT NOT NULL,
        accountId TEXT NOT NULL,
        notes TEXT,
        tags TEXT,
        isRecurring INTEGER NOT NULL DEFAULT 0,
        recurringId TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE accounts(
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        type TEXT NOT NULL,
        balance REAL NOT NULL,
        currency TEXT NOT NULL,
        icon TEXT,
        color TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE categories(
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        type TEXT NOT NULL,
        parentId TEXT,
        icon TEXT,
        color TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE tags(
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        color TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE recurring_transactions(
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        amount REAL NOT NULL,
        currency TEXT NOT NULL,
        startDate TEXT NOT NULL,
        nextDueDate TEXT NOT NULL,
        frequency TEXT NOT NULL,
        categoryId TEXT NOT NULL,
        accountId TEXT NOT NULL,
        notes TEXT,
        status TEXT NOT NULL,
        remindBeforeDays INTEGER NOT NULL DEFAULT 3
      )
    ''');

    await db.execute('''
      CREATE TABLE budgets(
        id TEXT PRIMARY KEY,
        categoryId TEXT,
        amount REAL NOT NULL
      )
    ''');
  }

  // Generic CRUD operations

  Future<int> insert(String table, Map<String, dynamic> data) async {
    final db = await database;
    return await db.insert(table, data, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Map<String, dynamic>>> query(
    String table, {
    String? where,
    List<Object?>? whereArgs,
    String? orderBy,
  }) async {
    final db = await database;
    return await db.query(table, where: where, whereArgs: whereArgs, orderBy: orderBy);
  }

  Future<int> update(
    String table,
    Map<String, dynamic> data, {
    String? where,
    List<Object?>? whereArgs,
  }) async {
    final db = await database;
    return await db.update(table, data, where: where, whereArgs: whereArgs);
  }

  Future<int> delete(
    String table, {
    String? where,
    List<Object?>? whereArgs,
  }) async {
    final db = await database;
    return await db.delete(table, where: where, whereArgs: whereArgs);
  }

  /// Atomically updates the balance of two accounts within a single database
  /// transaction. Used for transfers to prevent inconsistent state if the app
  /// crashes between individual writes.
  Future<void> batchUpdateBalances(
    String fromAccountId,
    double fromDelta,
    String toAccountId,
    double toDelta,
  ) async {
    final db = await database;
    await db.transaction((txn) async {
      // Update source account
      final fromRows = await txn.query(
        'accounts',
        where: 'id = ?',
        whereArgs: [fromAccountId],
      );
      if (fromRows.isNotEmpty) {
        final currentBalance = (fromRows.first['balance'] as num).toDouble();
        await txn.update(
          'accounts',
          {'balance': currentBalance + fromDelta},
          where: 'id = ?',
          whereArgs: [fromAccountId],
        );
      }

      // Update destination account
      final toRows = await txn.query(
        'accounts',
        where: 'id = ?',
        whereArgs: [toAccountId],
      );
      if (toRows.isNotEmpty) {
        final currentBalance = (toRows.first['balance'] as num).toDouble();
        await txn.update(
          'accounts',
          {'balance': currentBalance + toDelta},
          where: 'id = ?',
          whereArgs: [toAccountId],
        );
      }
    });
  }
}
