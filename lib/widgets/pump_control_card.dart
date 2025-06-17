import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../themes/app_theme.dart';
import '../utils/countdown_timer.dart';

class PumpControlCard extends StatelessWidget {
  final bool pumpStatus;
  final bool autoMode;
  final VoidCallback onToggle;
  final Function(int) onStartTimer;
  final VoidCallback onCancelTimer;
  final Function(bool) onPumpCommand;
  final VoidCallback onResetTimer;
  final int pumpTimer;
  final bool isTimerActive;

  const PumpControlCard({
    Key? key,
    required this.pumpStatus,
    required this.autoMode,
    required this.onToggle,
    required this.onStartTimer,
    required this.onCancelTimer,
    required this.onPumpCommand,
    required this.onResetTimer,
    this.pumpTimer = 0,
    this.isTimerActive = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenWidth < 600;
    final isVerySmallScreen = screenWidth < 400;
    final isShortScreen = screenHeight < 700;

    // Check if timer has reached 00:00 but pump is still showing as active
    final shouldShowInactive = isTimerActive && pumpTimer <= 0;
    final displayPumpStatus = shouldShowInactive ? false : pumpStatus;

    // Send pump command to false and reset timer when timer reaches 00:00
    if (shouldShowInactive && pumpStatus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        onPumpCommand(false);
        onResetTimer();
      });
    }

    final activeColor = displayPumpStatus
        ? AppTheme.activePumpColor
        : AppTheme.inactivePumpColor;

    // Responsive measurements
    final cardPadding = isVerySmallScreen
        ? 10.0
        : isSmallScreen
            ? 12.0
            : 16.0;
    final iconSize = isVerySmallScreen
        ? 12.0
        : isSmallScreen
            ? 14.0
            : 16.0;
    final iconPadding = isVerySmallScreen ? 6.0 : 8.0;
    final sectionSpacing = isVerySmallScreen
        ? 8.0
        : isSmallScreen
            ? 12.0
            : 16.0;
    final innerPadding = isVerySmallScreen
        ? 10.0
        : isSmallScreen
            ? 12.0
            : 16.0;
    final pumpIconSize = isVerySmallScreen
        ? 16.0
        : isSmallScreen
            ? 20.0
            : 24.0;
    final pumpIconPadding = isVerySmallScreen
        ? 4.0
        : isSmallScreen
            ? 6.0
            : 8.0;

    return Card(
      elevation: isSmallScreen ? 2 : 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(isSmallScreen ? 12 : 16),
      ),
      child: Padding(
        padding: EdgeInsets.all(cardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(iconPadding),
                  decoration: BoxDecoration(
                    color: activeColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(isSmallScreen ? 6 : 8),
                  ),
                  child: Icon(
                    Icons.water,
                    color: activeColor,
                    size: iconSize,
                  ),
                ),
                SizedBox(width: isVerySmallScreen ? 6 : 8),
                Expanded(
                  child: Text(
                    'Kontrol Pompa',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontSize: isVerySmallScreen
                              ? 12
                              : isSmallScreen
                                  ? 14
                                  : 16,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
              ],
            ),

            SizedBox(height: sectionSpacing),

            // Pump status indicator
            Container(
              padding: EdgeInsets.all(innerPadding),
              decoration: BoxDecoration(
                color: activeColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(isSmallScreen ? 12 : 16),
                border: Border.all(
                  color: activeColor.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  // Animated pump icon
                  if (displayPumpStatus)
                    Container(
                      padding: EdgeInsets.all(pumpIconPadding),
                      decoration: BoxDecoration(
                        color: AppTheme.activePumpColor,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.water,
                        color: Colors.white,
                        size: pumpIconSize,
                      ),
                    )
                        .animate(
                          onPlay: (controller) => controller.repeat(),
                        )
                        .scale(
                          duration: 1.seconds,
                          curve: Curves.easeInOut,
                          begin: const Offset(1, 1),
                          end: const Offset(1.1, 1.1),
                        )
                        .then()
                        .scale(
                          duration: 1.seconds,
                          curve: Curves.easeInOut,
                          begin: const Offset(1, 1),
                          end: const Offset(0.9, 0.9),
                        )
                  else
                    Container(
                      padding: EdgeInsets.all(pumpIconPadding),
                      decoration: BoxDecoration(
                        color: AppTheme.inactivePumpColor.withOpacity(0.8),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.water_drop,
                        color: Colors.white,
                        size: pumpIconSize,
                      ),
                    ),

                  SizedBox(
                      width: isVerySmallScreen
                          ? 8
                          : isSmallScreen
                              ? 12
                              : 16),

                  // Status text
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _getPumpStatusText(
                              displayPumpStatus, isTimerActive, pumpTimer),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: activeColor,
                            fontSize: isVerySmallScreen
                                ? 11
                                : isSmallScreen
                                    ? 13
                                    : 16,
                          ),
                        ),
                        SizedBox(
                            height: isVerySmallScreen
                                ? 1
                                : isSmallScreen
                                    ? 2
                                    : 4),
                        Text(
                          _getPumpDescriptionText(
                              displayPumpStatus, isTimerActive, pumpTimer),
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: isVerySmallScreen
                                ? 9
                                : isSmallScreen
                                    ? 10
                                    : 12,
                            height: 1.2,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (isTimerActive && pumpTimer > 0) ...[
                          SizedBox(
                              height: isVerySmallScreen
                                  ? 4
                                  : isSmallScreen
                                      ? 6
                                      : 8),
                          Text(
                            'Pompa akan otomatis mati dalam:',
                            style: TextStyle(
                              color: Colors.grey.shade400,
                              fontSize: isVerySmallScreen
                                  ? 8
                                  : isSmallScreen
                                      ? 9
                                      : 11,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                          SizedBox(
                              height: isVerySmallScreen
                                  ? 1
                                  : isSmallScreen
                                      ? 2
                                      : 4),
                          CountdownTimerWidget(
                            seconds: pumpTimer,
                            isActive: displayPumpStatus,
                            onCancel: onCancelTimer,
                          ),
                        ] else if (isTimerActive && pumpTimer <= 0) ...[
                          SizedBox(
                              height: isVerySmallScreen
                                  ? 4
                                  : isSmallScreen
                                      ? 6
                                      : 8),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: isVerySmallScreen ? 8 : 12,
                              vertical: isVerySmallScreen ? 4 : 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.orange.shade100,
                              borderRadius:
                                  BorderRadius.circular(isSmallScreen ? 4 : 6),
                              border: Border.all(
                                color: Colors.orange.shade300,
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.schedule,
                                  size: isVerySmallScreen
                                      ? 12
                                      : isSmallScreen
                                          ? 14
                                          : 16,
                                  color: Colors.orange.shade700,
                                ),
                                SizedBox(width: isVerySmallScreen ? 3 : 6),
                                Text(
                                  'Pompa dimatikan',
                                  style: TextStyle(
                                    color: Colors.orange.shade700,
                                    fontSize: isVerySmallScreen
                                        ? 8
                                        : isSmallScreen
                                            ? 9
                                            : 11,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: sectionSpacing),

            // Control buttons
            if (autoMode)
              // Auto mode indicator
              Container(
                padding: EdgeInsets.symmetric(
                  vertical: isVerySmallScreen
                      ? 8
                      : isSmallScreen
                          ? 10
                          : 12,
                  horizontal: isVerySmallScreen ? 12 : 16,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(isSmallScreen ? 6 : 8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.auto_mode,
                      color: Colors.grey.shade600,
                      size: isVerySmallScreen
                          ? 14
                          : isSmallScreen
                              ? 16
                              : 18,
                    ),
                    SizedBox(width: isVerySmallScreen ? 6 : 8),
                    Text(
                      'Mode Otomatis Aktif',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                        fontSize: isVerySmallScreen
                            ? 10
                            : isSmallScreen
                                ? 12
                                : 14,
                      ),
                    ),
                  ],
                ),
              )
            else
              // Manual control button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _handlePumpControl(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _getButtonColor(
                        displayPumpStatus, isTimerActive, pumpTimer),
                    padding: EdgeInsets.symmetric(
                      vertical: isVerySmallScreen
                          ? 10
                          : isSmallScreen
                              ? 12
                              : 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(isSmallScreen ? 6 : 8),
                    ),
                  ),
                  icon: Icon(
                    _getButtonIcon(displayPumpStatus, isTimerActive, pumpTimer),
                    size: isVerySmallScreen
                        ? 18
                        : isSmallScreen
                            ? 20
                            : 22,
                  ),
                  label: Text(
                    _getButtonText(displayPumpStatus, isTimerActive, pumpTimer),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: isVerySmallScreen
                          ? 12
                          : isSmallScreen
                              ? 14
                              : 16,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _getPumpStatusText(bool displayStatus, bool timerActive, int timer) {
    if (timerActive && timer <= 0) {
      return 'Timer Selesai';
    }
    return displayStatus ? 'Pompa Aktif' : 'Pompa Tidak Aktif';
  }

  String _getPumpDescriptionText(
      bool displayStatus, bool timerActive, int timer) {
    if (timerActive && timer <= 0) {
      return 'Pompa telah dimatikan otomatis';
    }
    return displayStatus
        ? 'Air sedang mengalir ke tanaman'
        : 'Tidak ada air yang mengalir';
  }

  Color _getButtonColor(bool displayStatus, bool timerActive, int timer) {
    if (timerActive && timer <= 0) {
      return AppTheme.activePumpColor; // Green to start again
    }
    return displayStatus
        ? AppTheme.inactivePumpColor // Red to turn off
        : AppTheme.activePumpColor; // Green to turn on
  }

  IconData _getButtonIcon(bool displayStatus, bool timerActive, int timer) {
    if (timerActive && timer <= 0) {
      return Icons.power; // Power on icon when timer finished
    }
    return displayStatus ? Icons.power_off : Icons.power;
  }

  String _getButtonText(bool displayStatus, bool timerActive, int timer) {
    if (timerActive && timer <= 0) {
      return 'NYALAKAN POMPA'; // Ready to start again
    }
    return displayStatus ? 'MATIKAN POMPA' : 'NYALAKAN POMPA';
  }

  void _handlePumpControl(BuildContext context) {
    // If timer has finished, reset the state first
    if (isTimerActive && pumpTimer <= 0) {
      onCancelTimer(); // This should reset the timer state
      onPumpCommand(false); // Ensure pump is turned off
      onResetTimer(); // Reset timer to 0
      // Don't toggle immediately, let user press again to start
      return;
    }

    if (pumpStatus) {
      // If pump is currently on, turn it off directly and cancel timer
      onCancelTimer(); // Cancel the timer first
      onToggle(); // Then turn off the pump
      onPumpCommand(false); // Send false command
      onResetTimer(); // Reset timer to 0
    } else {
      // If pump is off, show timer selection dialog first
      _showTimerSelectionDialog(context);
    }
  }

  void _showTimerSelectionDialog(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenWidth < 600;
    final isVerySmallScreen = screenWidth < 400;
    final isShortScreen = screenHeight < 700;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Pilih Durasi Timer',
            style: TextStyle(
              fontSize: isVerySmallScreen
                  ? 14
                  : isSmallScreen
                      ? 16
                      : 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Pilih berapa lama pompa akan menyala:',
                style: TextStyle(
                  fontSize: isVerySmallScreen
                      ? 11
                      : isSmallScreen
                          ? 12
                          : 14,
                  color: Colors.grey.shade600,
                ),
              ),
              SizedBox(height: isVerySmallScreen ? 12 : 16),
              _buildTimerOptions(
                  context, isSmallScreen, isVerySmallScreen, isShortScreen),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'BATAL',
                style: TextStyle(
                  fontSize: isVerySmallScreen
                      ? 11
                      : isSmallScreen
                          ? 12
                          : 14,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTimerOptions(BuildContext context, bool isSmallScreen,
      bool isVerySmallScreen, bool isShortScreen) {
    final timerOptions = [
      {'label': '1 Menit', 'seconds': 60},
      {'label': '2 Menit', 'seconds': 120},
      {'label': '5 Menit', 'seconds': 300},
      {'label': '10 Menit', 'seconds': 600},
      {'label': '15 Menit', 'seconds': 900},
      {'label': '30 Menit', 'seconds': 1800},
      {'label': '1 Jam', 'seconds': 3600},
      {'label': '2 Jam', 'seconds': 7200},
    ];

    // Adjust number of options based on screen height
    final maxOptions = isShortScreen ? 6 : 8;
    final displayOptions = timerOptions.take(maxOptions).toList();

    return SizedBox(
      height: isShortScreen ? 300 : 400,
      width: double.maxFinite,
      child: SingleChildScrollView(
        child: Column(
          children: displayOptions.map((option) {
            return Container(
              width: double.infinity,
              margin: EdgeInsets.only(
                bottom: isVerySmallScreen ? 6 : 8,
              ),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  // Add delay to ensure smooth activation
                  Future.delayed(const Duration(milliseconds: 100), () {
                    onStartTimer(option['seconds'] as int);
                    onPumpCommand(
                        true); // Send true command when starting timer
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.activePumpColor,
                  padding: EdgeInsets.symmetric(
                    vertical: isVerySmallScreen
                        ? 8
                        : isSmallScreen
                            ? 10
                            : 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(isSmallScreen ? 6 : 8),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.timer,
                      size: isVerySmallScreen
                          ? 14
                          : isSmallScreen
                              ? 16
                              : 18,
                      color: Colors.white,
                    ),
                    SizedBox(width: isVerySmallScreen ? 6 : 8),
                    Text(
                      option['label'] as String,
                      style: TextStyle(
                        fontSize: isVerySmallScreen
                            ? 11
                            : isSmallScreen
                                ? 12
                                : 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
