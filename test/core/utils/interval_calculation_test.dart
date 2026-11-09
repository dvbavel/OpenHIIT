import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:openhiit/core/models/timer_sound_settings.dart';
import 'package:openhiit/core/models/timer_time_settings.dart';
import 'package:openhiit/core/models/timer_type.dart';
import 'package:openhiit/core/providers/timer_creation_provider/timer_creation_provider.dart';
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

  group('per-interval work times', () {
    TimerType timer({List<int> workTimes = const [], int restarts = 0}) {
      return TimerType(
        id: 'timer-2',
        name: 'Custom times',
        timerIndex: 0,
        activeIntervals: 3,
        workTimes: workTimes,
        timeSettings: TimerTimeSettings(
          id: 'time-2',
          timerId: 'timer-2',
          workTime: 30,
          restTime: 10,
          breakTime: 0,
          warmupTime: 0,
          cooldownTime: 0,
          getReadyTime: 0,
          restarts: restarts,
          skipWarmupRest: 0,
        ),
        soundSettings: TimerSoundSettings.empty(),
      );
    }

    List<int> workDurations(TimerType t) => generateIntervalsFromTimer(t)
        .where((interval) => interval.name == 'Work')
        .map((interval) => interval.time)
        .toList();

    test('uses the default work time without overrides', () {
      expect(workDurations(timer()), [30, 30, 30]);
    });

    test('uses overrides and falls back to default for 0 or missing', () {
      expect(workDurations(timer(workTimes: [45, 0])), [45, 30, 30]);
    });

    test('applies overrides in every round', () {
      expect(
        workDurations(timer(workTimes: [20, 40, 60], restarts: 1)),
        [20, 40, 60, 20, 40, 60],
      );
    });

    test('marks custom intervals in the display model', () async {
      final displays = await generateIntervalDisplaysForTimer(
        timer(workTimes: [0, 40]),
        singleIteration: true,
      );
      final work = displays.where((d) => d.activeIndex > 0).toList();

      expect(work.map((d) => d.customTime), [false, true, false]);
      expect(work.map((d) => d.seconds), [30, 40, 30]);
    });

    test('survives database and export round trips', () {
      final original = timer(workTimes: [45, 0, 15]);

      final fromMap = TimerType.fromMap(original.toMap());
      expect(fromMap.workTimes, [45, 0, 15]);

      final json = jsonDecode(jsonEncode(original.toJson()));
      expect(TimerType.fromJson(json).workTimes, [45, 0, 15]);
    });

    test('loads timers saved before the column existed', () {
      final map = timer().toMap()..remove('workTimes');
      expect(TimerType.fromMap(map).workTimes, isEmpty);
    });

    test('provider sets and resets an override', () {
      final provider = TimerCreationProvider()..setTimer(timer());

      provider.setWorkTimeOverride(1, 50);
      expect(provider.timer.workTimes, [0, 50]);
      expect(provider.isEdited, isTrue);

      provider.setWorkTimeOverride(1, 0);
      expect(provider.timer.workTimes, isEmpty);
    });
  });
}
