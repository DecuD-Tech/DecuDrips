import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

// Drift code generation target file
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

/// Central local persistence manager powered by Drift
@DriftDatabase(tables: [PoolsTable, StreamsTable])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  // ==========================================
  // Reactive Query Streams (UI-Bound Watchers)
  // ==========================================

  /// Watch active funding pools list reactively
  Stream<List<PoolsTableData>> watchAllPools() {
    return select(poolsTable).watch();
  }

  /// Watch active docs reward streams list reactively
  Stream<List<StreamsTableData>> watchAllStreams() {
    return (select(streamsTable)
          ..orderBy([
            (t) => OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc)
          ]))
        .watch();
  }

  /// Watch metrics calculations for a single contribution stream
  Stream<StreamsTableData?> watchStreamById(String id) {
    return (select(streamsTable)..where((t) => t.id.equals(id)))
        .watchSingleOrNull();
  }

  // ==========================================
  // Data Mutation Actions (Cache Synchronizer)
  // ==========================================

  /// Batch upsert pools fetched from Rust Axum API
  Future<void> syncPools(List<PoolsTableData> pools) async {
    await batch((batch) {
      batch.insertAllOnConflictUpdate(poolsTable, pools);
    });
  }

  /// Batch upsert streams fetched from Rust Axum API
  Future<void> syncStreams(List<StreamsTableData> streams) async {
    await batch((batch) {
      batch.insertAllOnConflictUpdate(streamsTable, streams);
    });
  }

  /// Record an offline vote visually before server sync
  Future<void> recordOfflineVote(String streamId, bool isUpvote) async {
    final stream = await (select(streamsTable)..where((t) => t.id.equals(streamId))).getSingleOrNull();
    if (stream == null) return;

    // Simulate approval ratio scales locally
    final double updatedRatio = isUpvote 
        ? (stream.approvalRatio + 0.05).clamp(0.0, 1.0)
        : (stream.approvalRatio - 0.05).clamp(0.0, 1.0);

    await update(streamsTable).write(
      StreamsTableCompanion(
        id: Value(streamId),
        approvalRatio: Value(updatedRatio),
      ),
    );
  }
}

/// Helper function to open SQLite file on client devices
LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'docudrip.db'));
    return NativeDatabase.createInBackground(file);
  });
}
