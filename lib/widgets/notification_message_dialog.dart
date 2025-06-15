import 'package:brgy_bagbag/models/notification_link.dart';
import 'package:brgy_bagbag/models/notification_message.dart';
import 'package:brgy_bagbag/widgets/column_separated.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:url_launcher/url_launcher.dart';

class NotificationMessageDialog extends StatelessWidget {
  const NotificationMessageDialog({
    super.key,
    required this.notification,
  });

  final NotificationMessage notification;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      scrollable: true,
      insetPadding: const EdgeInsets.all(10),
      contentPadding: const EdgeInsets.all(16),
      icon: const Icon(TablerIcons.mail),
      title: Text(notification.title),
      content: SingleChildScrollView(
        child: SizedBox(
          width: 500,
          child: ColumnSeparated(
            spacing: 16,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(notification.content),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(
                  notification.links.length,
                  (index) {
                    NotificationLink link = notification.links[index];

                    return ListTile(
                      leading: const Icon(TablerIcons.link),
                      title: Text(link.name),
                      // subtitle: Text(link.url, maxLines: 1),
                      subtitle: const Text('Click to open URL'),
                      onTap: () async {
                        if (!await launchUrl(Uri.parse(link.url))) {
                          throw Exception('Could not launch url');
                        }
                      },
                    );
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
