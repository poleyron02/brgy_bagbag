import 'package:brgy_bagbag/db_helper.dart';
import 'package:brgy_bagbag/functions.dart';
import 'package:brgy_bagbag/globals.dart';
import 'package:brgy_bagbag/models/announcement_category.dart';
import 'package:brgy_bagbag/models/custom_notifier.dart';
import 'package:brgy_bagbag/widgets/column_separated.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

class AnnouncementCategoryDialog extends StatelessWidget {
  AnnouncementCategoryDialog({super.key});

  final GlobalKey<FormState> formKey = GlobalKey();
  final CustomNotifier<DocumentReference<AnnouncementCategory>> doc = CustomNotifier(null);
  final TextEditingController name = TextEditingController();

  void submit() async {
    if (!formKey.currentState!.validate()) return;

    DocumentReference<AnnouncementCategory> newDoc = announcementCategoriesCollection.doc();
    AnnouncementCategory newCategory = AnnouncementCategory(id: doc.value?.id ?? newDoc.id, name: name.text, createdAt: Timestamp.now(), updatedAt: Timestamp.now());

    await setAnnouncementCategory(newCategory, doc: doc.value ?? newDoc);

    name.clear();
    doc.remove();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      insetPadding: const EdgeInsets.all(10),
      contentPadding: const EdgeInsets.all(16),
      icon: const Icon(TablerIcons.category),
      title: const Text('Category'),
      content: ColumnSeparated(
        spacing: 16,
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 500,
            height: 500,
            child: StreamBuilder(
              stream: announcementCategoriesCollection.orderBy('createdAt').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No categories yet.'));
                }

                return ValueListenableBuilder(
                  valueListenable: doc,
                  builder: (context, docValue, child) {
                    return ListView.builder(
                      itemCount: snapshot.data!.size,
                      itemBuilder: (context, index) {
                        AnnouncementCategory category = snapshot.data!.docs[index].data();

                        return ListTile(
                          dense: true,
                          title: Text(category.name),
                          subtitle: Text(category.createdAt.format()),
                          selected: docValue?.id == category.id,
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                onPressed: () {
                                  doc.set(announcementCategoriesCollection.doc(category.id));
                                  name.text = category.name;
                                },
                                icon: const Icon(TablerIcons.edit),
                              ),
                              IconButton(
                                onPressed: () => removeAnnouncementCategory(category.id),
                                icon: const Icon(
                                  TablerIcons.trash,
                                  color: Colors.pink,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
          ValueListenableBuilder(
            valueListenable: doc,
            builder: (context, docValue, child) {
              return Row(
                children: [
                  Expanded(
                    child: Form(
                      key: formKey,
                      child: TextFormField(
                        controller: name,
                        validator: validate,
                        textInputAction: TextInputAction.done,
                        onEditingComplete: submit,
                        decoration: InputDecoration(
                          labelText: 'Name',
                          border: outlineInputBorder(context),
                          enabledBorder: outlineInputBorder(context),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  if (docValue != null)
                    TextButton(
                      onPressed: () {
                        name.clear();
                        doc.remove();
                      },
                      child: const Text('CANCEL'),
                    ),
                  FilledButton.icon(
                    onPressed: submit,
                    icon: Icon(docValue == null ? TablerIcons.plus : TablerIcons.edit),
                    label: Text(docValue == null ? 'ADD' : 'EDIT'),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
