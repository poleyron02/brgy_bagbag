import 'package:flutter/material.dart';

class AreYouSureDialog extends StatelessWidget {
  const AreYouSureDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Are you sure?'),
      content: const SizedBox(
        width: 500,
        child: Text(
          'Are you sure you want to do this action?',
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('CANCEL')),
        FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('CONFIRM')),
      ],
    );
  }
}
