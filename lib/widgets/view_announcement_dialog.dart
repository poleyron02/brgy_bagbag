import 'package:brgy_bagbag/functions.dart';
import 'package:brgy_bagbag/models/announcement.dart';
import 'package:brgy_bagbag/widgets/column_separated.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

class ViewAnnouncementDialog extends StatelessWidget {
  const ViewAnnouncementDialog({super.key, required this.announcement});

  final Announcement announcement;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      scrollable: true,
      insetPadding: const EdgeInsets.all(10),
      contentPadding: const EdgeInsets.all(16),
      icon: const Icon(TablerIcons.speakerphone),
      title: Text(announcement.title),
      content: SizedBox(
        width: 500,
        child: ColumnSeparated(
          spacing: 16,
          mainAxisSize: MainAxisSize.min,
          children: [
            Chip(label: Text(announcement.category)),
            ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.network(announcement.image)),
            Text(
              announcement.createdAt.format(),
              style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.secondary),
            ),
            Text(
              announcement.content,
              style: const TextStyle(
                height: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
