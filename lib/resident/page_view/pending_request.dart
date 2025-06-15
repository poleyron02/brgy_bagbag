import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

class ResidentPendingRequestPageView extends StatelessWidget {
  const ResidentPendingRequestPageView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const Icon(TablerIcons.loader),
        title: const Text('Pending Request'),
      ),
    );
  }
}
