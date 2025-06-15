import 'package:brgy_bagbag/db_helper.dart';
import 'package:brgy_bagbag/functions.dart';
import 'package:brgy_bagbag/models/notification_message.dart';
import 'package:brgy_bagbag/models/resident.dart';
import 'package:brgy_bagbag/widgets/notification_message_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

class ResidentNotificationsPageView extends StatefulWidget {
  const ResidentNotificationsPageView({
    super.key,
    required this.resident,
    this.drawer,
    this.isPortrait = false,
  });

  final Resident resident;
  final Widget? drawer;
  final bool isPortrait;

  @override
  _ResidentNotificationsPageViewState createState() => _ResidentNotificationsPageViewState();
}

class _ResidentNotificationsPageViewState extends State<ResidentNotificationsPageView> {
  List<NotificationMessage> selectedNotifications = [];
  bool allSelected = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(child: widget.drawer),
      appBar: AppBar(
        leading: widget.isPortrait ? null : const Icon(TablerIcons.bell),
        title: const Text('Notifications'),
        actions: [
          IconButton(
            icon: Icon(allSelected ? Icons.deselect : Icons.select_all),
            tooltip: allSelected ? 'Deselect All' : 'Select All',
            onPressed: _toggleSelectAll,
          ),
          IconButton(
            icon: const Icon(Icons.mark_as_unread),
            tooltip: 'Unmark as Read',
            onPressed: selectedNotifications.isEmpty ? null : _unmarkAsRead,
          ),
          IconButton(
            icon: const Icon(Icons.mark_email_read),
            tooltip: 'Mark as Read',
            onPressed: selectedNotifications.isEmpty ? null : _markAsRead,
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            tooltip: 'Delete',
            onPressed: selectedNotifications.isEmpty ? null : _deleteSelectedNotifications,
          ),
        ],
      ),
      body: StreamBuilder(
        stream: notificationsCollection.where('toUid', isEqualTo: widget.resident.id).orderBy('createdAt', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          if (snapshot.data!.docs.isEmpty) return const Center(child: Text('No notifications yet.'));

          List<NotificationMessage> notifications = snapshot.data!.docs.map((e) => (e.data())).toList();

          return ListView.builder(
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              NotificationMessage notification = notifications[index];
              bool isSelected = selectedNotifications.contains(notification);

              return ListTile(
                leading: Icon(
                  TablerIcons.mail,
                  color: notification.isRead ? Theme.of(context).colorScheme.secondary : null,
                ),
                title: Text(notification.title),
                subtitle: Text(notification.content),
                trailing: Text(notification.createdAt.format()),
                tileColor: isSelected ? Theme.of(context).colorScheme.primary : null,
                textColor: isSelected
                    ? Theme.of(context).colorScheme.onPrimary
                    : notification.isRead
                        ? Theme.of(context).colorScheme.secondary
                        : null,
                iconColor: isSelected
                    ? Theme.of(context).colorScheme.onPrimary
                    : notification.isRead
                        ? Theme.of(context).colorScheme.secondary
                        : null,
                onLongPress: () {
                  setState(() {
                    isSelected ? selectedNotifications.remove(notification) : selectedNotifications.add(notification);
                  });
                },
                onTap: () async {
                  if (!notification.isRead) {
                    notification.isRead = true;
                    DocumentReference<NotificationMessage> doc = notificationsCollection.doc(notification.id);
                    await setNotification(notification, doc: doc);
                  }
                  if (context.mounted) {
                    showDialog(
                      context: context,
                      builder: (context) => NotificationMessageDialog(notification: notification),
                    );
                  }
                },
              );
            },
          );
        },
      ),
    );
  }

  void _toggleSelectAll() {
    setState(() {
      allSelected = !allSelected;

      if (allSelected) {
        _selectAllNotifications();
      } else {
        _deselectAllNotifications();
      }
    });
  }

  void _selectAllNotifications() async {
    Stream<List<NotificationMessage>> notificationStream = notificationsCollection.where('toUid', isEqualTo: widget.resident.id).orderBy('createdAt', descending: true).snapshots().map((snapshot) => snapshot.docs.map((doc) => (doc.data())).toList());

    notificationStream.listen((allNotifications) {
      setState(() {
        selectedNotifications = allNotifications;
      });
    });
  }

  void _deselectAllNotifications() {
    setState(() {
      selectedNotifications.clear();
    });
  }

  void _markAsRead() async {
    for (var notification in selectedNotifications) {
      notification.isRead = true;
      DocumentReference<NotificationMessage> doc = notificationsCollection.doc(notification.id);
      await setNotification(notification, doc: doc);
    }
    setState(() {
      selectedNotifications.clear();
      allSelected = false;
    });
  }

  void _unmarkAsRead() async {
    for (var notification in selectedNotifications) {
      notification.isRead = false;
      DocumentReference<NotificationMessage> doc = notificationsCollection.doc(notification.id);
      await setNotification(notification, doc: doc);
    }
    setState(() {
      selectedNotifications.clear();
      allSelected = false;
    });
  }

  void _deleteSelectedNotifications() async {
    for (var notification in selectedNotifications) {
      DocumentReference<NotificationMessage> doc = notificationsCollection.doc(notification.id);
      await doc.delete();
    }
    setState(() {
      selectedNotifications.clear();
      allSelected = false;
    });
  }
}
