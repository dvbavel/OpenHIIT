import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openhiit/core/models/timer_sound_settings.dart';
import 'package:openhiit/core/models/timer_time_settings.dart';
import 'package:openhiit/core/models/timer_type.dart';
import 'package:openhiit/core/providers/timer_creation_provider/timer_creation_provider.dart';
import 'package:openhiit/features/edit_timer/ui/widgets/start_save_toggle.dart';
import 'package:openhiit/features/edit_timer/ui/widgets/tabs/editor_tab/editor_tab.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('sets and resets the time of a single work interval',
      (tester) async {
    // Typical phone width, to catch overflow from the tappable time chip.
    tester.view.physicalSize = const Size(360 * 3, 740 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    final provider = TimerCreationProvider()
      ..setTimer(TimerType(
        id: 't',
        name: 'Test',
        timerIndex: 0,
        activeIntervals: 3,
        timeSettings: TimerTimeSettings(
          id: 'ts',
          timerId: 't',
          workTime: 30,
          restTime: 10,
          breakTime: 0,
          warmupTime: 0,
          cooldownTime: 0,
          getReadyTime: 0,
          restarts: 0,
          skipWarmupRest: 0,
        ),
        soundSettings: TimerSoundSettings.empty(),
      ));
    final controllers =
        List.generate(3, (_) => TextEditingController(text: 'Work'));
    StartSaveState? lastState;

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: provider,
        child: MaterialApp(
          home: Scaffold(
            body: EditorTab(
              controllersUpdated: true,
              controllers: controllers,
              onEdited: (s) => lastState = s,
              setButtonState: (s) => lastState = s,
              scrollController: ScrollController(),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Open the second work interval and set it to 1:15.
    await tester.tap(find.byKey(const Key('activity-time-1')));
    await tester.pumpAndSettle();
    await tester.enterText(
        find.byKey(const Key('work-time-dialog-minutes')), '1');
    await tester.enterText(
        find.byKey(const Key('work-time-dialog-seconds')), '15');
    await tester.pump();
    await tester.tap(find.byKey(const Key('work-time-dialog-save')));
    await tester.pumpAndSettle();

    expect(provider.timer.workTimes, [0, 75]);
    expect(lastState, StartSaveState.save);
    expect(find.text('75'), findsOneWidget);

    // Reset it to the default again.
    await tester.tap(find.byKey(const Key('activity-time-1')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('work-time-dialog-reset')));
    await tester.pumpAndSettle();

    expect(provider.timer.workTimes, isEmpty);
    expect(find.text('75'), findsNothing);
  });
}
