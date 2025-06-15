import 'package:brgy_bagbag/db_helper.dart';
import 'package:brgy_bagbag/functions.dart';
import 'package:brgy_bagbag/globals.dart';
import 'package:brgy_bagbag/models/custom_notifier.dart';
import 'package:brgy_bagbag/models/incident_person.dart';
import 'package:brgy_bagbag/models/list_notifier.dart';
import 'package:brgy_bagbag/models/resident.dart';
import 'package:brgy_bagbag/widgets/column_separated.dart';
import 'package:brgy_bagbag/widgets/date_picker.dart';
import 'package:brgy_bagbag/widgets/dropdown_form_field.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

class IncidentPersonDialog extends StatelessWidget {
  IncidentPersonDialog({
    super.key,
    required this.notifier,
    this.incidentPerson,
  });

  final IncidentPerson? incidentPerson;

  final ListNotifier<IncidentPerson> notifier;

  final GlobalKey<FormState> formKey = GlobalKey();

  late TextEditingController residentId = TextEditingController(text: incidentPerson?.residentId);
  late TextEditingController name = TextEditingController(text: incidentPerson?.name);
  late TextEditingController gender = TextEditingController(text: incidentPerson?.gender);
  late TextEditingController phoneNumber = TextEditingController(text: incidentPerson?.phoneNumber);
  late CustomNotifier<DateTime> birthday = CustomNotifier(incidentPerson?.birthday.toDate());
  late TextEditingController address = TextEditingController(text: incidentPerson?.address);
  late TextEditingController description = TextEditingController(text: incidentPerson?.description);

  final TextEditingController searchResident = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      insetPadding: const EdgeInsets.all(10),
      contentPadding: const EdgeInsets.all(16),
      icon: const Icon(TablerIcons.user),
      title: const Text('Select Incident Person'),
      content: SizedBox(
        width: 1000,
        height: 500,
        child: Row(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: ColumnSeparated(
                    spacing: 16,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: residentId,
                        enabled: false,
                        readOnly: true,
                        decoration: InputDecoration(
                          labelText: 'Resident ID',
                          border: outlineInputBorder(context),
                          enabledBorder: outlineInputBorder(context),
                        ),
                      ),
                      TextFormField(
                        controller: name,
                        validator: validate,
                        decoration: InputDecoration(
                          labelText: 'Name',
                          border: outlineInputBorder(context),
                          enabledBorder: outlineInputBorder(context),
                        ),
                      ),
                      DropdownFormField(
                        controller: gender,
                        label: 'Gender',
                        values: genders,
                        prefixIcon: const Icon(TablerIcons.gender_bigender),
                      ),
                      TextFormField(
                        controller: phoneNumber,
                        validator: validate,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        decoration: InputDecoration(
                          labelText: 'Phone number',
                          prefixIcon: const Icon(TablerIcons.phone),
                          border: outlineInputBorder(context),
                          enabledBorder: outlineInputBorder(context),
                        ),
                      ),
                      DatePicker(
                        label: 'Birthday',
                        controller: birthday,
                      ),
                      TextFormField(
                        controller: address,
                        validator: validate,
                        decoration: InputDecoration(
                          labelText: 'Address',
                          prefixIcon: const Icon(TablerIcons.map_pin),
                          border: outlineInputBorder(context),
                          enabledBorder: outlineInputBorder(context),
                        ),
                      ),
                      TextFormField(
                        controller: description,
                        validator: validate,
                        minLines: 5,
                        maxLines: 10,
                        decoration: InputDecoration(
                          labelText: 'Description',
                          border: outlineInputBorder(context),
                          enabledBorder: outlineInputBorder(context),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            VerticalDivider(
              width: 32,
              color: Theme.of(context).colorScheme.secondaryContainer,
            ),
            Expanded(
              child: Column(
                children: [
                  TextFormField(
                    controller: searchResident,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(TablerIcons.search),
                      hintText: 'Search...',
                      border: outlineInputBorder(context),
                      enabledBorder: outlineInputBorder(context),
                    ),
                  ),
                  Expanded(
                    child: StreamBuilder(
                      stream: residentsCollection.snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

                        if (snapshot.data!.docs.isEmpty) return const Center(child: Text('No residents found'));

                        List<Resident> residents = snapshot.data!.docs.map((e) => e.data()).toList();

                        return ValueListenableBuilder(
                          valueListenable: searchResident,
                          builder: (context, searchQuery, child) {
                            List<Resident> searchResidents = searchQuery.text.isEmpty ? residents : residents.where((element) => element.fullName.contains(searchQuery.text)).toList();

                            if (searchResidents.isEmpty) {
                              return const Center(child: Text('No residents found.'));
                            }

                            return ListView.builder(
                              itemCount: searchResidents.length,
                              itemBuilder: (context, index) {
                                Resident resident = searchResidents[index];

                                return ValueListenableBuilder(
                                  valueListenable: residentId,
                                  builder: (context, residentIdValue, child) {
                                    return ListTile(
                                      selected: resident.id == residentIdValue.text,
                                      enabled: notifier.value.where((element) => element.residentId == resident.id).isEmpty,
                                      leading: const Icon(TablerIcons.user),
                                      title: Text(resident.fullName),
                                      subtitle: Text(resident.birthday.format()),
                                      onTap: () {
                                        if (resident.id == residentIdValue.text) {
                                          residentId.clear();
                                          name.clear();
                                          gender.clear();
                                          phoneNumber.clear();
                                          birthday.remove();
                                          address.clear();
                                          return;
                                        }

                                        residentId.text = resident.id;
                                        name.text = resident.fullName;
                                        gender.text = resident.gender;
                                        phoneNumber.text = resident.contactNumber;
                                        birthday.set(resident.birthday.toDate());
                                        address.text = resident.address;
                                      },
                                    );
                                  },
                                );
                              },
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCEL')),
        FilledButton(
          onPressed: () {
            if (!formKey.currentState!.validate()) return;

            IncidentPerson incidentPerson = IncidentPerson(
              residentId: residentId.text.isEmpty ? null : residentId.text,
              name: name.text,
              gender: gender.text,
              phoneNumber: phoneNumber.text,
              birthday: Timestamp.fromDate(birthday.value!),
              address: address.text,
              description: description.text,
            );

            notifier.add(incidentPerson);

            Navigator.pop(context);
          },
          child: const Text('CONFIRM'),
        ),
      ],
    );
  }
}
