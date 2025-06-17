import 'package:flutter/material.dart';
import '../themes/app_theme.dart';

class ModeSwitchCard extends StatelessWidget {
  final bool autoMode;
  final VoidCallback onToggle;

  const ModeSwitchCard({
    Key? key,
    required this.autoMode,
    required this.onToggle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenWidth < 600;
    final isVerySmallScreen = screenWidth < 400;
    final isShortScreen = screenHeight < 700;

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
    final switchWidth = isVerySmallScreen
        ? 44.0
        : isSmallScreen
            ? 50.0
            : 56.0;
    final switchHeight = isVerySmallScreen
        ? 22.0
        : isSmallScreen
            ? 25.0
            : 28.0;
    final switchButtonSize = isVerySmallScreen
        ? 18.0
        : isSmallScreen
            ? 21.0
            : 24.0;

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
                    color: AppTheme.secondaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(isSmallScreen ? 6 : 8),
                  ),
                  child: Icon(
                    Icons.settings,
                    color: AppTheme.secondaryColor,
                    size: iconSize,
                  ),
                ),
                SizedBox(width: isVerySmallScreen ? 6 : 8),
                Expanded(
                  child: Text(
                    'Mode Operasi',
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

            // Mode indicator
            InkWell(
              onTap: onToggle,
              borderRadius: BorderRadius.circular(isSmallScreen ? 12 : 16),
              child: Ink(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(isSmallScreen ? 12 : 16),
                  gradient: LinearGradient(
                    colors: [
                      autoMode
                          ? AppTheme.primaryColor.withOpacity(0.8)
                          : AppTheme.accentColor.withOpacity(0.8),
                      autoMode
                          ? AppTheme.primaryColor.withOpacity(0.6)
                          : AppTheme.accentColor.withOpacity(0.6),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.all(innerPadding),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              autoMode ? 'Mode Otomatis' : 'Mode Manual',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    fontSize: isVerySmallScreen
                                        ? 11
                                        : isSmallScreen
                                            ? 13
                                            : 15,
                                  ),
                            ),
                            SizedBox(height: isVerySmallScreen ? 2 : 4),
                            Text(
                              autoMode
                                  ? 'Pompa menyala otomatis saat tanah kering'
                                  : 'Kontrol pompa secara manual dengan timer',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: Colors.white.withOpacity(0.8),
                                    fontSize: isVerySmallScreen
                                        ? 9
                                        : isSmallScreen
                                            ? 10
                                            : 11,
                                    height: 1.2,
                                  ),
                              maxLines: isVerySmallScreen ? 2 : 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: isVerySmallScreen ? 6 : 8),
                      Container(
                        padding: EdgeInsets.all(isVerySmallScreen ? 6 : 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          autoMode ? Icons.auto_mode : Icons.touch_app,
                          color: Colors.white,
                          size: isVerySmallScreen
                              ? 16
                              : isSmallScreen
                                  ? 20
                                  : 24,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            SizedBox(height: sectionSpacing),

            // Toggle switch
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Manual',
                  style: TextStyle(
                    color: !autoMode ? AppTheme.accentColor : Colors.grey,
                    fontWeight: !autoMode ? FontWeight.bold : FontWeight.normal,
                    fontSize: isVerySmallScreen
                        ? 10
                        : isSmallScreen
                            ? 11
                            : 12,
                  ),
                ),
                SizedBox(width: isVerySmallScreen ? 6 : 8),
                GestureDetector(
                  onTap: onToggle,
                  child: Container(
                    width: switchWidth,
                    height: switchHeight,
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(switchHeight / 2),
                      color: autoMode
                          ? AppTheme.primaryColor
                          : Colors.grey.shade700,
                    ),
                    child: Stack(
                      children: [
                        AnimatedAlign(
                          alignment: autoMode
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          duration: const Duration(milliseconds: 200),
                          child: Container(
                            width: switchButtonSize,
                            height: switchButtonSize,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: isVerySmallScreen ? 6 : 8),
                Text(
                  'Otomatis',
                  style: TextStyle(
                    color: autoMode ? AppTheme.primaryColor : Colors.grey,
                    fontWeight: autoMode ? FontWeight.bold : FontWeight.normal,
                    fontSize: isVerySmallScreen
                        ? 10
                        : isSmallScreen
                            ? 11
                            : 12,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
