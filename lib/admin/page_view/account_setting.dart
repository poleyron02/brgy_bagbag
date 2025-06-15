import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

class AccountSettingPageView extends StatelessWidget {
  const AccountSettingPageView({
    super.key,
    this.isPortrait = false,
    this.drawer,
  });

  final bool isPortrait;
  final Widget? drawer;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(child: drawer),
      appBar: AppBar(
        leading: isPortrait ? null : const Icon(TablerIcons.settings),
        title: const Text('Account Setting'),
      ),
    );
  }
}
