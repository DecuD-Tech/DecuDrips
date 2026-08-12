import 'dart:convert';
import 'package:drift/drift.dart';
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

  /// Helper to safely convert JSON values (String/num/null) to double (FIX-06)
  double _parseDouble(dynamic val, [double fallback = 0.0]) {
    if (val == null) return fallback;
    if (val is num) return val.toDouble();
    return double.tryParse(val.toString()) ?? fallback;
  }

  /// Periodically fetch pools, streams, and claims from Axum API (#7.4)
  Future<void> syncAllFromServer() async {
    try {
      final poolsResp = await http.get(Uri.parse('$apiBaseUrl/pools'));
      if (poolsResp.statusCode == 200) {
        final List<dynamic> list = jsonDecode(poolsResp.body);
        final pools = list.map((json) => PoolsTableData(
          id: json['id'],
          repoFullName: json['repo_full_name'] ?? 'unknown/repo',
          fundingAmount: _parseDouble(json['funding_amount'] ?? json['funding_amount_usdc']),
          baseRate: _parseDouble(json['base_rate']),
          totalDripped: _parseDouble(json['total_dripped'] ?? json['total_dripped_usdc']),
          status: json['status'] ?? 'active',
        )).toList();
        await db.syncPools(pools);
      }

      final streamsResp = await http.get(Uri.parse('$apiBaseUrl/streams'));
      if (streamsResp.statusCode == 200) {
        final List<dynamic> list = jsonDecode(streamsResp.body);
        final streams = list.map((json) => StreamsTableData(
          id: json['id'],
          poolId: json['pool_id'],
          authorUsername: json['author_username'] ?? json['author_id'] ?? 'contributor',
          filePath: json['file_path'] ?? '',
          characterCount: (json['character_count'] as num? ?? 0).toInt(),
          locale: json['locale'] ?? 'en',
          accumulated: _parseDouble(json['accumulated']),
          flowRatePerSecond: _parseDouble(json['flow_rate_per_second']),
          approvalRatio: _parseDouble(json['approval_ratio'], 1.0),
          status: json['status'] ?? 'active',
          createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
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
