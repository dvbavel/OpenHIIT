import 'package:flutter/material.dart';
import 'package:openhiit/core/models/interval_display_model.dart';
import 'package:openhiit/core/utils/interval_display.dart';

class IntervalListTile extends StatelessWidget {
  final IntervalDisplayModel interval;
  final Color backgroundColor;
  final bool editing;
  final TextEditingController nameController;
  final ValueChanged<String>? onNameChanged; // callback for text changes
  final VoidCallback? onTimeTap; // edit this interval's duration
  final String? formFieldKey;
  final String? timeKey;

  IntervalListTile({
    super.key,
    required this.interval,
    required this.backgroundColor,
    this.editing = false,
    this.onNameChanged,
    this.onTimeTap,
    this.formFieldKey,
    this.timeKey,
    TextEditingController? nameController,
  }) : nameController = nameController ?? TextEditingController();

  Widget _buildTime(TextScaler textScaler) {
    final time = Text(
      intervalSecondsDisplay(interval.seconds, interval.showMinutes),
      style: TextStyle(
        fontSize: textScaler.scale(24),
        color: Colors.white,
        fontWeight: interval.customTime ? FontWeight.bold : FontWeight.normal,
      ),
    );

    if (onTimeTap == null) return time;

    return InkWell(
      key: timeKey != null ? Key(timeKey!) : null,
      borderRadius: BorderRadius.circular(12),
      onTap: onTimeTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: const Color.fromARGB(51, 0, 0, 0),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              interval.customTime ? Icons.timer : Icons.timer_outlined,
              size: textScaler.scale(18),
              color: Colors.white70,
            ),
            const SizedBox(width: 4),
            time,
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textScaler = MediaQuery.of(context).textScaler;
    final isActive = interval.activeIndex != 0;

    return Padding(
        padding: const EdgeInsets.all(5),
        child: Container(
          decoration: BoxDecoration(
            color: backgroundColor, // background color of the tile
            borderRadius: BorderRadius.circular(12), // round the corners
          ),
          child: ListTile(
            leading: SizedBox(
              width: textScaler.scale(40), // reserve space
              child: isActive
                  ? Text(
                      interval.activeIndex.toString(),
                      style: TextStyle(
                          fontSize: textScaler.scale(24),
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    )
                  : null,
            ),
            title: editing && isActive
                ? TextFormField(
                    key:
                        Key(formFieldKey ?? 'interval-${interval.activeIndex}'),
                    controller: nameController,
                    onChanged: onNameChanged,
                    textCapitalization: TextCapitalization.words,
                    style: TextStyle(
                        fontSize: (24 - (interval.name.length * 0.5))
                            .clamp(12, 24) // don’t shrink below 12, max 24
                            .toDouble(),
                        color: Colors.white),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color.fromARGB(51, 0, 0, 0),
                      suffix: const Icon(
                        Icons.edit,
                        size: 20,
                        color: Colors.white70,
                      ),
                      suffixIconConstraints: const BoxConstraints(
                        minWidth: 25,
                        minHeight: 0,
                      ),
                      contentPadding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  )
                : Text(
                    interval.name,
                    style: TextStyle(
                        fontSize: textScaler.scale(24), color: Colors.white),
                    overflow: TextOverflow.ellipsis,
                  ),
            trailing: _buildTime(textScaler),
          ),
        ));
  }
}
