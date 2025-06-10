import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../themes/app_theme.dart';
import '../utils/countdown_timer.dart';

class DashboardCard extends StatelessWidget {
  final int moistureValue;
  final String soilStatus;
  final bool pumpStatus;
  final bool autoMode;
  final int pumpTimer;
  final bool isTimerActive;

  const DashboardCard({
    Key? key,
    required this.moistureValue,
    required this.soilStatus,
    required this.pumpStatus,
    required this.autoMode,
    this.pumpTimer = 0,
    this.isTimerActive = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final formattedTime = DateFormat('HH:mm').format(now);

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).cardColor,
              Theme.of(context).cardColor.withOpacity(0.8),
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.water_drop,
                        color: AppTheme.primaryColor,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Dashboard',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.darkCardColor.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.access_time,
                        size: 14,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        formattedTime,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const Divider(height: 24),

            // Timer indicator (if active)
            if (isTimerActive) ...[
              Center(
                child: CountdownTimerWidget(
                  seconds: pumpTimer,
                  isActive: pumpStatus,
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Status boxes
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildInfoItem(
                  context,
                  icon: Icons.water_drop,
                  title: 'Kelembapan',
                  value: '$moistureValue',
                  color: soilStatus == 'wet'
                      ? AppTheme.wetColor
                      : AppTheme.dryColor,
                ),
                _buildInfoItem(
                  context,
                  icon: Icons.landscape,
                  title: 'Status Tanah',
                  value: soilStatus == 'wet' ? 'Basah' : 'Kering',
                  color: soilStatus == 'wet'
                      ? AppTheme.wetColor
                      : AppTheme.dryColor,
                ),
                _buildInfoItem(
                  context,
                  icon: Icons.power,
                  title: 'Pompa',
                  value: pumpStatus ? 'Aktif' : 'Mati',
                  color: pumpStatus
                      ? AppTheme.activePumpColor
                      : AppTheme.inactivePumpColor,
                ),
                _buildInfoItem(
                  context,
                  icon: Icons.settings,
                  title: 'Mode',
                  value: autoMode ? 'Otomatis' : 'Manual',
                  color: AppTheme.secondaryColor,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: color,
            size: 24,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
        ),
      ],
    );
  }
}
