import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:openhiit/core/utils/interval_display.dart';

/// Asks for the duration of a single work interval.
///
/// Returns the chosen number of seconds, 0 when the user resets the interval
/// to the default work time, or null when the dialog is dismissed.
Future<int?> showWorkTimeDialog(
  BuildContext context, {
  required String intervalName,
  required int currentSeconds,
  required int defaultSeconds,
  required bool showMinutes,
  required bool isCustom,
}) {
  return showDialog<int>(
    context: context,
    builder: (context) => _WorkTimeDialog(
      intervalName: intervalName,
      currentSeconds: currentSeconds,
      defaultSeconds: defaultSeconds,
      showMinutes: showMinutes,
      isCustom: isCustom,
    ),
  );
}

class _WorkTimeDialog extends StatefulWidget {
  final String intervalName;
  final int currentSeconds;
  final int defaultSeconds;
  final bool showMinutes;
  final bool isCustom;

  const _WorkTimeDialog({
    required this.intervalName,
    required this.currentSeconds,
    required this.defaultSeconds,
    required this.showMinutes,
    required this.isCustom,
  });

  @override
  State<_WorkTimeDialog> createState() => _WorkTimeDialogState();
}

class _WorkTimeDialogState extends State<_WorkTimeDialog> {
  late final TextEditingController _minutesController;
  late final TextEditingController _secondsController;

  @override
  void initState() {
    super.initState();
    _minutesController =
        TextEditingController(text: (widget.currentSeconds ~/ 60).toString());
    _secondsController =
        TextEditingController(text: (widget.currentSeconds % 60).toString());
  }

  @override
  void dispose() {
    _minutesController.dispose();
    _secondsController.dispose();
    super.dispose();
  }

  int get _totalSeconds {
    final minutes = int.tryParse(_minutesController.text) ?? 0;
    final seconds = int.tryParse(_secondsController.text) ?? 0;
    return minutes * 60 + seconds;
  }

  Widget _numberField(TextEditingController controller, String label,
      {String? key}) {
    return Expanded(
      child: TextField(
        key: key != null ? Key(key) : null,
        controller: controller,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        textAlign: TextAlign.center,
        decoration: InputDecoration(labelText: label),
        onChanged: (_) => setState(() {}),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final defaultLabel =
        intervalSecondsDisplay(widget.defaultSeconds, widget.showMinutes);

    return AlertDialog(
      title: Text(widget.intervalName),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _numberField(_minutesController, 'Minutes',
                  key: 'work-time-dialog-minutes'),
              const SizedBox(width: 16),
              _numberField(_secondsController, 'Seconds',
                  key: 'work-time-dialog-seconds'),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Default work time: $defaultLabel',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
      actions: [
        if (widget.isCustom)
          TextButton(
            key: const Key('work-time-dialog-reset'),
            onPressed: () => Navigator.of(context).pop(0),
            child: const Text('Use default'),
          ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          key: const Key('work-time-dialog-save'),
          onPressed: _totalSeconds > 0
              ? () => Navigator.of(context).pop(_totalSeconds)
              : null,
          child: const Text('Save'),
        ),
      ],
    );
  }
}
