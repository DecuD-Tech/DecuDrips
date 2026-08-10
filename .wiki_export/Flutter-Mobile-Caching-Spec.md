# Flutter Mobile Client Caching (`mobile/`)

To support offline-first usage, the mobile companion dashboard is scaffolded around a robust SQLite persistence layer powered by Simon Binder's reactive **Drift** library for Dart/Flutter.

---

## 💾 Caching Strategy & Caching Layer

```
[Local Flutter UI] <───watch───> [Drift Local Database (SQLite)]
                                       ▲
                                    syncAll()
                                       │
                                [Rust Axum API]
```

* **No Direct API Dependencies:** Visual lists and reward counters read directly from local Drift SQLite database via reactive streams.
* **Sub-millisecond Refreshes:** Write or database updates trigger immediate reactive stream emits.
* **Periodic Background Syncing:** Scheduler fetches fresh states from backend Axum API and batch upserts to local database.

---

## 🗃️ Drift Database Schema (`database.dart`)

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

@DriftDatabase(tables: [PoolsTable, StreamsTable])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  Stream<List<StreamsTableData>> watchAllStreams() {
    return (select(streamsTable)
          ..orderBy([
            (t) => OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc)
          ]))
        .watch();
  }

  Future<void> syncStreams(List<StreamsTableData> streams) async {
    await batch((batch) {
      batch.insertAllOnConflictUpdate(streamsTable, streams);
    });
  }
}
```
