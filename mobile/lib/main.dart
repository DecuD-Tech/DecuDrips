import 'dart:convert';
import 'package:flutter/material.dart';
import 'db/database.dart';
import 'services/notification_service.dart';
import 'services/sync_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService().initialize();
  final database = AppDatabase();
  final syncService = SyncService(
    db: database,
    apiBaseUrl: 'http://localhost:3000/api/v1',
  );

  runApp(DocuDripApp(database: database, syncService: syncService));
}

class DocuDripApp extends StatelessWidget {
  final AppDatabase database;
  final SyncService syncService;

  const DocuDripApp({
    super.key,
    required this.database,
    required this.syncService,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DocuDrip Mobile',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6366F1),
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xFF0F172A),
        cardTheme: CardThemeData(
          color: const Color(0xFF1E293B),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      home: MainNavigationShell(
        database: database,
        syncService: syncService,
      ),
    );
  }
}

class MainNavigationShell extends StatefulWidget {
  final AppDatabase database;
  final SyncService syncService;

  const MainNavigationShell({
    super.key,
    required this.database,
    required this.syncService,
  });

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
  int _selectedIndex = 0;

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      PoolsScreen(database: widget.database),
      StreamsScreen(database: widget.database, syncService: widget.syncService),
      SettingsScreen(syncService: widget.syncService),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: StreamBuilder<List<OfflineActionsTableData>>(
        stream: widget.database.watchPendingActions(),
        builder: (context, snapshot) {
          final pendingCount = snapshot.data?.length ?? 0;

          return NavigationBar(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            backgroundColor: const Color(0xFF0F172A),
            indicatorColor: const Color(0xFF6366F1).withValues(alpha: 0.2),
            destinations: [
              const NavigationDestination(
                icon: Icon(Icons.account_balance_wallet_outlined),
                selectedIcon: Icon(Icons.account_balance_wallet, color: Color(0xFF818CF8)),
                label: 'Pools',
              ),
              NavigationDestination(
                icon: pendingCount > 0
                    ? Badge.count(
                        count: pendingCount,
                        backgroundColor: const Color(0xFF6366F1),
                        textColor: Colors.white,
                        child: const Icon(Icons.waves_outlined),
                      )
                    : const Icon(Icons.waves_outlined),
                selectedIcon: pendingCount > 0
                    ? Badge.count(
                        count: pendingCount,
                        backgroundColor: const Color(0xFF6366F1),
                        textColor: Colors.white,
                        child: const Icon(Icons.waves, color: Color(0xFF818CF8)),
                      )
                    : const Icon(Icons.waves, color: Color(0xFF818CF8)),
                label: 'Streams',
              ),
              const NavigationDestination(
                icon: Icon(Icons.settings_outlined),
                selectedIcon: Icon(Icons.settings, color: Color(0xFF818CF8)),
                label: 'Settings',
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Pools Screen: Reactive watcher over watchAllPools()
class PoolsScreen extends StatelessWidget {
  final AppDatabase database;

  const PoolsScreen({super.key, required this.database});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Funding Pools'),
        centerTitle: false,
        backgroundColor: const Color(0xFF0F172A),
        elevation: 0,
      ),
      body: StreamBuilder<List<PoolsTableData>>(
        stream: database.watchAllPools(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error loading pools: ${snapshot.error}',
                style: const TextStyle(color: Colors.redAccent),
              ),
            );
          }

          final pools = snapshot.data ?? [];

          if (pools.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.account_balance_wallet_outlined,
                    size: 64,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No Funding Pools Available',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade400,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Sync with the server to fetch active pools.',
                    style: TextStyle(color: Colors.grey.shade500),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: pools.length,
            itemBuilder: (context, index) {
              final pool = pools[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              pool.repoFullName,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: pool.status.toLowerCase() == 'active'
                                  ? Colors.green.withValues(alpha: 0.2)
                                  : Colors.orange.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              pool.status.toUpperCase(),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: pool.status.toLowerCase() == 'active'
                                    ? Colors.greenAccent
                                    : Colors.orangeAccent,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildStatItem('Funding Amount', '\$${pool.fundingAmount.toStringAsFixed(2)}'),
                          _buildStatItem('Base Rate', '${pool.baseRate.toStringAsFixed(2)}/s'),
                          _buildStatItem('Total Dripped', '\$${pool.totalDripped.toStringAsFixed(2)}'),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade400),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}

/// Streams Screen: Reactive watcher over watchAllStreams()
class StreamsScreen extends StatelessWidget {
  final AppDatabase database;
  final SyncService syncService;

  const StreamsScreen({
    super.key,
    required this.database,
    required this.syncService,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Active Streams'),
        centerTitle: false,
        backgroundColor: const Color(0xFF0F172A),
        elevation: 0,
      ),
      body: StreamBuilder<List<StreamsTableData>>(
        stream: database.watchAllStreams(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error loading streams: ${snapshot.error}',
                style: const TextStyle(color: Colors.redAccent),
              ),
            );
          }

          final streams = snapshot.data ?? [];

          if (streams.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.waves_outlined,
                    size: 64,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No Active Streams',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade400,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Contribution streams will appear here.',
                    style: TextStyle(color: Colors.grey.shade500),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: streams.length,
            itemBuilder: (context, index) {
              final stream = streams[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const CircleAvatar(
                                radius: 14,
                                backgroundColor: Color(0xFF6366F1),
                                child: Icon(Icons.person, size: 16, color: Colors.white),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                stream.authorUsername,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: stream.status.toLowerCase() == 'active'
                                  ? Colors.green.withValues(alpha: 0.2)
                                  : Colors.blue.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              stream.status.toUpperCase(),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: stream.status.toLowerCase() == 'active'
                                    ? Colors.greenAccent
                                    : Colors.blueAccent,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        stream.filePath,
                        style: TextStyle(
                          fontSize: 13,
                          fontFamily: 'monospace',
                          color: Colors.indigo.shade200,
                        ),
                      ),
                      const Divider(height: 24, color: Color(0xFF334155)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildStatItem('Accumulated', '\$${stream.accumulated.toStringAsFixed(4)}'),
                          _buildStatItem('Flow Rate', '${stream.flowRatePerSecond.toStringAsFixed(4)}/s'),
                          _buildStatItem('Approval Ratio', '${(stream.approvalRatio * 100).toStringAsFixed(0)}%'),
                        ],
                      ),
                      const Divider(height: 24, color: Color(0xFF334155)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            'Was this helpful?',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade400,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.thumb_up_outlined, size: 20),
                            color: const Color(0xFF10B981),
                            tooltip: 'Helpful',
                            visualDensity: VisualDensity.compact,
                            onPressed: () async {
                              await database.queueOfflineAction(
                                'vote',
                                jsonEncode({
                                  'stream_id': stream.id,
                                  'is_upvote': true,
                                }),
                              );
                              syncService.processOfflineQueue();
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Helpful feedback logged!'),
                                    backgroundColor: Color(0xFF10B981),
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                              }
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.thumb_down_outlined, size: 20),
                            color: const Color(0xFFFF007F),
                            tooltip: 'Unhelpful',
                            visualDensity: VisualDensity.compact,
                            onPressed: () async {
                              await database.queueOfflineAction(
                                'vote',
                                jsonEncode({
                                  'stream_id': stream.id,
                                  'is_upvote': false,
                                }),
                              );
                              syncService.processOfflineQueue();
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Unhelpful feedback logged!'),
                                    backgroundColor: Color(0xFFFF007F),
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                              }
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade400),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}

/// Settings Screen: Version info, sync status trigger, logout placeholder
class SettingsScreen extends StatefulWidget {
  final SyncService syncService;

  const SettingsScreen({super.key, required this.syncService});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isSyncing = false;

  Future<void> _handleSync() async {
    setState(() {
      _isSyncing = true;
    });

    try {
      await widget.syncService.syncAll();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sync completed successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sync failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSyncing = false;
        });
      }
    }
  }

  void _handleLogout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text('Logout', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Logout functionality placeholder. Session token will be cleared upon full auth implementation.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: false,
        backgroundColor: const Color(0xFF0F172A),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFF6366F1).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.mobile_friendly,
                      color: Color(0xFF818CF8),
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'DocuDrip Mobile',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Version 1.0.0+1',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.sync, color: Color(0xFF818CF8)),
                  title: const Text(
                    'Sync Status & Manual Refresh',
                    style: TextStyle(color: Colors.white),
                  ),
                  subtitle: const Text(
                    'Fetch latest pools, streams & flush offline actions',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  trailing: _isSyncing
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : OutlinedButton(
                          onPressed: _handleSync,
                          child: const Text('Sync Now'),
                        ),
                ),
                const Divider(height: 1, color: Color(0xFF334155)),
                ListTile(
                  leading: const Icon(Icons.lock_outline, color: Colors.orangeAccent),
                  title: const Text(
                    'Encryption Status',
                    style: TextStyle(color: Colors.white),
                  ),
                  subtitle: const Text(
                    'SQLCipher encrypted local database active',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  trailing: const Icon(Icons.check_circle, color: Colors.greenAccent, size: 20),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: _handleLogout,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent.withValues(alpha: 0.15),
                foregroundColor: Colors.redAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.logout),
              label: const Text('Log Out (Placeholder)'),
            ),
          ),
        ],
      ),
    );
  }
}
