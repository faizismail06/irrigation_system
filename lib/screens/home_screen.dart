import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/irrigation_model.dart';
import '../widgets/dashboard_card.dart';
import '../widgets/history_card.dart';
import '../widgets/moisture_status_card.dart';
import '../widgets/pump_control_card.dart';
import '../widgets/mode_switch_card.dart';
import '../themes/app_theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
// Di dalam build method
    final now = DateTime.now();
    final formattedDate = DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(now);

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Smart Irrigation'),
            Text(
              formattedDate,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              // Add a new test entry to history
              final model =
                  Provider.of<IrrigationModel>(context, listen: false);
              model.addTestHistoryEntry();

              // Show snackbar
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Data diperbarui'),
                  duration: Duration(seconds: 1),
                ),
              );
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppTheme.primaryColor,
          unselectedLabelColor: Colors.grey,
          indicatorColor: AppTheme.primaryColor,
          tabs: const [
            Tab(
              icon: Icon(Icons.dashboard),
              text: 'Dashboard',
            ),
            Tab(
              icon: Icon(Icons.history),
              text: 'Riwayat',
            ),
          ],
        ),
      ),
      body: Consumer<IrrigationModel>(
        builder: (context, model, child) {
          if (model.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return TabBarView(
            controller: _tabController,
            children: [
              // Dashboard Tab
              _buildDashboardTab(model),

              // History Tab
              _buildHistoryTab(model),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDashboardTab(IrrigationModel model) {
    return RefreshIndicator(
      onRefresh: () async {
        // Add a new test entry to history for testing
        await model.addTestHistoryEntry();
        await Future.delayed(const Duration(seconds: 1));
      },
      color: AppTheme.primaryColor,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Dashboard summary
            DashboardCard(
              moistureValue: model.moistureValue,
              soilStatus: model.soilStatus,
              pumpStatus: model.pumpStatus,
              autoMode: model.autoMode,
              pumpTimer: model.localTimerValue,
              isTimerActive: model.isTimerActive,
            ),

            const SizedBox(height: 16),

            // Main controls
            Row(
              children: [
                // Moisture status visualization
                Expanded(
                  flex: 1,
                  child: MoistureStatusCard(
                    moistureValue: model.moistureValue,
                    soilStatus: model.soilStatus,
                  ),
                ),

                const SizedBox(width: 16),

                // Mode switch and pump controls
                Expanded(
                  flex: 1,
                  child: Column(
                    children: [
                      ModeSwitchCard(
                        autoMode: model.autoMode,
                        onToggle: model.toggleAutoMode,
                      ),
                      const SizedBox(height: 16),
                      // Widget usage dengan parameter yang lengkap
                      PumpControlCard(
                        pumpStatus: model.pumpStatus,
                        autoMode: model.autoMode,
                        pumpTimer: model.localTimerValue,
                        isTimerActive: model.isTimerActive,
                        onToggle: model.togglePump,
                        onStartTimer: model.startPumpWithTimer,
                        onCancelTimer: model.cancelPumpTimer,
                        onPumpCommand:
                            model.sendPumpCommand, // Parameter yang sudah ada
                        onResetTimer: model
                            .resetPumpTimer, // Parameter baru yang diperlukan
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Recent history preview
            HistoryCard(
              moistureHistory: model.moistureHistory.take(5).toList(),
              showViewAll: true,
              onViewAll: () {
                _tabController.animateTo(1);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryTab(IrrigationModel model) {
    return HistoryCard(
      moistureHistory: model.moistureHistory,
      showViewAll: false,
      fullPage: true,
    );
  }
}
