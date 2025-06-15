import 'package:brgy_bagbag/db_helper.dart';
import 'package:brgy_bagbag/functions.dart';
import 'package:brgy_bagbag/globals.dart';
import 'package:brgy_bagbag/models/custom_notifier.dart';
import 'package:brgy_bagbag/models/resident.dart';
import 'package:brgy_bagbag/models/valid_id.dart';
import 'package:brgy_bagbag/resident/widgets/terms_and_conditions_dialog.dart';
// import 'package:brgy_bagbag/resident/widgets/email_verification_dialog.dart';
import 'package:brgy_bagbag/widgets/column_separated.dart';
import 'package:brgy_bagbag/widgets/date_picker.dart';
import 'package:brgy_bagbag/widgets/dropdown_form_field.dart';
import 'package:brgy_bagbag/widgets/valid_id_file_picker_list_tile.dart';
import 'package:brgy_bagbag/widgets/row_separated.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

class ResidentRegisterPage extends StatelessWidget {
  ResidentRegisterPage({super.key});

  final ValueNotifier<int> currentStep = ValueNotifier(0);

  final GlobalKey<FormState> credentialsFormKey = GlobalKey();
  final GlobalKey<FormState> basicInformationFormKey = GlobalKey();
  final GlobalKey<FormState> residencyFormKey = GlobalKey();
  final GlobalKey<FormState> validIdFormKey = GlobalKey();

  final TextEditingController email = TextEditingController();
  final TextEditingController password = TextEditingController();
  final TextEditingController confirmPassword = TextEditingController();

  final TextEditingController firstName = TextEditingController();
  final TextEditingController middleName = TextEditingController();
  final TextEditingController lastName = TextEditingController();
  final TextEditingController suffix = TextEditingController();
  final TextEditingController gender = TextEditingController();
  final TextEditingController civilStatus = TextEditingController();
  // final TextEditingController address = TextEditingController();
  final TextEditingController street = TextEditingController();
  final TextEditingController barangay = TextEditingController(text: 'Bagbag');
  final TextEditingController city = TextEditingController(text: 'Quezon City');
  final TextEditingController contactNumber = TextEditingController();
  final CustomNotifier<DateTime> birthday = CustomNotifier(null);
  final TextEditingController placeOfBirth = TextEditingController();
  final TextEditingController occupation = TextEditingController();

  final ValueNotifier<bool> isVoter = ValueNotifier(false);
  // final TextEditingController purokNumber = TextEditingController();
  final TextEditingController residentSince = TextEditingController();
  final TextEditingController residentType = TextEditingController();

  final TextEditingController idNo = TextEditingController();
  final TextEditingController firstValidIdType = TextEditingController();
  final TextEditingController firstValidIdPath = TextEditingController();
  final TextEditingController secondValidIdType = TextEditingController();
  final TextEditingController secondValidIdPath = TextEditingController();

  final ValueNotifier<bool> isSubmit = ValueNotifier(false);
  final ValueNotifier<bool> agree = ValueNotifier(true);
  final ValueNotifier<bool> obscurePassword = ValueNotifier(true);
  final ValueNotifier<bool> obscureConfirmPassword = ValueNotifier(true);

  bool isValidEmail(String email) {
    // Regular expression for validating an email address
    String pattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
    RegExp regex = RegExp(pattern);
    return regex.hasMatch(email);
  }

  String? validateEmail(String? value) {
    String? firstCheck = validate(value);
    if (firstCheck != null) return firstCheck;

    if (!isValidEmail(value!)) return 'Invalid Email';

    return null;
  }

  String? validatePassword(String? value) {
    // Check if the basic validation fails
    String? firstCheck = validate(value);
    if (firstCheck != null) return firstCheck;

    // Ensure password meets strength criteria
    if (value!.length < 8) return 'Password must be at least 8 characters long';
    if (!RegExp(r'[A-Z]').hasMatch(value)) return 'Password must contain at least one uppercase letter';
    if (!RegExp(r'[a-z]').hasMatch(value)) return 'Password must contain at least one lowercase letter';
    if (!RegExp(r'[0-9]').hasMatch(value)) return 'Password must contain at least one number';
    if (!RegExp(r'[!@#\$&*~]').hasMatch(value)) return 'Password must contain at least one special character';

    // Check if passwords match
    if (password.text != value) return 'Password does not match';

    return null; // All checks passed, return null indicating the password is valid
  }

  String? validateConfirmPassword(String? value) {
    // Check if the basic validation fails
    String? firstCheck = validate(value);
    if (firstCheck != null) return firstCheck;

    // Check if passwords match
    if (password.text != value) return 'Password does not match';

    return null; // All checks passed, return null indicating the password is valid
  }

  void submit(BuildContext context) async {
    if (isSubmit.value) return;
    isSubmit.value = true;

    try {
      final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email.text,
        password: password.text,
      );

      DocumentReference<Resident> doc = residentsCollection.doc(credential.user!.uid);

      Resident resident = Resident(
        id: doc.id,
        userId: doc.id,
        firstName: firstName.text,
        middleName: middleName.text,
        lastName: lastName.text,
        suffix: suffix.text,
        gender: gender.text,
        civilStatus: civilStatus.text,
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
        firstValidId: ValidId(idNo: idNo.text, type: firstValidIdType.text, path: firstValidIdPath.text),
        secondValidId: ValidId(idNo: idNo.text, type: firstValidIdType.text, path: secondValidIdPath.text),
        createdAt: Timestamp.now(),
        updatedAt: Timestamp.now(),
      );

      await setResident(resident, doc: doc);

      if (context.mounted) sendEmailVerification(context, credential.user!);
    } catch (e) {
      SnackBar snackBar = SnackBar(content: Text('$e'));
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } finally {
      isSubmit.value = false;
      if (context.mounted) Navigator.pop(context);
      if (context.mounted) Navigator.pop(context);
      // if (context.mounted) showDialog(context: context, builder: (context) => const EmailVerificationDialog());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: RowSeparated(
          spacing: 16,
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox.square(dimension: 50, child: Image.asset('images/logo.png')),
            const Text('Resident Registration'),
          ],
        ),
      ),
      body: ValueListenableBuilder(
        valueListenable: currentStep,
        builder: (context, currentStepValue, child) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Stepper(
                currentStep: currentStepValue,
                onStepCancel: currentStepValue <= 0
                    ? null
                    : () {
                        currentStep.value = --currentStepValue;
                      },
                onStepContinue: () {
                  switch (currentStepValue) {
                    case 0:
                      if (!credentialsFormKey.currentState!.validate()) return;
                      break;
                    case 1:
                      if (!basicInformationFormKey.currentState!.validate()) return;
                      break;
                    case 2:
                      if (!residencyFormKey.currentState!.validate()) return;
                      break;
                    case 3:
                      if (!validIdFormKey.currentState!.validate()) return;
                      submit(context);
                      return;
                    default:
                  }
                  currentStep.value = ++currentStepValue;
                },
                controlsBuilder: (context, details) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: ColumnSeparated(
                      spacing: 16,
                      mainAxisSize: MainAxisSize.min,
                      // crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextButton.icon(
                          onPressed: details.onStepCancel,
                          icon: const Icon(TablerIcons.chevron_up),
                          label: const Text('BACK'),
                          style: const ButtonStyle(padding: WidgetStatePropertyAll(EdgeInsets.all(16))),
                        ),
                        ValueListenableBuilder(
                          valueListenable: isSubmit,
                          builder: (context, isSubmitValue, child) {
                            return ValueListenableBuilder(
                              valueListenable: agree,
                              builder: (context, agreeValue, child) {
                                return FilledButton.icon(
                                  onPressed: isSubmitValue
                                      ? null
                                      : details.currentStep == 3 && !agreeValue
                                          ? null
                                          : details.onStepContinue,
                                  icon: Icon(details.currentStep == 3 ? TablerIcons.check : TablerIcons.chevron_down),
                                  label: Text(
                                    details.currentStep == 3 ? 'SUBMIT' : 'CONTINUE',
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  style: const ButtonStyle(padding: WidgetStatePropertyAll(EdgeInsets.all(16))),
                                );
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  );
                },
                steps: [
                  Step(
                    state: currentStepValue > 0 ? StepState.complete : StepState.indexed,
                    title: const Text('Credentials'),
                    content: Form(
                      key: credentialsFormKey,
                      child: ColumnSeparated(
                        spacing: 16,
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextFormField(
                            controller: email,
                            validator: validateEmail,
                            decoration: InputDecoration(
                              labelText: 'Email',
                              prefixIcon: const Icon(TablerIcons.mail),
                              border: outlineInputBorder(context),
                              enabledBorder: outlineInputBorder(context),
                            ),
                          ),
                          ValueListenableBuilder(
                            valueListenable: obscurePassword,
                            builder: (context, value, child) {
                              return TextFormField(
                                controller: password,
                                validator: validatePassword,
                                autovalidateMode: AutovalidateMode.always,
                                obscureText: value,
                                decoration: InputDecoration(
                                  prefixIcon: const Icon(TablerIcons.lock_password),
                                  labelText: 'Password',
                                  border: outlineInputBorder(context),
                                  enabledBorder: outlineInputBorder(context),
                                  suffixIcon: GestureDetector(
                                    onTap: () => obscurePassword.value = !obscurePassword.value,
                                    child: Icon(value ? TablerIcons.eye : TablerIcons.eye_filled),
                                  ),
                                ),
                              );
                            },
                          ),
                          ValueListenableBuilder(
                            valueListenable: obscureConfirmPassword,
                            builder: (context, value, child) {
                              return TextFormField(
                                controller: confirmPassword,
                                validator: validateConfirmPassword,
                                autovalidateMode: AutovalidateMode.always,
                                obscureText: value,
                                decoration: InputDecoration(
                                  labelText: 'Confirm Password',
                                  prefixIcon: const Icon(TablerIcons.lock_password),
                                  border: outlineInputBorder(context),
                                  enabledBorder: outlineInputBorder(context),
                                  suffixIcon: GestureDetector(
                                    onTap: () => obscureConfirmPassword.value = !obscureConfirmPassword.value,
                                    child: Icon(value ? TablerIcons.eye : TablerIcons.eye_filled),
                                  ),
                                ),
                              );
                            },
                          ),
                          ValueListenableBuilder(
                            valueListenable: password,
                            builder: (context, value, child) {
                              return ColumnSeparated(
                                spacing: 2,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  PasswordMatchText(
                                    isMatch: value.text.length > 8,
                                    label: 'Password must be at least 8 characters long',
                                  ),
                                  PasswordMatchText(
                                    isMatch: RegExp(r'[A-Z]').hasMatch(value.text),
                                    label: 'Password must contain at least one uppercase letter',
                                  ),
                                  PasswordMatchText(
                                    isMatch: RegExp(r'[a-z]').hasMatch(value.text),
                                    label: 'Password must contain at least one lowercase letter',
                                  ),
                                  PasswordMatchText(
                                    isMatch: RegExp(r'[0-9]').hasMatch(value.text),
                                    label: 'Password must contain at least one number',
                                  ),
                                  PasswordMatchText(
                                    isMatch: RegExp(r'[!@#\$&*~]').hasMatch(value.text),
                                    label: 'Password must contain at least one special character',
                                  ),
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  Step(
                    state: currentStepValue > 1 ? StepState.complete : StepState.indexed,
                    title: const Text('Basic Information'),
                    content: Form(
                      key: basicInformationFormKey,
                      child: ColumnSeparated(
                        spacing: 16,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextFormField(
                            controller: firstName,
                            validator: validate,
                            decoration: InputDecoration(
                              labelText: 'First name',
                              border: outlineInputBorder(context),
                              enabledBorder: outlineInputBorder(context),
                            ),
                          ),
                          TextFormField(
                            controller: middleName,
                            // validator: validate,
                            decoration: InputDecoration(
                              labelText: 'Middle name (Optional)',
                              border: outlineInputBorder(context),
                              enabledBorder: outlineInputBorder(context),
                            ),
                          ),
                          TextFormField(
                            controller: lastName,
                            validator: validate,
                            decoration: InputDecoration(
                              labelText: 'Last name',
                              border: outlineInputBorder(context),
                              enabledBorder: outlineInputBorder(context),
                            ),
                          ),
                          DropdownFormField(controller: suffix, label: 'Suffix', values: nameSuffixes),
                          DropdownFormField(
                            controller: gender,
                            label: 'Gender',
                            values: genders,
                            prefixIcon: const Icon(TablerIcons.gender_bigender),
                          ),
                          DropdownFormField(
                            controller: civilStatus,
                            label: 'Civil Status',
                            values: civilStatuses,
                            // prefixIcon: const Icon(TablerIcons.gender_bigender),
                          ),
                          DatePicker(label: 'Birthday', controller: birthday),
                          // const RowSeparated(
                          //   spacing: 16,
                          //   children: [],
                          // ),
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
                              labelText: 'Contact number',
                              prefixIcon: const Icon(TablerIcons.phone),
                              border: outlineInputBorder(context),
                              enabledBorder: outlineInputBorder(context),
                            ),
                          ),
                          RowSeparated(
                            spacing: 8,
                            children: [
                              Expanded(
                                child: Autocomplete<String>(
                                  initialValue: street.value,
                                  onSelected: (option) {
                                    street.text = option;
                                  },
                                  optionsBuilder: (textEditingValue) {
                                    return bagbagStreets.where(
                                      (element) => element.toLowerCase().contains(textEditingValue.text.toLowerCase()),
                                    );
                                  },
                                  fieldViewBuilder: (context, textEditingController, focusNode, onFieldSubmitted) => TextFormField(
                                    controller: textEditingController,
                                    focusNode: focusNode,
                                    // onFieldSubmitted: onFieldSubmitted,
                                    validator: validate,
                                    decoration: InputDecoration(
                                      labelText: 'Street',
                                      // prefixIcon: const Icon(TablerIcons.address_book),
                                      border: outlineInputBorder(context),
                                      enabledBorder: outlineInputBorder(context),
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: TextFormField(
                                  controller: barangay,
                                  validator: validate,
                                  decoration: InputDecoration(
                                    labelText: 'Barangay',
                                    // prefixIcon: const Icon(TablerIcons.address_book),
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
                                    // prefixIcon: const Icon(TablerIcons.address_book),
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
                              prefixIcon: const Icon(TablerIcons.address_book),
                              border: outlineInputBorder(context),
                              enabledBorder: outlineInputBorder(context),
                            ),
                          ),
                          TextFormField(
                            controller: occupation,
                            validator: validate,
                            decoration: InputDecoration(
                              labelText: 'Occupation',
                              prefixIcon: const Icon(TablerIcons.briefcase),
                              border: outlineInputBorder(context),
                              enabledBorder: outlineInputBorder(context),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Step(
                    state: currentStepValue > 2 ? StepState.complete : StepState.indexed,
                    title: const Text('Residency'),
                    content: Form(
                      key: residencyFormKey,
                      child: ColumnSeparated(
                        spacing: 16,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IsVoterListTile(isVoter: isVoter),
                          // TextFormField(
                          //   controller: purokNumber,
                          //   validator: validate,
                          //   decoration: InputDecoration(
                          //     labelText: 'Purok No.',
                          //     prefixIcon: const Icon(TablerIcons.hash),
                          //     border: outlineInputBorder(context),
                          //     enabledBorder: outlineInputBorder(context),
                          //   ),
                          // ),
                          DropdownFormField(controller: residentType, label: 'Resident Type', values: residentTypes),
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
                          // DatePicker(label: 'Resident since', controller: residentSince),
                        ],
                      ),
                    ),
                  ),
                  Step(
                    state: currentStepValue > 3 ? StepState.complete : StepState.indexed,
                    title: const Text('Valid ID'),
                    content: Form(
                      key: validIdFormKey,
                      child: ColumnSeparated(
                        spacing: 8,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextFormField(
                            controller: idNo,
                            validator: validate,
                            decoration: InputDecoration(
                              labelText: 'ID No.',
                              prefixIcon: const Icon(TablerIcons.hash),
                              border: outlineInputBorder(context),
                              enabledBorder: outlineInputBorder(context),
                            ),
                          ),
                          ListTile(
                            leading: const Icon(TablerIcons.id),
                            title: const Text('ID Type'),
                            subtitle: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: ValueListenableBuilder(
                                valueListenable: firstValidIdType,
                                builder: (context, idTypeValue, child) {
                                  return FormField(
                                    validator: validate,
                                    initialValue: firstValidIdType.text,
                                    builder: (field) => Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        DropdownButton(
                                          isDense: true,
                                          isExpanded: true,
                                          hint: const Text('Choose ID Type'),
                                          underline: Container(),
                                          value: idTypeValue.text.isEmpty ? null : idTypeValue.text,
                                          onChanged: (value) {
                                            firstValidIdType.text = value!;
                                            field.didChange(value);
                                          },
                                          items: List.generate(
                                            validPhilippineIDs.length,
                                            (index) => DropdownMenuItem(
                                              value: validPhilippineIDs[index],
                                              child: Text(validPhilippineIDs[index]),
                                            ),
                                          ),
                                        ),
                                        if (field.hasError)
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(
                                              field.errorText ?? '',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Theme.of(context).colorScheme.error,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),

                          ValidIdFilePickerListTile(
                            label: 'Front ID',
                            path: firstValidIdPath,
                            // idType: firstValidIdType,
                          ),
                          ValidIdFilePickerListTile(
                            label: 'Back ID',
                            path: secondValidIdPath,
                            // idType: secondValidIdType,
                          ),
                          // ValueListenableBuilder(
                          //   valueListenable: agree,
                          //   builder: (context, value, child) {
                          //     return SwitchListTile(
                          //       value: value,
                          //       onChanged: (value) => agree.value = value,
                          //       title: GestureDetector(
                          //         child: const Text('Agree to Terms & Conditions'),
                          //         onTap: () {
                          //           showDialog(context: context, builder: (context) => const TermsAndConditionsDialog());
                          //         },
                          //       ),
                          //     );
                          //   },
                          // ),
                          // ValueListenableBuilder(
                          //   valueListenable: agree,
                          //   builder: (context, value, child) {
                          //     return CheckboxListTile(
                          //       value: value,
                          //       onChanged: (newValue) async {
                          //         // Show dialog before changing the checkbox state
                          //         bool? result = await showDialog(
                          //           context: context,
                          //           builder: (context) => const TermsAndConditionsDialog(),
                          //         );

                          //         // Update value only if the user agrees
                          //         if (result == true) {
                          //           agree.value = true;
                          //         } else if (result == false) {
                          //           agree.value = false;
                          //         }
                          //       },
                          //       title: const Text('Agree to Terms & Conditions'),
                          //     );
                          //   },
                          // ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class PasswordMatchText extends StatelessWidget {
  const PasswordMatchText({
    super.key,
    required this.isMatch,
    required this.label,
  });

  final bool isMatch;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(
          radius: 2,
          backgroundColor: isMatch ? Colors.green : Theme.of(context).colorScheme.onSurface,
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isMatch ? Colors.green : null,
          ),
        ),
      ],
    );
  }
}

class IsVoterListTile extends StatelessWidget {
  const IsVoterListTile({
    super.key,
    required this.isVoter,
    this.enabled = true,
  });

  final ValueNotifier<bool> isVoter;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: isVoter,
      builder: (context, value, child) => SwitchListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 8),
        secondary: const Icon(TablerIcons.fingerprint),
        value: value,
        title: const Text('Are you a Voter?'),
        subtitle: Text('${value ? 'Yes' : 'No'}, I am ${value ? '' : 'not '}a Voter.'),
        onChanged: !enabled ? null : (value) => isVoter.value = value,
      ),
    );
  }
}
