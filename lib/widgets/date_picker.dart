import 'package:brgy_bagbag/functions.dart';
import 'package:brgy_bagbag/globals.dart';
import 'package:brgy_bagbag/models/custom_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

class DatePicker extends StatelessWidget {
  const DatePicker({
    super.key,
    required this.label,
    required this.controller,
    this.isNullable = false,
    this.pickTime = false,
    this.readOnly = false,
    this.enabled = true,
  });

  final String label;
  final CustomNotifier<DateTime> controller;
  final bool isNullable;
  final bool pickTime;
  final bool readOnly;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: controller,
      builder: (context, controllerValue, child) {
        TextEditingController textEditingController = TextEditingController(text: controllerValue?.format());

        return TextFormField(
          enabled: enabled,
          readOnly: true,
          controller: textEditingController,
          validator: isNullable ? null : validate,
          decoration: InputDecoration(
            isDense: true,
            labelText: label,
            prefixIcon: const Icon(TablerIcons.calendar),
            border: outlineInputBorder(context),
            enabledBorder: outlineInputBorder(context),
            suffixIconConstraints: BoxConstraints.tight(Size.zero),
            suffix: readOnly
                ? null
                : IconButton(
                    visualDensity: VisualDensity.compact,
                    onPressed: () {
                      controller.remove();
                      textEditingController.clear();
                    },
                    icon: const Icon(TablerIcons.x),
                  ),
          ),
          onTap: readOnly
              ? null
              : () async {
                  DateTime? date = await showDatePicker(context: context, firstDate: DateTime(1900), lastDate: DateTime.now(), initialEntryMode: DatePickerEntryMode.input);
                  if (date == null) return;

                  if (pickTime) {
                    TimeOfDay? time;
                    if (context.mounted) time = await showTimePicker(context: context, initialTime: TimeOfDay.now());
                    if (time == null) return;
                    date = DateTime(
                      date.year,
                      date.month,
                      date.day,
                      time.hour,
                      time.minute,
                    );
                  }

                  controller.set(date);
                  textEditingController.text = date.format();
                },
        );
      },
    );
  }
}
