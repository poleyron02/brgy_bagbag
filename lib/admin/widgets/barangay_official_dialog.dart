import 'package:brgy_bagbag/admin/widgets/announcement_dialog.dart';
import 'package:brgy_bagbag/admin/widgets/image_picker.dart';
import 'package:brgy_bagbag/db_helper.dart';
import 'package:brgy_bagbag/functions.dart';
import 'package:brgy_bagbag/globals.dart';
import 'package:brgy_bagbag/models/barangay_official.dart';
import 'package:brgy_bagbag/models/custom_notifier.dart';
import 'package:brgy_bagbag/widgets/column_separated.dart';
import 'package:brgy_bagbag/widgets/date_picker.dart';
import 'package:brgy_bagbag/widgets/dropdown_form_field.dart';
import 'package:brgy_bagbag/widgets/row_separated.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

class BarangayOfficialDialog extends StatelessWidget {
  BarangayOfficialDialog({super.key, this.barangayOfficial});

  final BarangayOfficial? barangayOfficial;

  final GlobalKey<FormState> formKey = GlobalKey();

  late DocumentReference<BarangayOfficial> doc = barangayOfficialCollection.doc(barangayOfficial?.id);

  late TextEditingController image = TextEditingController(text: barangayOfficial?.image);
  late TextEditingController firstName = TextEditingController(text: barangayOfficial?.firstName);
  late TextEditingController middleName = TextEditingController(text: barangayOfficial?.middleName);
  late TextEditingController lastName = TextEditingController(text: barangayOfficial?.lastName);
  late TextEditingController suffix = TextEditingController(text: barangayOfficial?.suffix);
  late TextEditingController gender = TextEditingController(text: barangayOfficial?.gender);
  late TextEditingController position = TextEditingController(text: barangayOfficial?.position);

  late CustomNotifier<DateTime> appointedAt = CustomNotifier(barangayOfficial?.appointedAt.toDate());
  late CustomNotifier<DateTime> endedAt = CustomNotifier(barangayOfficial?.endedAt?.toDate());
  late TextEditingController appointedAtController = TextEditingController(text: barangayOfficial?.appointedAt.format());
  late TextEditingController endedAtController = TextEditingController(text: barangayOfficial?.appointedAt.format());

  void submit(BuildContext context) async {
    if (!formKey.currentState!.validate()) return;

    BarangayOfficial newBarangayOfficial = BarangayOfficial(
      id: doc.id,
      firstName: firstName.text,
      middleName: middleName.text.isEmpty ? null : middleName.text,
      lastName: lastName.text,
      suffix: suffix.text,
      gender: gender.text,
      position: position.text,
      image: image.text,
      appointedAt: Timestamp.fromDate(appointedAt.value!),
      endedAt: endedAt.value == null ? null : Timestamp.fromDate(endedAt.value!),
      createdAt: barangayOfficial?.createdAt ?? Timestamp.now(),
      updatedAt: Timestamp.now(),
    );

    await setBarangayOfficial(newBarangayOfficial, doc: doc);

    if (context.mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      insetPadding: const EdgeInsets.all(10),
      contentPadding: const EdgeInsets.all(16),
      icon: const Icon(TablerIcons.discount_check),
      title: const Text('Add Barangay Official'),
      content: SizedBox(
        width: 500,
        child: Form(
          key: formKey,
          child: ColumnSeparated(
            spacing: 16,
            mainAxisSize: MainAxisSize.min,
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
                      ref: 'barangay_official',
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
              RowSeparated(
                spacing: 16,
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: firstName,
                      validator: validate,
                      decoration: InputDecoration(
                        labelText: 'First name',
                        border: outlineInputBorder(context),
                        enabledBorder: outlineInputBorder(context),
                      ),
                    ),
                  ),
                  Expanded(
                    child: TextFormField(
                      controller: middleName,
                      // validator: validate,
                      decoration: InputDecoration(
                        labelText: 'Middle name',
                        border: outlineInputBorder(context),
                        enabledBorder: outlineInputBorder(context),
                      ),
                    ),
                  ),
                ],
              ),
              RowSeparated(
                spacing: 16,
                children: [
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: lastName,
                      validator: validate,
                      decoration: InputDecoration(
                        labelText: 'Last name',
                        border: outlineInputBorder(context),
                        enabledBorder: outlineInputBorder(context),
                      ),
                    ),
                  ),
                  Expanded(
                    child: DropdownFormField(controller: suffix, label: 'Suffix', values: nameSuffixes),
                  ),
                ],
              ),
              DropdownFormField(controller: gender, label: 'Gender', values: genders),
              ReceiverFormField(
                controller: position,
                label: 'Position',
              ),
              DatePicker(label: 'Appointed at', controller: appointedAt),
              DatePicker(label: 'Ended at', controller: endedAt, isNullable: true),
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
