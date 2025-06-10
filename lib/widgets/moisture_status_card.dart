import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../themes/app_theme.dart';

class MoistureStatusCard extends StatefulWidget {
  final int moistureValue;
  final String soilStatus;

  const MoistureStatusCard({
    Key? key,
    required this.moistureValue,
    required this.soilStatus,
  }) : super(key: key);

  @override
  State<MoistureStatusCard> createState() => _MoistureStatusCardState();
}

class _MoistureStatusCardState extends State<MoistureStatusCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;
    final isSmallScreen = screenWidth < 600;
    final isVerySmallScreen = screenWidth < 400;
    final isLandscape = screenWidth > screenHeight;

    final bool isWet = widget.soilStatus == 'wet';
    final Color statusColor = isWet ? AppTheme.wetColor : AppTheme.dryColor;
    final String statusText = isWet ? 'Basah' : 'Kering';

    // Calculate percentage for visualization (assuming 4095 is max for ESP32 ADC)
    final double percentage = (4095 - widget.moistureValue) / 4095;
    final double clampedPercentage = percentage.clamp(0.0, 1.0);

    // Responsive dimensions
    final double cardPadding = isSmallScreen ? 12.0 : 16.0;
    final double iconSize = isVerySmallScreen ? 14 : (isSmallScreen ? 16 : 18);
    final double titleFontSize =
        isVerySmallScreen ? 14 : (isSmallScreen ? 16 : 18);
    final double containerHeight = _getContainerHeight(screenSize, isLandscape);
    final double statusIconSize =
        isVerySmallScreen ? 32 : (isSmallScreen ? 36 : 40);
    final double waveHeight = isSmallScreen ? 6 : 8;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(cardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(isSmallScreen ? 6 : 8),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.water_drop,
                    color: statusColor,
                    size: iconSize,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Status Kelembapan',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontSize: titleFontSize,
                        ),
                  ),
                ),
              ],
            ),

            SizedBox(height: isSmallScreen ? 16 : 20),

            // Moisture visualization
            Container(
              height: containerHeight,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Theme.of(context).cardColor.withOpacity(0.3),
                border: Border.all(
                  color: Colors.grey.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Stack(
                children: [
                  // Background grid lines
                  _buildGridLines(),

                  // Water level with animated waves
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    height: containerHeight * clampedPercentage,
                    child: AnimatedBuilder(
                      animation: _controller,
                      builder: (context, child) {
                        return CustomPaint(
                          painter: WavePainter(
                            color: statusColor.withOpacity(0.3),
                            secondaryColor: statusColor.withOpacity(0.15),
                            waveHeight: waveHeight,
                            progress: _controller.value,
                          ),
                          child: Container(),
                        );
                      },
                    ),
                  ),

                  // Status indicator
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: statusColor.withOpacity(0.1),
                          ),
                          child: Icon(
                            isWet
                                ? Icons.water_drop
                                : Icons.water_drop_outlined,
                            size: statusIconSize,
                            color: statusColor,
                          ),
                        ),
                        SizedBox(height: isSmallScreen ? 12 : 16),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: isSmallScreen ? 12 : 16,
                            vertical: isSmallScreen ? 6 : 8,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                          child: Text(
                            statusText,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  color: statusColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: isVerySmallScreen
                                      ? 14
                                      : (isSmallScreen ? 16 : 18),
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Scale markings on the side (only show on larger screens)
                  if (!isVerySmallScreen)
                    Positioned(
                      top: 10,
                      bottom: 10,
                      right: 10,
                      child: SizedBox(
                        width: isSmallScreen ? 25 : 30,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children:
                              List.generate(isSmallScreen ? 3 : 5, (index) {
                            final totalMarks = isSmallScreen ? 3 : 5;
                            final level = (totalMarks - 1) - index;
                            final percent = level / (totalMarks - 1);
                            final value = (4095 * (1 - percent)).round();

                            return Row(
                              children: [
                                Container(
                                  width: isSmallScreen ? 4 : 5,
                                  height: 1,
                                  color: Colors.grey.withOpacity(0.5),
                                ),
                                const SizedBox(width: 2),
                                Expanded(
                                  child: Text(
                                    '$value',
                                    style: TextStyle(
                                      fontSize: isSmallScreen ? 7 : 8,
                                      color: Colors.grey.withOpacity(0.7),
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            );
                          }),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            SizedBox(height: isSmallScreen ? 12 : 16),

            // Value display
            Container(
              padding: EdgeInsets.all(isSmallScreen ? 10 : 12),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: statusColor.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.analytics,
                    size: isSmallScreen ? 14 : 16,
                    color: statusColor,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Nilai Sensor:',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize:
                          isVerySmallScreen ? 12 : (isSmallScreen ? 13 : 14),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${widget.moistureValue}',
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                      fontSize:
                          isVerySmallScreen ? 14 : (isSmallScreen ? 15 : 16),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Add percentage indicator
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: isSmallScreen ? 6 : 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${(clampedPercentage * 100).toInt()}%',
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                        fontSize:
                            isVerySmallScreen ? 10 : (isSmallScreen ? 11 : 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  double _getContainerHeight(Size screenSize, bool isLandscape) {
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;

    if (isLandscape) {
      // In landscape, use smaller height relative to screen
      return math.min(screenHeight * 0.3, 180);
    } else {
      // In portrait, adjust based on screen width
      if (screenWidth < 400) {
        return 160; // Very small screens
      } else if (screenWidth < 600) {
        return 180; // Small screens
      } else {
        return 220; // Large screens
      }
    }
  }

  Widget _buildGridLines() {
    return CustomPaint(
      painter: GridPainter(),
      child: Container(),
    );
  }
}

// Wave effect painter
class WavePainter extends CustomPainter {
  final Color color;
  final Color secondaryColor;
  final double waveHeight;
  final double progress;

  WavePainter({
    required this.color,
    required this.secondaryColor,
    required this.waveHeight,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // First wave
    final firstWavePaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final firstWavePath = Path();

    // First wave starting point
    firstWavePath.moveTo(0, size.height * 0.5);

    // Create first wave pattern
    for (double i = 0; i < size.width; i++) {
      final x = i;
      final y =
          math.sin((i / size.width * 2 * math.pi) + (progress * 2 * math.pi)) *
                  waveHeight +
              size.height * 0.5;
      firstWavePath.lineTo(x, y);
    }

    // Complete the first wave path
    firstWavePath.lineTo(size.width, size.height);
    firstWavePath.lineTo(0, size.height);
    firstWavePath.close();

    canvas.drawPath(firstWavePath, firstWavePaint);

    // Second wave
    final secondWavePaint = Paint()
      ..color = secondaryColor
      ..style = PaintingStyle.fill;

    final secondWavePath = Path();

    // Second wave starting point
    secondWavePath.moveTo(0, size.height * 0.5);

    // Create second wave pattern (offset from first)
    for (double i = 0; i < size.width; i++) {
      final x = i;
      final y = math.sin((i / size.width * 2 * math.pi) +
                  (progress * 2 * math.pi) +
                  math.pi / 2) *
              (waveHeight * 1.5) +
          size.height * 0.5;
      secondWavePath.lineTo(x, y);
    }

    // Complete the second wave path
    secondWavePath.lineTo(size.width, size.height);
    secondWavePath.lineTo(0, size.height);
    secondWavePath.close();

    canvas.drawPath(secondWavePath, secondWavePaint);
  }

  @override
  bool shouldRepaint(covariant WavePainter oldDelegate) =>
      oldDelegate.progress != progress;
}

// Grid lines painter
class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.withOpacity(0.1)
      ..strokeWidth = 1;

    // Horizontal lines
    for (int i = 1; i < 5; i++) {
      final y = size.height * (i / 5);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    // Vertical lines
    for (int i = 1; i < 5; i++) {
      final x = size.width * (i / 5);
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
