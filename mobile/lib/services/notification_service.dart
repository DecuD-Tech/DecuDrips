import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../db/database.dart';

/// Notification Service (#59 / #6.3)
/// Manages local push notifications for stream milestone earnings and claim settlement updates.
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  static const List<double> milestoneThresholds = [10.0, 50.0, 100.0, 500.0];

  /// Initializes the local notification plugin and channel settings.
  Future<void> initialize() async {
    if (_initialized) return;

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwinSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
      macOS: darwinSettings,
    );

    try {
      await _notificationsPlugin.initialize(settings: initSettings);
      _initialized = true;
    } catch (e) {
      debugPrint('NotificationService initialization failed: $e');
    }
  }

  /// Sends a local notification for claim settlement status transitions.
  Future<void> notifyClaimStatus(ClaimsTableData claim) async {
    if (!_initialized) await initialize();

    final status = claim.status.toLowerCase();
    String title;
    String body;

    if (status == 'settled') {
      title = 'Claim Settled 🎉';
      body =
          'Your payout for \$${claim.amount.toStringAsFixed(2)} has been settled.';
    } else if (status == 'failed') {
      title = 'Claim Failed ⚠️';
      body =
          'Your payout for \$${claim.amount.toStringAsFixed(2)} could not be settled.';
    } else {
      return;
    }

    const notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        'docudrip_claims_channel',
        'Claim Status Updates',
        channelDescription: 'Notifications regarding contributor reward claim payouts',
        importance: Importance.high,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(),
    );

    try {
      final notificationId = claim.id.hashCode & 0x7FFFFFFF;
      await _notificationsPlugin.show(
        id: notificationId,
        title: title,
        body: body,
        notificationDetails: notificationDetails,
      );
    } catch (e) {
      debugPrint('Failed to show claim status notification: $e');
    }
  }

  /// Evaluates stream accumulated balances against milestones ($10, $50, $100, $500)
  /// with SharedPreferences deduplication keys to ensure alerts fire only once.
  Future<void> checkMilestones(List<StreamsTableData> streams) async {
    if (!_initialized) await initialize();

    final prefs = await SharedPreferences.getInstance();

    const notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        'docudrip_milestones_channel',
        'Stream Milestones',
        channelDescription: 'Alerts when documentation streams hit reward milestones',
        importance: Importance.defaultImportance,
        priority: Priority.defaultPriority,
      ),
      iOS: DarwinNotificationDetails(),
    );

    for (final stream in streams) {
      for (final threshold in milestoneThresholds) {
        if (stream.accumulated >= threshold) {
          final prefKey = 'milestone_notified_${stream.id}_$threshold';
          final alreadyNotified = prefs.getBool(prefKey) ?? false;

          if (!alreadyNotified) {
            final title = 'Milestone Reached! 🚀';
            final body =
                'Stream for "${stream.filePath}" crossed \$${threshold.toStringAsFixed(0)} in rewards!';

            try {
              final notificationId = (stream.id.hashCode ^ threshold.toInt()) & 0x7FFFFFFF;
              await _notificationsPlugin.show(
                id: notificationId,
                title: title,
                body: body,
                notificationDetails: notificationDetails,
              );
              await prefs.setBool(prefKey, true);
            } catch (e) {
              debugPrint('Failed to show milestone notification: $e');
            }
          }
        }
      }
    }
  }
}
