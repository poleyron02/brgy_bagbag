import 'package:brgy_bagbag/admin/widgets/announcement_category_dialog.dart';
import 'package:brgy_bagbag/admin/widgets/announcement_dialog.dart';
import 'package:brgy_bagbag/admin/widgets/announcement_receiver_dialog.dart';
import 'package:brgy_bagbag/db_helper.dart';
import 'package:brgy_bagbag/functions.dart';
import 'package:brgy_bagbag/models/admin_account.dart';
import 'package:brgy_bagbag/models/announcement.dart';
import 'package:brgy_bagbag/resident/widgets/are_you_sure_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

class AnnouncementPageView extends StatelessWidget {
  const AnnouncementPageView({
    super.key,
    required this.admin,
    this.isPortrait = false,
    this.drawer,
  });

  final AdminAccount admin;

  final bool isPortrait;
  final Widget? drawer;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(child: drawer),
      appBar: AppBar(
        leading: isPortrait ? null : const Icon(TablerIcons.speakerphone),
        title: const Text('Announcement'),
        actions: !admin.isSuper
            ? null
            : isPortrait
                ? [
                    IconButton(
                      onPressed: () => showDialog(
                        context: context,
                        builder: (context) => AnnouncementReceiverDialog(),
                      ),
                      icon: const Icon(TablerIcons.users),
                      // label: const Text('Receiver Option'),
                    ),
                    IconButton(
                      onPressed: () => showDialog(
                        context: context,
                        builder: (context) => AnnouncementCategoryDialog(),
                      ),
                      icon: const Icon(TablerIcons.category),
                      // label: const Text('Category Option'),
                    ),
                    IconButton(
                      onPressed: () => showDialog(
                        context: context,
                        builder: (context) => AnnouncementDialog(),
                      ),
                      icon: const Icon(TablerIcons.plus),
                      // label: const Text('Add Announcement'),
                    ),
                  ]
                : [
                    TextButton.icon(
                      onPressed: () => showDialog(
                        context: context,
                        builder: (context) => AnnouncementReceiverDialog(),
                      ),
                      icon: const Icon(TablerIcons.users),
                      label: const Text('Receiver Option'),
                    ),
                    TextButton.icon(
                      onPressed: () => showDialog(
                        context: context,
                        builder: (context) => AnnouncementCategoryDialog(),
                      ),
                      icon: const Icon(TablerIcons.category),
                      label: const Text('Category Option'),
                    ),
                    TextButton.icon(
                      onPressed: () => showDialog(
                        context: context,
                        builder: (context) => AnnouncementDialog(),
                      ),
                      icon: const Icon(TablerIcons.plus),
                      label: const Text('Add Announcement'),
                    ),
                  ],
      ),
      body: StreamBuilder(
        stream: announcementsStream,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No announcements yet.'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: snapshot.data!.size,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              Announcement announcement = snapshot.data!.docs[index].data();

              return Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Theme.of(context).colorScheme.secondaryContainer),
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(borderRadius: BorderRadius.circular(8), child: SizedBox.square(dimension: isPortrait ? 100 : 200, child: Image.network(announcement.image, fit: BoxFit.cover))),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  announcement.title,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              if (admin.isSuper)
                                Row(
                                  children: [
                                    TextButton.icon(
                                      onPressed: () => showDialog(context: context, builder: (context) => AnnouncementDialog(announcement: announcement)),
                                      icon: const Icon(TablerIcons.edit),
                                      label: const Text('Edit'),
                                    ),
                                    TextButton.icon(
                                      onPressed: () async {
                                        bool? sure = await showDialog(
                                          context: context,
                                          builder: (context) => const AreYouSureDialog(),
                                        );

                                        if (sure == null) return;
                                        if (!sure) return;
                                        removeAnnouncement(announcement.id);
                                      },
                                      icon: const Icon(TablerIcons.trash),
                                      label: const Text('Delete'),
                                      style: const ButtonStyle(foregroundColor: WidgetStatePropertyAll(Colors.pink)),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                          Divider(color: Theme.of(context).colorScheme.secondaryContainer),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Row(
                              children: [
                                Icon(TablerIcons.clock, size: 16, color: Theme.of(context).colorScheme.secondary),
                                const SizedBox(width: 8),
                                Text(
                                  announcement.createdAt.format(),
                                  style: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.secondary),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            announcement.content,
                            maxLines: 4,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(height: 1.5),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
