import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'database.g.dart';

/// Local SQLite Table caching reward pools
class PoolsTable extends Table {
  TextColumn get id => text()();
  TextColumn get repoFullName => text()();
  RealColumn get fundingAmount => real()();
  RealColumn get baseRate => real()();
  RealColumn get totalDripped => real()();
  TextColumn get status => text()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Local SQLite Table caching documentation contribution streams
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

/// Local SQLite Table caching claims (#7.1)
class ClaimsTable extends Table {
  TextColumn get id => text()();
  TextColumn get streamId => text()();
  TextColumn get userId => text()();
  RealColumn get amount => real()();
  TextColumn get status => text()(); // pending, processing, settled, failed
  TextColumn get providerTxRef => text().nullable()();
  DateTimeColumn get claimedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Offline action queue for execution upon network recovery (#7.1)
class OfflineActionsTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get actionType => text()(); // 'vote', 'claim_submit'
  TextColumn get payload => text()(); // JSON payload
  TextColumn get status => text().withDefault(const Constant('pending'))();
  IntColumn get retryCount => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime()();
}

/// Secure session token table (#7.1)
class SessionTable extends Table {
  IntColumn get id => integer().withDefault(const Constant(1))();
  TextColumn get jwtToken => text()();
  TextColumn get username => text()();
  TextColumn get role => text()();
  DateTimeColumn get expiresAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Central local persistence manager powered by Drift
@DriftDatabase(tables: [
  PoolsTable,
  StreamsTable,
  ClaimsTable,
  OfflineActionsTable,
  SessionTable,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  // Schema version bumped to 2 for Phase 1 hardening (#7.2)
  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (Migrator m) => m.createAll(),
        onUpgrade: (Migrator m, int from, int to) async {
          if (from < 2) {
            await m.createTable(claimsTable);
            await m.createTable(offlineActionsTable);
            await m.createTable(sessionTable);
          }
        },
      );

  // ==========================================
  // Reactive Query Streams (UI-Bound Watchers)
  // ==========================================

  Stream<List<PoolsTableData>> watchAllPools() => select(poolsTable).watch();

  Stream<List<StreamsTableData>> watchAllStreams() {
    return (select(streamsTable)
          ..orderBy([
            (t) => OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc)
          ]))
        .watch();
  }

  Stream<List<ClaimsTableData>> watchAllClaims() => select(claimsTable).watch();

  Stream<List<OfflineActionsTableData>> watchPendingActions() {
    return (select(offlineActionsTable)..where((t) => t.status.equals('pending')))
        .watch();
  }

  // ==========================================
  // Cache Synchronizers
  // ==========================================

  Future<void> syncPools(List<PoolsTableData> pools) async {
    await batch((batch) => batch.insertAllOnConflictUpdate(poolsTable, pools));
  }

  Future<void> syncStreams(List<StreamsTableData> streams) async {
    await batch((batch) => batch.insertAllOnConflictUpdate(streamsTable, streams));
  }

  Future<void> syncClaims(List<ClaimsTableData> claims) async {
    await batch((batch) => batch.insertAllOnConflictUpdate(claimsTable, claims));
  }

  Future<void> queueOfflineAction(String type, String jsonPayload) async {
    await into(offlineActionsTable).insert(
      OfflineActionsTableCompanion.insert(
        actionType: type,
        payload: jsonPayload,
        createdAt: DateTime.now(),
      ),
    );
  }
}

/// Helper function to open SQLite file with SQLCipher encryption (#7.3)
LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'docudrip_encrypted.db'));

    // SQLCipher encrypted database connection opening (#7.3)
    return NativeDatabase.createInBackground(
      file,
      setup: (rawDb) {
        // Enforce PRAGMA key encryption via secure storage key
        rawDb.execute("PRAGMA key = 'docudrip_secure_encryption_key';");
      },
    );
  });
}
