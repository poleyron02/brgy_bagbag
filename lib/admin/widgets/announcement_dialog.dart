import 'package:brgy_bagbag/admin/widgets/image_picker.dart';
import 'package:brgy_bagbag/db_helper.dart';
import 'package:brgy_bagbag/functions.dart';
import 'package:brgy_bagbag/globals.dart';
import 'package:brgy_bagbag/models/announcement.dart';
import 'package:brgy_bagbag/models/announcement_category.dart';
import 'package:brgy_bagbag/models/announcement_receiver.dart';
import 'package:brgy_bagbag/widgets/column_separated.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

class AnnouncementDialog extends StatelessWidget {
  AnnouncementDialog({
    super.key,
    this.announcement,
  });

  final GlobalKey<FormState> formKey = GlobalKey();

  final Announcement? announcement;

  late DocumentReference<Announcement> doc = announcementCollection.doc(announcement?.id);

  late TextEditingController category = TextEditingController(text: announcement?.category);
  late TextEditingController receiver = TextEditingController(text: announcement?.receiver);
  late TextEditingController title = TextEditingController(text: announcement?.title);
  late TextEditingController content = TextEditingController(text: announcement?.content);
  late TextEditingController image = TextEditingController(text: announcement?.image);

  void submit(BuildContext context) async {
    if (!formKey.currentState!.validate()) return;

    Announcement newAnnouncement = Announcement(id: doc.id, category: category.text, receiver: receiver.text, title: title.text, content: content.text, image: image.text, createdAt: announcement?.createdAt ?? Timestamp.now(), updatedAt: Timestamp.now());

    await setAnnouncement(newAnnouncement, doc: doc);

    if (context.mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      insetPadding: const EdgeInsets.all(10),
      contentPadding: const EdgeInsets.all(16),
      icon: const Icon(TablerIcons.speakerphone),
      title: const Text('Add Announcement'),
      content: SizedBox(
        width: 500,
        child: Form(
          key: formKey,
          child: ColumnSeparated(
            mainAxisSize: MainAxisSize.min,
            spacing: 16,
            children: [
              FormField(
                validator: (value) {
                  if (image.text.isEmpty) return 'Required';
                  return null;
                },
                builder: (field) => Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ImagePicker(
                      dimension: 200,
                      ref: 'announcement',
                      name: doc.id,
                      controller: image,
                      errorColor: !field.hasError ? null : Theme.of(context).colorScheme.error,
                    ),
                    if (field.hasError)
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Text(
                          field.errorText ?? '',
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                      )
                  ],
                ),
              ),
              FormField(
                validator: validate,
                initialValue: category.text,
                builder: (field) => StreamBuilder(
                  stream: announcementCategoriesCollection.snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return TextField(
                        enabled: false,
                        decoration: InputDecoration(
                          hintText: 'Loading...',
                          border: outlineInputBorder(context),
                          enabledBorder: outlineInputBorder(context),
                        ),
                      );
                    }

                    if (snapshot.data!.docs.isEmpty) {
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const ListTile(
                            dense: true,
                            leading: Icon(TablerIcons.plus),
                            title: Text('Add Category'),
                          ),
                          if (field.hasError)
                            Padding(
                              padding: const EdgeInsets.all(12),
                              child: Text(
                                field.errorText ?? '',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Theme.of(context).colorScheme.error,
                                ),
                              ),
                            )
                        ],
                      );
                    }

                    List<QueryDocumentSnapshot<AnnouncementCategory>> docs = snapshot.data!.docs;

                    return DropdownMenu(
                      expandedInsets: EdgeInsets.zero,
                      label: const Text('Category'),
                      controller: category,
                      initialSelection: category.text,
                      onSelected: (value) {
                        category.text = value!;
                        field.didChange(value);
                      },
                      inputDecorationTheme: InputDecorationTheme(
                        border: outlineInputBorder(context),
                        enabledBorder: outlineInputBorder(context),
                      ),
                      errorText: field.errorText,
                      dropdownMenuEntries: List.generate(
                        docs.length,
                        (index) {
                          AnnouncementCategory category = docs[index].data();
                          return DropdownMenuEntry(value: category.name, label: category.name);
                        },
                      ),
                    );
                  },
                ),
              ),
              ReceiverFormField(
                controller: receiver,
                label: 'Receiver',
              ),
              TextFormField(
                validator: validate,
                controller: title,
                decoration: InputDecoration(
                  labelText: 'Title',
                  border: outlineInputBorder(context),
                  enabledBorder: outlineInputBorder(context),
                ),
              ),
              TextFormField(
                validator: validate,
                controller: content,
                keyboardType: TextInputType.multiline,
                minLines: 5,
                maxLines: 10,
                textAlignVertical: TextAlignVertical.top,
                decoration: InputDecoration(
                  labelText: 'Content',
                  border: outlineInputBorder(context),
                  enabledBorder: outlineInputBorder(context),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('CANCEL'),
        ),
        FilledButton(
          onPressed: () => submit(context),
          child: const Text('CONFIRM'),
        ),
      ],
    );
  }
}

class ReceiverFormField extends StatelessWidget {
  const ReceiverFormField({
    super.key,
    required this.label,
    required this.controller,
  });

  final String label;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return FormField(
      validator: validate,
      initialValue: controller.text,
      builder: (field) => StreamBuilder(
        stream: announcementReceiverCollection.snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return TextField(
              enabled: false,
              decoration: InputDecoration(
                hintText: 'Loading...',
                border: outlineInputBorder(context),
                enabledBorder: outlineInputBorder(context),
              ),
            );
          }

          if (snapshot.data!.docs.isEmpty) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const ListTile(
                  dense: true,
                  leading: Icon(TablerIcons.plus),
                  title: Text('Add Receiver'),
                ),
                if (field.hasError)
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(
                      field.errorText ?? '',
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  )
              ],
            );
          }

          List<QueryDocumentSnapshot<AnnouncementReceiver>> docs = snapshot.data!.docs;

          return DropdownMenu(
            expandedInsets: EdgeInsets.zero,
            label: Text(label),
            controller: controller,
            onSelected: (value) {
              controller.text = value!;
              field.didChange(value);
            },
            inputDecorationTheme: InputDecorationTheme(
              border: outlineInputBorder(context),
              enabledBorder: outlineInputBorder(context),
            ),
            errorText: field.errorText,
            dropdownMenuEntries: List.generate(
              docs.length,
              (index) {
                AnnouncementReceiver receiver = docs[index].data();
                return DropdownMenuEntry(value: receiver.name, label: receiver.name);
              },
            ),
          );
        },
      ),
    );
  }
}
