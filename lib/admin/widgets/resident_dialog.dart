import 'package:brgy_bagbag/admin/widgets/reason_for_decline_dialog.dart';
import 'package:brgy_bagbag/db_helper.dart';
import 'package:brgy_bagbag/functions.dart';
import 'package:brgy_bagbag/globals.dart';
import 'package:brgy_bagbag/models/custom_notifier.dart';
import 'package:brgy_bagbag/models/resident.dart';
import 'package:brgy_bagbag/resident/register.dart';
import 'package:brgy_bagbag/widgets/column_separated.dart';
import 'package:brgy_bagbag/widgets/date_picker.dart';
import 'package:brgy_bagbag/widgets/dropdown_form_field.dart';
import 'package:brgy_bagbag/widgets/row_separated.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

class ResidentDialog extends StatelessWidget {
  ResidentDialog({
    super.key,
    required this.resident,
    required this.isAdmin,
  });

  final Resident resident;
  final bool isAdmin;

  final GlobalKey<FormState> formKey = GlobalKey();

  late TextEditingController firstName = TextEditingController(text: resident.firstName);
  late TextEditingController middleName = TextEditingController(text: resident.middleName);
  late TextEditingController lastName = TextEditingController(text: resident.lastName);
  late TextEditingController suffix = TextEditingController(text: resident.suffix);
  late TextEditingController gender = TextEditingController(text: resident.gender);
  late CustomNotifier<DateTime> birthday = CustomNotifier(resident.birthday.toDate());
  late TextEditingController contactNumber = TextEditingController(text: resident.contactNumber);
  // late TextEditingController address = TextEditingController(text: resident.address);
  late TextEditingController street = TextEditingController(text: resident.street);
  late TextEditingController city = TextEditingController(text: resident.city);
  late TextEditingController barangay = TextEditingController(text: resident.barangay);
  late TextEditingController placeOfBirth = TextEditingController(text: resident.placeOfBirth);
  late TextEditingController occupation = TextEditingController(text: resident.occupation);
  late ValueNotifier<bool> isVoter = ValueNotifier(resident.isVoter);
  // late TextEditingController purokNumber = TextEditingController(text: resident.purokNumber);
  late TextEditingController residentType = TextEditingController(text: resident.residentType);
  late TextEditingController residentSince = TextEditingController(text: resident.residentSince);
  // late CustomNotifier<DateTime> residentSince = CustomNotifier(resident.residentSince.toDate());

  void submit(BuildContext context) async {
    Resident newResident = Resident(
      id: resident.id,
      status: resident.status,
      reasonForDecline: resident.reasonForDecline,
      userId: resident.userId,
      firstName: firstName.text,
      middleName: middleName.text,
      lastName: lastName.text,
      suffix: suffix.text,
      gender: gender.text,
      birthday: Timestamp.fromDate(birthday.value!),
      contactNumber: contactNumber.text,
      // address: address.text,
      street: street.text,
      barangay: barangay.text,
      city: city.text,
      placeOfBirth: placeOfBirth.text,
      occupation: occupation.text,
      isVoter: isVoter.value,
      // purokNumber: purokNumber.text,
      residentSince: residentSince.text,
      residentType: residentType.text,
      firstValidId: resident.firstValidId,
      secondValidId: resident.secondValidId,
      createdAt: resident.createdAt,
      updatedAt: Timestamp.now(),
    );

    DocumentReference<Resident> doc = residentsCollection.doc(resident.id);

    await setResident(newResident, doc: doc);

    if (context.mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      insetPadding: const EdgeInsets.all(10),
      contentPadding: const EdgeInsets.all(16),
      icon: const Icon(TablerIcons.gavel),
      title: const Text('Edit Resident'),
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
                              validator: validate,
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
                          Expanded(child: DropdownFormField(controller: suffix, label: 'Suffix', values: nameSuffixes)),
                        ],
                      ),
                      DropdownFormField(controller: gender, label: 'Gender', values: genders),
                      DatePicker(label: 'Birthday', controller: birthday),
                      TextFormField(
                        controller: contactNumber,
                        validator: validateContactNumber,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(10),
                          FilteringTextInputFormatter.allow(RegExp(r'^[1-9]\d*')),
                        ],
                        decoration: InputDecoration(
                          prefixText: '+63',
                          prefixIcon: const Icon(TablerIcons.phone),
                          labelText: 'Contact number',
                          border: outlineInputBorder(context),
                          enabledBorder: outlineInputBorder(context),
                        ),
                      ),
                      // TextFormField(
                      //   controller: address,
                      //   validator: validate,
                      //   decoration: InputDecoration(
                      //     labelText: 'Address',
                      //     border: outlineInputBorder(context),
                      //     enabledBorder: outlineInputBorder(context),
                      //   ),
                      // ),
                      RowSeparated(
                        spacing: 16,
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: street,
                              validator: validate,
                              decoration: InputDecoration(
                                labelText: 'Street',
                                border: outlineInputBorder(context),
                                enabledBorder: outlineInputBorder(context),
                              ),
                            ),
                          ),
                          Expanded(
                            child: TextFormField(
                              controller: barangay,
                              validator: validate,
                              decoration: InputDecoration(
                                labelText: 'Barangay',
                                border: outlineInputBorder(context),
                                enabledBorder: outlineInputBorder(context),
                              ),
                            ),
                          ),
                          Expanded(
                            child: TextFormField(
                              controller: city,
                              validator: validate,
                              decoration: InputDecoration(
                                labelText: 'City',
                                border: outlineInputBorder(context),
                                enabledBorder: outlineInputBorder(context),
                              ),
                            ),
                          ),
                        ],
                      ),
                      TextFormField(
                        controller: placeOfBirth,
                        validator: validate,
                        decoration: InputDecoration(
                          labelText: 'Place of Birth',
                          border: outlineInputBorder(context),
                          enabledBorder: outlineInputBorder(context),
                        ),
                      ),
                      TextFormField(
                        controller: occupation,
                        validator: validate,
                        decoration: InputDecoration(
                          labelText: 'Occupation',
                          border: outlineInputBorder(context),
                          enabledBorder: outlineInputBorder(context),
                        ),
                      ),
                      RowSeparated(
                        spacing: 16,
                        children: [
                          Expanded(child: IsVoterListTile(isVoter: isVoter)),
                          Expanded(
                            child: TextFormField(
                              controller: residentSince,
                              validator: validate,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(4)
                              ],
                              decoration: InputDecoration(
                                labelText: 'Resident since',
                                border: outlineInputBorder(context),
                                enabledBorder: outlineInputBorder(context),
                              ),
                            ),
                          ),
                          // Expanded(child: DatePicker(label: 'Resident since', controller: residentSince)),
                        ],
                      ),
                      // TextFormField(
                      //   controller: purokNumber,
                      //   validator: validate,
                      //   decoration: InputDecoration(
                      //     labelText: 'Purok no.',
                      //     border: outlineInputBorder(context),
                      //     enabledBorder: outlineInputBorder(context),
                      //   ),
                      // ),
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
              child: DefaultTabController(
                length: 2,
                child: Column(
                  children: [
                    TabBar(
                      tabs: [
                        Tab(text: resident.firstValidId.type),
                        Tab(text: resident.secondValidId.type),
                      ],
                    ),
                    Expanded(
                      child: TabBarView(
                        children: [
                          InteractiveViewer(child: Image.network(resident.firstValidId.path)),
                          InteractiveViewer(child: Image.network(resident.secondValidId.path)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      actions: !isAdmin
          ? null
          : [
              FilledButton.icon(
                onPressed: () async {
                  String? result = await showDialog<String>(
                    context: context,
                    builder: (context) => ReasonForDeclineDialog(),
                  );

                  if (result == null) return;
                  if (result.isEmpty) return;

                  resident.status = 'Declined';
                  resident.reasonForDecline = result;
                  if (context.mounted) submit(context);
                },
                style: const ButtonStyle(backgroundColor: WidgetStatePropertyAll(Colors.red)),
                icon: const Icon(TablerIcons.rosette_discount_check_off),
                label: const Text('DECLINE'),
              ),
              FilledButton.icon(
                onPressed: () {
                  resident.status = 'Approved';
                  submit(context);
                },
                style: const ButtonStyle(backgroundColor: WidgetStatePropertyAll(Colors.green)),
                icon: const Icon(TablerIcons.rosette_discount_check),
                label: const Text('APPROVE'),
              ),
            ],
    );
  }
}
