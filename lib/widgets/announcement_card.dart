import 'package:brgy_bagbag/admin/widgets/announcement_dialog.dart';
import 'package:brgy_bagbag/functions.dart';
import 'package:brgy_bagbag/models/announcement.dart';
import 'package:brgy_bagbag/widgets/column_separated.dart';
import 'package:brgy_bagbag/widgets/row_separated.dart';
import 'package:brgy_bagbag/widgets/view_announcement_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

class AnnouncementCard extends StatelessWidget {
  const AnnouncementCard({
    super.key,
    required this.announcement,
  });

  final Announcement announcement;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Material(
        borderRadius: BorderRadius.circular(8),
        color: Theme.of(context).colorScheme.secondaryContainer,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () {
            showDialog(context: context, builder: (context) => ViewAnnouncementDialog(announcement: announcement));
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: RowSeparated(
              spacing: 16,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: AspectRatio(
                    aspectRatio: 4 / 3,
                    child: Image.network(
                      announcement.image,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Expanded(
                  child: ColumnSeparated(
                    spacing: 8,
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        announcement.createdAt.format(),
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                      Text(
                        announcement.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      RowSeparated(
                        spacing: 8,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(TablerIcons.category, size: 14),
                          Text(
                            announcement.category,
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                      Divider(
                        height: 0,
                        thickness: 0,
                        color: Theme.of(context).colorScheme.tertiary,
                      ),
                      Expanded(
                        child: Text(
                          announcement.content,
                          style: const TextStyle(
                            height: 2,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
