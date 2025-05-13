// utils/audio_helpers.dart - Helper functions for audio handling
import 'package:wakelock_plus/wakelock_plus.dart';

class AudioHelpers {
  // Format duration to mm:ss
  static String formatTime(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  // Enable wakelock to keep screen on during playback
  static Future<void> enableWakelock() async {
    try {
      await WakelockPlus.enable();
      final isEnabled = await WakelockPlus.enabled;
      print('Wakelock is enabled: $isEnabled');
    } catch (e) {
      print('Error enabling wakelock: $e');
    }
  }

  // Disable wakelock when stopping media playback
  static Future<void> disableWakelock() async {
    try {
      await WakelockPlus.disable();
    } catch (e) {
      print('Error disabling wakelock: $e');
    }
  }
}