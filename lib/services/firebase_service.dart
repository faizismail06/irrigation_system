import 'package:firebase_database/firebase_database.dart';
import '../models/irrigation_model.dart';

class FirebaseService {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref('irrigation');

  // Subscribe to real-time updates
  void subscribeToIrrigationData({
    required Function(int) onMoistureChanged,
    required Function(String) onSoilStatusChanged,
    required Function(bool) onPumpStatusChanged,
    required Function(bool) onAutoModeChanged,
    required Function(List<MoistureRecord>) onHistoryUpdated,
    required Function(int?) onPumpTimerChanged,
  }) {
    // Listen to moisture value
    _dbRef.child('moisture').onValue.listen((event) {
      if (event.snapshot.exists) {
        final value = event.snapshot.value as int;
        onMoistureChanged(value);
      }
    });

    // Listen to soil status
    _dbRef.child('soilStatus').onValue.listen((event) {
      if (event.snapshot.exists) {
        final status = event.snapshot.value as String;
        onSoilStatusChanged(status);
      }
    });

    // Listen to pump status
    _dbRef.child('pumpStatus').onValue.listen((event) {
      if (event.snapshot.exists) {
        final status = event.snapshot.value as bool;
        onPumpStatusChanged(status);
      }
    });

    // Listen to auto mode
    _dbRef.child('autoMode').onValue.listen((event) {
      if (event.snapshot.exists) {
        final mode = event.snapshot.value as bool;
        onAutoModeChanged(mode);
      }
    });

    // Listen to pump timer (if exists)
    _dbRef.child('pumpTimer').onValue.listen((event) {
      if (event.snapshot.exists) {
        final timer = event.snapshot.value as int;
        onPumpTimerChanged(timer);
      } else {
        onPumpTimerChanged(null);
      }
    });

    // Listen to history
    _dbRef.child('history').limitToLast(50).onValue.listen((event) {
      if (event.snapshot.exists) {
        final historyData = event.snapshot.value as Map<dynamic, dynamic>;
        final history = <MoistureRecord>[];

        historyData.forEach((key, value) {
          final record = MoistureRecord(
            timestamp: DateTime.fromMillisecondsSinceEpoch(
                int.parse(value['timestamp'] as String)),
            moistureValue: value['moisture'] as int,
            soilStatus: value['soilStatus'] as String,
          );
          history.add(record);
        });

        // Sort by timestamp (newest first)
        history.sort((a, b) => b.timestamp.compareTo(a.timestamp));
        onHistoryUpdated(history);
      }
    });
  }

  // Update auto mode
  Future<void> setAutoMode(bool mode) async {
    await _dbRef.child('autoMode').set(mode);
  }

  // Update pump command (for manual mode)
  Future<void> setPumpCommand(bool command) async {
    await _dbRef.child('pumpCommand').set(command);
  }

  // Set pump timer for manual mode (in seconds)
  Future<void> setPumpTimer(int seconds) async {
    await _dbRef.child('pumpTimer').set(seconds);

    // Also set the pump command to true
    if (seconds > 0) {
      await setPumpCommand(true);
    }
  }

  // Cancel pump timer
  Future<void> cancelPumpTimer() async {
    await _dbRef.child('pumpTimer').remove();
    await setPumpCommand(false);
  }

  // Add test entry to history (for testing only)
  Future<void> addTestHistoryEntry() async {
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final randomMoisture = 1500 + (DateTime.now().millisecond % 1000);
    final soilStatus = randomMoisture > 2000 ? 'dry' : 'wet';

    await _dbRef.child('history').child(timestamp).set({
      'timestamp': timestamp,
      'moisture': randomMoisture,
      'soilStatus': soilStatus,
    });
  }
}
