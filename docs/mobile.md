# Flutter Mobile Client Caching (`mobile/`)

To support offline-first usage, our conceptual mobile companion dashboard is scaffolded around a robust SQLite persistence layer powered by Simon Binder's reactive **Drift** library for Dart/Flutter.

---

## 💾 Caching Strategy & Caching Layer

The mobile client operates as an **offline-first caching client**:

```
[Local Flutter UI] <───watch───> [Drift Local Database (SQLite)]
                                       ▲
                                    syncAll()
                                       │
                                [Rust Axum API]
```

* **No Direct API Dependencies:** Visual lists and reward counters read directly from the local Drift SQLite database via reactive streams.
* **Sub-millisecond Refreshes:** Any write or database update triggers immediate reactive stream emits, updating UI widgets instantly without manual UI state management.
* **Periodic Background Syncing:** A background scheduler (like Flutter's `workmanager`) wakes up periodically to fetch fresh states from the backend Axum API and batch upsert them to the local database.

---

## 🗃️ Drift Database Schema (`database.dart`)

The SQLite schema and reactive queries are defined inside `mobile/lib/db/database.dart`:

### 1. Caching Tables
We mirror the core backend models inside local SQLite structures:
```dart
class StreamsTable extends Table {
  TextColumn get id => text()();
  TextColumn get poolId => text()();
  TextColumn get authorUsername => text()();
  TextColumn get filePath => text()();
  IntColumn get characterCount => integer()();
  TextColumn get locale => text()();
  RealColumn get accumulated => real()();
  RealColumn get flowRatePerSecond => real()();
  RealColumn get approvalRatio => real()();
  TextColumn get status => text()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
```

### 2. Reactive Watch Streams
We expose standard watch queries that automatically emit new lists whenever SQLite data changes:
```dart
@DriftDatabase(tables: [PoolsTable, StreamsTable])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  /// Watch active documentation streams reactively
  Stream<List<StreamsTableData>> watchAllStreams() {
    return (select(streamsTable)
          ..orderBy([
            (t) => OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc)
          ]))
        .watch();
  }
}
```

### 3. Local Cache Synchronizers
On background sync runs, we perform batch updates to commit server state locally:
```dart
Future<void> syncStreams(List<StreamsTableData> streams) async {
  await batch((batch) {
    batch.insertAllOnConflictUpdate(streamsTable, streams);
  });
}
```
Using Drift's `insertAllOnConflictUpdate` guarantees that any changes in active stream balances are cleanly merged without creating duplicate key records.
