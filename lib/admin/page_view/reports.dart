import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

class ReportsPageView extends StatelessWidget {
  const ReportsPageView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const Icon(TablerIcons.report),
        title: const Text('Reports'),
      ),
    );
  }
}
