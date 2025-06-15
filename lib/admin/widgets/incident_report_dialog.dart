import 'package:brgy_bagbag/admin/widgets/incident_person_dialog.dart';
import 'package:brgy_bagbag/db_helper.dart';
import 'package:brgy_bagbag/functions.dart';
import 'package:brgy_bagbag/globals.dart';
import 'package:brgy_bagbag/models/custom_notifier.dart';
import 'package:brgy_bagbag/models/incident_person.dart';
import 'package:brgy_bagbag/models/incident_report.dart';
import 'package:brgy_bagbag/models/list_notifier.dart';
import 'package:brgy_bagbag/widgets/column_separated.dart';
import 'package:brgy_bagbag/widgets/date_picker.dart';
import 'package:brgy_bagbag/widgets/dropdown_form_field.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

class IncidentReportDialog extends StatelessWidget {
  IncidentReportDialog({
    super.key,
    this.incidentReport,
  });

  final IncidentReport? incidentReport;

  final GlobalKey<FormState> formKey = GlobalKey();

  late DocumentReference<IncidentReport> doc = incidentReportCollection.doc(incidentReport?.id);

  late TextEditingController blotterType = TextEditingController(text: incidentReport?.blotterType);
  late TextEditingController incidentCase = TextEditingController(text: incidentReport?.incidentCase);
  late TextEditingController title = TextEditingController(text: incidentReport?.title);
  late CustomNotifier<DateTime> occurredAt = CustomNotifier(incidentReport?.occurredAt.toDate());
  late TextEditingController location = TextEditingController(text: incidentReport?.location);
  late TextEditingController narrative = TextEditingController(text: incidentReport?.narrative);

  late ListNotifier<IncidentPerson> complainants = ListNotifier(incidentReport?.complainants ?? []);
  late ListNotifier<IncidentPerson> offenders = ListNotifier(incidentReport?.offenders ?? []);

  void submit(BuildContext context) async {
    if (!formKey.currentState!.validate()) return;

    IncidentReport incidentReport = IncidentReport(
      id: doc.id,
      blotterType: blotterType.text,
      incidentCase: incidentCase.text,
      title: title.text,
      occurredAt: Timestamp.fromDate(occurredAt.value!),
      location: location.text,
      narrative: narrative.text,
      complainants: complainants.value,
      offenders: offenders.value,
      createdAt: Timestamp.now(),
      updatedAt: Timestamp.now(),
    );

    await setIncidentReport(incidentReport, doc: doc);

    if (context.mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      insetPadding: const EdgeInsets.all(10),
      contentPadding: const EdgeInsets.all(16),
      icon: const Icon(TablerIcons.gavel),
      title: const Text('Add Incident Report'),
      content: SizedBox(
        width: 500,
        child: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: ColumnSeparated(
              spacing: 16,
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownFormField(controller: blotterType, label: 'Blotter Type', values: blotterTypes),
                DropdownFormField(controller: incidentCase, label: 'Case', values: incidentCases),
                DatePicker(
                  label: 'Occurred at',
                  controller: occurredAt,
                  pickTime: true,
                ),
                TextFormField(
                  controller: location,
                  validator: validate,
                  decoration: InputDecoration(
                    labelText: 'Location',
                    border: outlineInputBorder(context),
                    enabledBorder: outlineInputBorder(context),
                  ),
                ),
                TextFormField(
                  controller: title,
                  validator: validate,
                  decoration: InputDecoration(
                    labelText: 'Title',
                    border: outlineInputBorder(context),
                    enabledBorder: outlineInputBorder(context),
                  ),
                ),
                TextFormField(
                  controller: narrative,
                  validator: validate,
                  minLines: 5,
                  maxLines: 10,
                  decoration: InputDecoration(
                    labelText: 'Narrative',
                    border: outlineInputBorder(context),
                    enabledBorder: outlineInputBorder(context),
                  ),
                ),
                Divider(
                  height: 0,
                  color: Theme.of(context).colorScheme.secondaryContainer,
                ),
                IncidentPersonList(
                  label: 'Complainants',
                  notifier: complainants,
                ),
                Divider(
                  height: 0,
                  color: Theme.of(context).colorScheme.secondaryContainer,
                ),
                IncidentPersonList(
                  label: 'Offenders',
                  notifier: offenders,
                ),
              ],
            ),
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

class IncidentPersonList extends StatelessWidget {
  const IncidentPersonList({
    super.key,
    required this.label,
    required this.notifier,
  });

  final String label;
  final ListNotifier<IncidentPerson> notifier;

  @override
  Widget build(BuildContext context) {
    return FormField(
      validator: (value) {
        if (notifier.value.isEmpty) return 'Required';
        return null;
      },
      builder: (field) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(TablerIcons.users),
            title: Text(label),
            subtitle: !field.hasError
                ? null
                : Text(
                    field.errorText ?? '',
                    style: TextStyle(color: Theme.of(context).colorScheme.error),
                  ),
            trailing: IconButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => IncidentPersonDialog(
                    notifier: notifier,
                  ),
                );
              },
              icon: const Icon(TablerIcons.plus),
            ),
          ),
          ValueListenableBuilder(
            valueListenable: notifier,
            builder: (context, value, child) {
              return ListView.builder(
                shrinkWrap: true,
                itemCount: value.length,
                itemBuilder: (context, index) {
                  IncidentPerson person = value[index];

                  return ListTile(
                    leading: const Icon(TablerIcons.user),
                    title: Text(person.name),
                    subtitle: Text(person.birthday.format()),
                    trailing: IconButton(
                      onPressed: () => notifier.remove(person),
                      icon: const Icon(
                        TablerIcons.trash,
                        color: Colors.pink,
                      ),
                    ),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) => IncidentPersonDialog(
                          notifier: notifier,
                          incidentPerson: person,
                        ),
                      );
                    },
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
