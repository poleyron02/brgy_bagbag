import 'package:brgy_bagbag/globals.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

class ResidentSettingsPageView extends StatelessWidget {
  const ResidentSettingsPageView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const Icon(TablerIcons.settings),
        title: const Text('Settings'),
      ),
      body: ValueListenableBuilder(
        valueListenable: darkMode,
        builder: (context, value, child) => SwitchListTile(
          value: value,
          onChanged: (value) => darkMode.value = value,
          secondary: const Icon(TablerIcons.moon),
          title: const Text('Dark Mode'),
        ),
      ),
    );
  }
}
