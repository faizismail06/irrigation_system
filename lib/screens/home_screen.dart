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
    final now = DateTime.now();
    final formattedDate = DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(now);
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenWidth < 600;
    final isVerySmallScreen = screenWidth < 400;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        titleSpacing: isSmallScreen ? 8 : 16,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Smart Irrigation',
              style: TextStyle(
                fontSize: isVerySmallScreen
                    ? 16
                    : isSmallScreen
                        ? 18
                        : 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              formattedDate,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey,
                    fontSize: isVerySmallScreen
                        ? 10
                        : isSmallScreen
                            ? 11
                            : 12,
                  ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.refresh,
              size: isSmallScreen ? 20 : 24,
            ),
            onPressed: () {
              final model =
                  Provider.of<IrrigationModel>(context, listen: false);
              model.addTestHistoryEntry();

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Data diperbarui',
                    style: TextStyle(
                      fontSize: isSmallScreen ? 12 : 14,
                    ),
                  ),
                  duration: const Duration(seconds: 1),
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
          labelStyle: TextStyle(
            fontSize: isVerySmallScreen
                ? 10
                : isSmallScreen
                    ? 11
                    : 12,
            fontWeight: FontWeight.w500,
          ),
          unselectedLabelStyle: TextStyle(
            fontSize: isVerySmallScreen
                ? 10
                : isSmallScreen
                    ? 11
                    : 12,
          ),
          tabs: [
            Tab(
              icon: Icon(
                Icons.dashboard,
                size: isSmallScreen ? 18 : 20,
              ),
              text: 'Dashboard',
            ),
            Tab(
              icon: Icon(
                Icons.history,
                size: isSmallScreen ? 18 : 20,
              ),
              text: 'Riwayat',
            ),
          ],
        ),
      ),
      body: Consumer<IrrigationModel>(
        builder: (context, model, child) {
          if (model.isLoading) {
            return Center(
              child: SizedBox(
                width: isSmallScreen ? 30 : 40,
                height: isSmallScreen ? 30 : 40,
                child: const CircularProgressIndicator(),
              ),
            );
          }

          return TabBarView(
            controller: _tabController,
            children: [
              _buildDashboardTab(model, isSmallScreen, isVerySmallScreen),
              _buildHistoryTab(model, isSmallScreen),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDashboardTab(
      IrrigationModel model, bool isSmallScreen, bool isVerySmallScreen) {
    final screenWidth = MediaQuery.of(context).size.width;
    final basePadding = isVerySmallScreen
        ? 8.0
        : isSmallScreen
            ? 12.0
            : 16.0;
    final cardSpacing = isVerySmallScreen
        ? 8.0
        : isSmallScreen
            ? 12.0
            : 16.0;

    return RefreshIndicator(
      onRefresh: () async {
        await model.addTestHistoryEntry();
        await Future.delayed(const Duration(seconds: 1));
      },
      color: AppTheme.primaryColor,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.all(basePadding),
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

            SizedBox(height: cardSpacing),

            // Moisture status visualization
            MoistureStatusCard(
              moistureValue: model.moistureValue,
              soilStatus: model.soilStatus,
            ),

            SizedBox(height: cardSpacing),

            // Mode switch and pump controls
            _buildControlsSection(
              model,
              screenWidth,
              isSmallScreen,
              isVerySmallScreen,
              cardSpacing,
            ),

            SizedBox(height: cardSpacing),

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

  Widget _buildControlsSection(
    IrrigationModel model,
    double screenWidth,
    bool isSmallScreen,
    bool isVerySmallScreen,
    double spacing,
  ) {
    // Stack vertically on very small screens or when width is too constrained
    if (isVerySmallScreen || screenWidth < 500) {
      return Column(
        children: [
          ModeSwitchCard(
            autoMode: model.autoMode,
            onToggle: model.toggleAutoMode,
          ),
          SizedBox(height: spacing),
          PumpControlCard(
            pumpStatus: model.pumpStatus,
            autoMode: model.autoMode,
            pumpTimer: model.localTimerValue,
            isTimerActive: model.isTimerActive,
            onToggle: model.togglePump,
            onStartTimer: model.startPumpWithTimer,
            onCancelTimer: model.cancelPumpTimer,
            onPumpCommand: model.sendPumpCommand,
            onResetTimer: model.resetPumpTimer,
          ),
        ],
      );
    }

    // Side by side layout for larger screens
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 1,
          child: ModeSwitchCard(
            autoMode: model.autoMode,
            onToggle: model.toggleAutoMode,
          ),
        ),
        SizedBox(width: spacing),
        Expanded(
          flex: 1,
          child: PumpControlCard(
            pumpStatus: model.pumpStatus,
            autoMode: model.autoMode,
            pumpTimer: model.localTimerValue,
            isTimerActive: model.isTimerActive,
            onToggle: model.togglePump,
            onStartTimer: model.startPumpWithTimer,
            onCancelTimer: model.cancelPumpTimer,
            onPumpCommand: model.sendPumpCommand,
            onResetTimer: model.resetPumpTimer,
          ),
        ),
      ],
    );
  }

  Widget _buildHistoryTab(IrrigationModel model, bool isSmallScreen) {
    return HistoryCard(
      moistureHistory: model.moistureHistory,
      showViewAll: false,
      fullPage: true,
    );
  }
}
