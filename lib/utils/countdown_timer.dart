import 'package:flutter/material.dart';
import '../themes/app_theme.dart';

class CountdownTimerWidget extends StatelessWidget {
  final int seconds;
  final VoidCallback? onCancel;
  final bool isActive;

  const CountdownTimerWidget({
    Key? key,
    required this.seconds,
    this.onCancel,
    this.isActive = true,
  }) : super(key: key);

  String get formattedTime {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: isActive
            ? AppTheme.activePumpColor.withOpacity(0.1)
            : Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isActive ? AppTheme.activePumpColor : Colors.grey,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.timer,
            color: isActive ? AppTheme.activePumpColor : Colors.grey,
            size: 18,
          ),
          const SizedBox(width: 8),
          Text(
            formattedTime,
            style: TextStyle(
              color: isActive ? AppTheme.activePumpColor : Colors.grey,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          if (onCancel != null && isActive) ...[
            const SizedBox(width: 8),
            GestureDetector(
              onTap: onCancel,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppTheme.inactivePumpColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.cancel,
                  color: AppTheme.inactivePumpColor,
                  size: 16,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// Dialog untuk memilih waktu
class TimerSelectionDialog extends StatefulWidget {
  final Function(int) onTimeSelected;

  const TimerSelectionDialog({
    Key? key,
    required this.onTimeSelected,
  }) : super(key: key);

  @override
  State<TimerSelectionDialog> createState() => _TimerSelectionDialogState();
}

class _TimerSelectionDialogState extends State<TimerSelectionDialog> {
  int _selectedSeconds = 30;

  // Predefined durations
  final List<int> _durations = [30, 60, 120, 300, 600];

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Atur Durasi Pompa',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),

            // Predefined durations
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _durations.map((seconds) {
                final isSelected = _selectedSeconds == seconds;
                final minutes = seconds ~/ 60;
                final remainingSeconds = seconds % 60;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedSeconds = seconds;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppTheme.primaryColor
                          : AppTheme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      remainingSeconds == 0
                          ? '$minutes menit'
                          : '$minutes:${remainingSeconds.toString().padLeft(2, '0')}',
                      style: TextStyle(
                        color:
                            isSelected ? Colors.white : AppTheme.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 20),

            // Custom input slider
            Text(
              'Durasi: ${_formatDuration(_selectedSeconds)}',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
            Slider(
              value: _selectedSeconds.toDouble(),
              min: 10,
              max: 900, // 15 minutes
              divisions: 89,
              activeColor: AppTheme.primaryColor,
              inactiveColor: AppTheme.primaryColor.withOpacity(0.2),
              onChanged: (value) {
                setState(() {
                  _selectedSeconds = value.round();
                });
              },
            ),

            const SizedBox(height: 20),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Batal'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      widget.onTimeSelected(_selectedSeconds);
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Mulai'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;

    if (minutes == 0) {
      return '$seconds detik';
    } else if (remainingSeconds == 0) {
      return '$minutes menit';
    } else {
      return '$minutes menit $remainingSeconds detik';
    }
  }
}

// Show timer selection dialog
void showTimerSelectionDialog(
    BuildContext context, Function(int) onTimeSelected) {
  showDialog(
    context: context,
    builder: (context) => TimerSelectionDialog(
      onTimeSelected: onTimeSelected,
    ),
  );
}
