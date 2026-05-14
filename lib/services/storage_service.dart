/// Platform-agnostic key/value table storage interface used by providers.
///
/// Implementations exist for native (sqflite) and web (shared_preferences).
/// All values flowing through this interface use sqlite-friendly primitives:
/// `String`, `int` (0/1 for booleans), `double`, `null`, and JSON-encoded
/// strings for collection-typed columns. This keeps callers in providers
/// uniform across platforms.
abstract class StorageService {
  /// Open the underlying store (create tables / load preferences) if needed.
  Future<void> initialize();

  /// Insert a row. If a row with the same primary key (`id`) already exists
  /// it is replaced, matching sqflite's `ConflictAlgorithm.replace`.
  Future<int> insert(String table, Map<String, dynamic> data);

  /// Return rows from a table, optionally filtered by a sqflite-style
  /// `where` clause and ordered by `orderBy`. Web implementations only
  /// support a small subset of clauses (simple `field = ?` equality
  /// joined by `AND`, optional `field ASC|DESC` ordering); see
  /// [WebStorageService] for the supported syntax.
  Future<List<Map<String, dynamic>>> query(
    String table, {
    String? where,
    List<Object?>? whereArgs,
    String? orderBy,
  });

  /// Update rows matching the `where` clause with `data`. Returns the
  /// number of affected rows.
  Future<int> update(
    String table,
    Map<String, dynamic> data, {
    String? where,
    List<Object?>? whereArgs,
  });

  /// Delete rows matching the `where` clause. Returns the number of
  /// deleted rows.
  Future<int> delete(
    String table, {
    String? where,
    List<Object?>? whereArgs,
  });

  /// Atomically apply two account balance deltas (used for transfers).
  Future<void> batchUpdateBalances(
    String fromAccountId,
    double fromDelta,
    String toAccountId,
    double toDelta,
  );
}
