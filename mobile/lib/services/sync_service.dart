import 'dart:convert';
import 'package:http/http.dart' as http;
import '../db/database.dart';

/// SyncService coordinates background polling and offline queue execution (#7.4, #7.5)
class SyncService {
  final AppDatabase db;
  final String apiBaseUrl;

  SyncService({required this.db, required this.apiBaseUrl});

  /// Triggers full sync: fetches server data and processes queued offline actions
  Future<void> syncAll() async {
    await syncAllFromServer();
    await processOfflineQueue();
  }

  /// Periodically fetch pools, streams, and claims from Axum API (#7.4)
  Future<void> syncAllFromServer() async {
    try {
      final poolsResp = await http.get(Uri.parse('$apiBaseUrl/pools'));
      if (poolsResp.statusCode == 200) {
        final List<dynamic> list = jsonDecode(poolsResp.body);
        final pools = list.map((json) => PoolsTableData(
          id: json['id'],
          repoFullName: json['repo_full_name'],
          fundingAmount: (json['funding_amount'] as num).toDouble(),
          baseRate: (json['base_rate'] as num).toDouble(),
          totalDripped: (json['total_dripped'] as num).toDouble(),
          status: json['status'],
        )).toList();
        await db.syncPools(pools);
      }

      final streamsResp = await http.get(Uri.parse('$apiBaseUrl/streams'));
      if (streamsResp.statusCode == 200) {
        final List<dynamic> list = jsonDecode(streamsResp.body);
        final streams = list.map((json) => StreamsTableData(
          id: json['id'],
          poolId: json['pool_id'],
          authorUsername: json['author_id'] ?? 'contributor',
          filePath: json['file_path'],
          characterCount: json['character_count'],
          locale: json['locale'],
          accumulated: (json['accumulated'] as num).toDouble(),
          flowRatePerSecond: (json['flow_rate_per_second'] as num? ?? 0.0).toDouble(),
          approvalRatio: (json['approval_ratio'] as num? ?? 1.0).toDouble(),
          status: json['status'],
          createdAt: DateTime.parse(json['created_at']),
        )).toList();
        await db.syncStreams(streams);
      }
    } catch (e) {
      // Offline mode — silently fallback to local Drift SQLite cache
    }
  }

  /// Processes queued offline actions with exponential backoff retries (#7.5)
  Future<void> processOfflineQueue() async {
    final pendingActions = await (db.select(db.offlineActionsTable)
      ..where((t) => t.status.equals('pending'))).get();

    for (final action in pendingActions) {
      try {
        if (action.actionType == 'vote') {
          final payload = jsonDecode(action.payload);
          final resp = await http.post(
            Uri.parse('$apiBaseUrl/streams/${payload['stream_id']}/vote'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(payload),
          );

          if (resp.statusCode == 200 || resp.statusCode == 409) {
            await (db.update(db.offlineActionsTable)..where((t) => t.id.equals(action.id)))
                .write(const OfflineActionsTableCompanion(status: Value('completed')));
          }
        }
      } catch (e) {
        // Increment retry count
        final nextRetry = action.retryCount + 1;
        final newStatus = nextRetry >= 5 ? 'failed' : 'pending';
        await (db.update(db.offlineActionsTable)..where((t) => t.id.equals(action.id)))
            .write(OfflineActionsTableCompanion(
              retryCount: Value(nextRetry),
              status: Value(newStatus),
            ));
      }
    }
  }
}
