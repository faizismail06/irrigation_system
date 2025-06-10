import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../models/irrigation_model.dart';
import '../themes/app_theme.dart';

class HistoryCard extends StatelessWidget {
  final List<MoistureRecord> moistureHistory;
  final bool showViewAll;
  final VoidCallback? onViewAll;
  final bool fullPage;

  const HistoryCard({
    Key? key,
    required this.moistureHistory,
    this.showViewAll = false,
    this.onViewAll,
    this.fullPage = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (fullPage) {
      return _buildFullPageHistory(context);
    }

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
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
                        color: AppTheme.secondaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.history,
                        color: AppTheme.secondaryColor,
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Riwayat Kelembapan',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
                if (showViewAll && onViewAll != null)
                  TextButton.icon(
                    onPressed: onViewAll,
                    icon: const Icon(Icons.arrow_forward, size: 16),
                    label: const Text('Lihat Semua'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppTheme.secondaryColor,
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 16),

            // Chart or empty state
            if (moistureHistory.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: Text('Belum ada data riwayat'),
                ),
              )
            else
              SizedBox(
                height: 200,
                child: LineChart(
                  _buildLineChartData(context),
                ),
              ),

            if (moistureHistory.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),

              // Recent history list header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Data Terakhir',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  Text(
                    'Pembaruan Terakhir: ${_getLastUpdateTime()}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey,
                          fontSize: 10,
                        ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Recent history list
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount:
                    moistureHistory.length > 5 ? 5 : moistureHistory.length,
                itemBuilder: (context, index) {
                  final record = moistureHistory[index];
                  final isWet = record.soilStatus == 'wet';

                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isWet
                            ? AppTheme.wetColor.withOpacity(0.1)
                            : AppTheme.dryColor.withOpacity(0.1),
                      ),
                      child: Icon(
                        Icons.water_drop,
                        color: isWet ? AppTheme.wetColor : AppTheme.dryColor,
                        size: 20,
                      ),
                    ),
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          isWet ? 'Tanah Basah' : 'Tanah Kering',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color:
                                isWet ? AppTheme.wetColor : AppTheme.dryColor,
                          ),
                        ),
                        Text(
                          DateFormat('HH:mm, dd MMM').format(record.timestamp),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                    subtitle: Text(
                      'Nilai: ${record.moistureValue}',
                      style: const TextStyle(
                        fontSize: 12,
                      ),
                    ),
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFullPageHistory(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Chart
          if (moistureHistory.isNotEmpty) ...[
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppTheme.secondaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.analytics,
                            color: AppTheme.secondaryColor,
                            size: 16,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Grafik Kelembapan',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    SizedBox(
                      height: 250,
                      child: LineChart(
                        _buildLineChartData(context, showAllLabels: true),
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Legend
                    Wrap(
                      spacing: 16,
                      children: [
                        _buildLegendItem(context,
                            color: AppTheme.wetColor, label: 'Tanah Basah'),
                        _buildLegendItem(context,
                            color: AppTheme.dryColor, label: 'Tanah Kering'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // History timeline
          Card(
            elevation: 4,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppTheme.secondaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.history,
                          color: AppTheme.secondaryColor,
                          size: 16,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Riwayat Lengkap',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (moistureHistory.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32.0),
                        child: Text('Belum ada data riwayat'),
                      ),
                    )
                  else
                    _buildTimelineView(context),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(BuildContext context,
      {required Color color, required String label}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _buildTimelineView(BuildContext context) {
    // Group by date
    final groupedRecords = <DateTime, List<MoistureRecord>>{};

    for (final record in moistureHistory) {
      final date = DateTime(
        record.timestamp.year,
        record.timestamp.month,
        record.timestamp.day,
      );

      if (!groupedRecords.containsKey(date)) {
        groupedRecords[date] = [];
      }

      groupedRecords[date]!.add(record);
    }

    // Sort dates (newest first)
    final dates = groupedRecords.keys.toList()..sort((a, b) => b.compareTo(a));

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: dates.length,
      itemBuilder: (context, dateIndex) {
        final date = dates[dateIndex];
        final records = groupedRecords[date]!;
        final dateStr = DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(date);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                dateStr,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: AppTheme.secondaryColor,
                    ),
              ),
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: records.length,
              itemBuilder: (context, recordIndex) {
                final record = records[recordIndex];
                final isWet = record.soilStatus == 'wet';
                final time = DateFormat('HH:mm').format(record.timestamp);

                return IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Timeline line and dot
                      SizedBox(
                        width: 20,
                        child: Column(
                          children: [
                            // Dot
                            Container(
                              width: 10,
                              height: 10,
                              margin: const EdgeInsets.only(top: 16),
                              decoration: BoxDecoration(
                                color: isWet
                                    ? AppTheme.wetColor
                                    : AppTheme.dryColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                            // Line (if not last item)
                            if (recordIndex < records.length - 1)
                              Expanded(
                                child: Container(
                                  width: 2,
                                  margin:
                                      const EdgeInsets.symmetric(vertical: 4),
                                  color: (isWet
                                          ? AppTheme.wetColor
                                          : AppTheme.dryColor)
                                      .withOpacity(0.3),
                                ),
                              ),
                          ],
                        ),
                      ),

                      // Content
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 12, bottom: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      isWet ? 'Tanah Basah' : 'Tanah Kering',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: isWet
                                            ? AppTheme.wetColor
                                            : AppTheme.dryColor,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Nilai: ${record.moistureValue}',
                                      style:
                                          Theme.of(context).textTheme.bodySmall,
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: isWet
                                      ? AppTheme.wetColor.withOpacity(0.1)
                                      : AppTheme.dryColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  time,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isWet
                                        ? AppTheme.wetColor
                                        : AppTheme.dryColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            if (dateIndex < dates.length - 1)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Divider(),
              ),
          ],
        );
      },
    );
  }

  LineChartData _buildLineChartData(BuildContext context,
      {bool showAllLabels = false}) {
    // Prepare chart data (last 20 records, reversed to show oldest to newest)
    final chartData = moistureHistory.take(20).toList().reversed.toList();

    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: true,
        horizontalInterval: 500,
        verticalInterval: 1,
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: Colors.grey.withOpacity(0.2),
            strokeWidth: 1,
          );
        },
        getDrawingVerticalLine: (value) {
          return FlLine(
            color: Colors.grey.withOpacity(0.2),
            strokeWidth: 1,
          );
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            getTitlesWidget: (value, meta) {
              if (value.toInt() >= 0 && value.toInt() < chartData.length) {
                final date = chartData[value.toInt()].timestamp;

                // Show fewer labels on smaller charts
                if (!showAllLabels && value.toInt() % 3 != 0) {
                  return const SizedBox();
                }

                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    DateFormat('HH:mm').format(date),
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 10,
                    ),
                  ),
                );
              }
              return const SizedBox();
            },
            interval: 1,
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 40,
            getTitlesWidget: (value, meta) {
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Text(
                  value.toInt().toString(),
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 10,
                  ),
                ),
              );
            },
            interval: 1000,
          ),
        ),
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      minX: 0,
      maxX: chartData.length.toDouble() - 1,
      minY: 0,
      maxY: 4095, // ESP32 ADC max value
      lineBarsData: [
        LineChartBarData(
          spots: List.generate(chartData.length, (index) {
            return FlSpot(
              index.toDouble(),
              chartData[index].moistureValue.toDouble(),
            );
          }),
          isCurved: true,
          gradient: const LinearGradient(
            colors: AppTheme.chartGradientColors,
          ),
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: true,
            getDotPainter: (spot, percent, barData, index) {
              final isWet = chartData[index].soilStatus == 'wet';
              return FlDotCirclePainter(
                radius: 4,
                color: isWet ? AppTheme.wetColor : AppTheme.dryColor,
                strokeWidth: 2,
                strokeColor: Colors.white,
              );
            },
          ),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: AppTheme.chartGradientColors
                  .map((color) => color.withOpacity(0.2))
                  .toList(),
            ),
          ),
        ),
      ],
      lineTouchData: LineTouchData(
        touchTooltipData: LineTouchTooltipData(
          tooltipBgColor: Theme.of(context).cardColor,
          tooltipRoundedRadius: 8,
          getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
            return touchedBarSpots.map((barSpot) {
              final index = barSpot.x.toInt();
              final record = chartData[index];
              return LineTooltipItem(
                '${record.moistureValue}',
                TextStyle(
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                  fontWeight: FontWeight.bold,
                ),
                children: [
                  TextSpan(
                    text:
                        '\n${record.soilStatus == 'wet' ? 'Basah' : 'Kering'}',
                    style: TextStyle(
                      color: record.soilStatus == 'wet'
                          ? AppTheme.wetColor
                          : AppTheme.dryColor,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  TextSpan(
                    text:
                        '\n${DateFormat('HH:mm, dd MMM').format(record.timestamp)}',
                    style: const TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.normal,
                      fontSize: 12,
                    ),
                  ),
                ],
              );
            }).toList();
          },
        ),
      ),
    );
  }

  String _getLastUpdateTime() {
    if (moistureHistory.isEmpty) {
      return 'Tidak ada data';
    }

    final lastRecord = moistureHistory.first;
    return DateFormat('HH:mm, dd MMM').format(lastRecord.timestamp);
  }
}
