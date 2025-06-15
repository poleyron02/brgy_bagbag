import 'package:brgy_bagbag/functions.dart';
import 'package:brgy_bagbag/globals.dart';
import 'package:brgy_bagbag/models/resident.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

class ReasonForDeclineDialog extends StatelessWidget {
  ReasonForDeclineDialog({
    super.key,
  });

  final GlobalKey<FormState> formKey = GlobalKey();

  final TextEditingController reason = TextEditingController();

  void submit(BuildContext context) async {
    if (!formKey.currentState!.validate()) return;

    if (context.mounted) Navigator.pop(context, reason.text);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      insetPadding: const EdgeInsets.all(10),
      contentPadding: const EdgeInsets.all(16),
      icon: const Icon(TablerIcons.rosette_discount_check_off),
      title: const Text('Reason for Decline'),
      content: SizedBox(
        width: 500,
        child: Form(
          key: formKey,
          child: TextFormField(
            controller: reason,
            validator: validate,
            minLines: 5,
            maxLines: 10,
            decoration: InputDecoration(
              labelText: 'Tell us in detail',
              hintText: 'e.g. "No Valid ID", "Blurry photo", etc.',
              border: outlineInputBorder(context),
              enabledBorder: outlineInputBorder(context),
            ),
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, ''), child: const Text('CANCEL')),
        FilledButton(onPressed: () => submit(context), child: const Text('CONFIRM')),
      ],
    );
  }
}
