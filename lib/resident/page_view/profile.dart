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

class ResidentProfilePageView extends StatelessWidget {
  ResidentProfilePageView({
    super.key,
    required this.resident,
    this.drawer,
    this.isPortrait = false,
  });

  final Resident resident;

  final Widget? drawer;
  final bool isPortrait;

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
  late TextEditingController barangay = TextEditingController(text: resident.barangay);
  late TextEditingController city = TextEditingController(text: resident.city);
  late TextEditingController placeOfBirth = TextEditingController(text: resident.placeOfBirth);
  late TextEditingController occupation = TextEditingController(text: resident.occupation);
  late ValueNotifier<bool> isVoter = ValueNotifier(resident.isVoter);
  late ValueNotifier<bool> isMarried = ValueNotifier(resident.isMarried);
  // late TextEditingController purokNumber = TextEditingController(text: resident.purokNumber);
  // late TextEditingController purokNumber = TextEditingController(text: '_');
  late TextEditingController residentSince = TextEditingController(text: resident.residentSince);
  late TextEditingController residentType = TextEditingController(text: resident.residentType);

  final ValueNotifier<bool> loading = ValueNotifier(false);

  void submit(BuildContext context) async {
    if (!formKey.currentState!.validate()) return;

    if (loading.value) return;
    loading.value = true;

    Resident resident = Resident(
      id: this.resident.id,
      status: this.resident.status,
      reasonForDecline: this.resident.reasonForDecline,
      userId: this.resident.userId,
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
      isMarried: isMarried.value,
      // purokNumber: purokNumber.text,
      residentSince: residentSince.text,
      residentType: residentType.text,
      firstValidId: this.resident.firstValidId,
      secondValidId: this.resident.secondValidId,
      createdAt: this.resident.createdAt,
      updatedAt: Timestamp.now(),
    );

    DocumentReference<Resident> doc = residentsCollection.doc(this.resident.id);

    await setResident(resident, doc: doc);

    loading.value = false;

    if (context.mounted) showSnackBar(context, 'Successfully updated profile.');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(child: drawer),
      appBar: AppBar(
        leading: isPortrait ? null : const Icon(TablerIcons.user),
        title: const Text('Profile'),
        actions: [
          ValueListenableBuilder(
            valueListenable: loading,
            builder: (context, value, child) => TextButton.icon(
              onPressed: value ? null : () => submit(context),
              icon: const Icon(TablerIcons.send),
              label: const Text('UPDATE'),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: formKey,
            child: ColumnSeparated(
              spacing: 16,
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  enabled: false,
                  controller: firstName,
                  validator: validate,
                  decoration: InputDecoration(
                    labelText: 'First name',
                    border: outlineInputBorder(context),
                    enabledBorder: outlineInputBorder(context),
                  ),
                ),
                TextFormField(
                  enabled: false,
                  controller: middleName,
                  validator: validate,
                  decoration: InputDecoration(
                    labelText: 'Middle name',
                    border: outlineInputBorder(context),
                    enabledBorder: outlineInputBorder(context),
                  ),
                ),
                ValueListenableBuilder(
                  valueListenable: isMarried,
                  builder: (context, value, child) => Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          enabled: value,
                          controller: lastName,
                          validator: validate,
                          decoration: InputDecoration(
                            labelText: 'Last name',
                            border: outlineInputBorder(context),
                            enabledBorder: outlineInputBorder(context),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 200,
                        child: CheckboxListTile(
                          value: value,
                          title: const Text('Married'),
                          onChanged: (value) {
                            isMarried.value = value!;
                          },
                        ),
                      )
                    ],
                  ),
                ),
                DropdownFormField(
                  enabled: false,
                  controller: suffix,
                  label: 'Suffix',
                  values: nameSuffixes,
                ),
                DropdownFormField(
                  enabled: false,
                  controller: gender,
                  label: 'Gender',
                  values: genders,
                ),
                DatePicker(
                  enabled: false,
                  label: 'Birthday',
                  controller: birthday,
                ),
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
                //   enabled: false,
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
                  enabled: false,
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
                IsVoterListTile(
                  enabled: false,
                  isVoter: isVoter,
                ),
                // TextFormField(
                //   enabled: false,
                //   controller: purokNumber,
                //   validator: validate,
                //   decoration: InputDecoration(
                //     labelText: 'Purok No.',
                //     border: outlineInputBorder(context),
                //     enabledBorder: outlineInputBorder(context),
                //   ),
                // ),
                TextFormField(
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
                // DatePicker(
                //   enabled: false,
                //   label: 'Resident since',
                //   controller: residentSince,
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
