import 'package:brgy_bagbag/globals.dart';
import 'package:flutter/material.dart';

class DropdownFormField extends StatelessWidget {
  const DropdownFormField({
    super.key,
    required this.controller,
    required this.label,
    required this.values,
    this.prefixIcon,
    this.isDense = false,
    this.expanedInsets = EdgeInsets.zero,
    this.readOnly = false,
    this.enabled = true,
  });

  final TextEditingController controller;
  final String label;
  final List<String> values;
  final Icon? prefixIcon;
  final bool isDense;
  final EdgeInsets? expanedInsets;
  final bool readOnly;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return FormField(
      enabled: enabled,
      initialValue: controller.text,
      validator: (String? value) {
        if (controller.text.isEmpty) return 'Required';
        return null;
      },
      builder: (field) => DropdownMenu(
        enabled: enabled ? !readOnly : false,
        controller: controller,
        leadingIcon: prefixIcon,
        textStyle: TextStyle(color: enabled ? null : Theme.of(context).disabledColor),
        label: Text(label),
        expandedInsets: expanedInsets,
        errorText: field.errorText,
        onSelected: (value) {
          controller.text = value!;
          field.didChange(value);
        },
        inputDecorationTheme: InputDecorationTheme(
          isDense: isDense,
          border: outlineInputBorder(context),
          enabledBorder: outlineInputBorder(context),
        ),
        dropdownMenuEntries: List.generate(
          values.length,
          (index) => DropdownMenuEntry(value: values[index], label: values[index]),
        ),
      ),
    );
  }
}
