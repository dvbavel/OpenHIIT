import 'package:flutter_test/flutter_test.dart';
import 'package:openhiit/core/models/timer_sound_settings.dart';
import 'package:openhiit/core/models/timer_time_settings.dart';
import 'package:openhiit/core/models/timer_type.dart';
import 'package:openhiit/core/utils/interval_calculation.dart';

TimerType _timer({required int skipWarmupRest}) {
  return TimerType(
    id: 'timer-1',
    name: 'Warmup timer',
    timerIndex: 0,
    activeIntervals: 1,
    timeSettings: TimerTimeSettings(
      id: 'time-1',
      timerId: 'timer-1',
      workTime: 30,
      restTime: 10,
      breakTime: 0,
      warmupTime: 20,
      cooldownTime: 0,
      getReadyTime: 0,
      restarts: 0,
      skipWarmupRest: skipWarmupRest,
    ),
    soundSettings: TimerSoundSettings.empty(),
  );
}

void main() {
  group('generateIntervalsFromTimer', () {
    test('keeps rest after warmup by default', () {
      final intervals = generateIntervalsFromTimer(_timer(skipWarmupRest: 0));

      expect(intervals.map((interval) => interval.name), [
        'Warmup',
        'Rest',
        'Work',
      ]);
    });

    test('skips rest after warmup when enabled', () {
      final intervals = generateIntervalsFromTimer(_timer(skipWarmupRest: 1));

      expect(intervals.map((interval) => interval.name), ['Warmup', 'Work']);
    });
  });
}
