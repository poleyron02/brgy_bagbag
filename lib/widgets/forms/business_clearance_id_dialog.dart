import 'package:brgy_bagbag/db_helper.dart';
import 'package:brgy_bagbag/functions.dart';
import 'package:brgy_bagbag/globals.dart';
import 'package:brgy_bagbag/models/custom_notifier.dart';
import 'package:brgy_bagbag/models/forms/business_clearance_id.dart';
import 'package:brgy_bagbag/models/notification_message.dart';
import 'package:brgy_bagbag/models/request.dart';
import 'package:brgy_bagbag/models/resident.dart';
import 'package:brgy_bagbag/models/valid_id.dart';
import 'package:brgy_bagbag/resident/widgets/are_you_sure_dialog.dart';
import 'package:brgy_bagbag/widgets/column_separated.dart';
import 'package:brgy_bagbag/widgets/date_picker.dart';
import 'package:brgy_bagbag/widgets/dropdown_form_field.dart';
import 'package:brgy_bagbag/widgets/file_picker_form_field.dart';
import 'package:brgy_bagbag/widgets/forms/business_clearance_dialog.dart';
import 'package:brgy_bagbag/widgets/row_separated.dart';
import 'package:brgy_bagbag/widgets/show_image_list_tile.dart';
import 'package:brgy_bagbag/widgets/valid_id_file_picker_list_tile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

class BusinessClearanceIdDialog extends StatefulWidget {
  const BusinessClearanceIdDialog({
    super.key,
    this.resident,
    this.id,
    this.uid,
    this.requestId,
    this.isAdmin = false,
    this.isDone = false,
    this.onCancel,
    this.request,
  });

  final String? id;
  final String? uid;
  final String? requestId;
  final bool isAdmin;
  final bool isDone;
  final Resident? resident;
  final Request? request;
  final Future<void> Function()? onCancel;

  @override
  State<BusinessClearanceIdDialog> createState() => _BusinessClearanceIdDialogState();
}

class _BusinessClearanceIdDialogState extends State<BusinessClearanceIdDialog> {
  late Future<bool> future;

  final GlobalKey<FormState> formKey = GlobalKey();

  late TextEditingController firstName = TextEditingController(text: widget.resident?.firstName);
  late TextEditingController middleName = TextEditingController(text: widget.resident?.middleName);
  late TextEditingController lastName = TextEditingController(text: widget.resident?.lastName);
  late TextEditingController address = TextEditingController(text: widget.resident?.address);
  late CustomNotifier<DateTime> birthday = CustomNotifier(widget.resident?.birthday.toDate());
  late TextEditingController placeOfBirth = TextEditingController(text: widget.resident?.placeOfBirth);
  final TextEditingController precinctNumber = TextEditingController();
  final TextEditingController precinctAddress = TextEditingController();
  final TextEditingController precinctContactNumber = TextEditingController();
  late TextEditingController gender = TextEditingController(text: widget.resident?.gender);
  final TextEditingController civilStatus = TextEditingController();
  final TextEditingController purpose = TextEditingController();
  final TextEditingController height = TextEditingController();
  final TextEditingController weight = TextEditingController();
  final TextEditingController parentFirstName = TextEditingController();
  final TextEditingController parentMiddleName = TextEditingController();
  final TextEditingController parentLastName = TextEditingController();
  final TextEditingController parentAddress = TextEditingController();
  final TextEditingController parentContactNumber = TextEditingController();
  final TextEditingController parentRelationship = TextEditingController();
  final TextEditingController twoByTwoPicture = TextEditingController();
  final TextEditingController firstGovernmentIdType = TextEditingController();
  final TextEditingController firstGovernmentIdPath = TextEditingController();
  final TextEditingController secondGovernmentIdType = TextEditingController();
  final TextEditingController secondGovernmentIdPath = TextEditingController();

  final ValueNotifier<bool> isLoading = ValueNotifier(false);

  Future<bool> load() async {
    if (widget.id == null) return false;
    var doc = await businessClearanceIdCollection.doc(widget.id).get();
    if (!doc.exists) return false;

    var businessClearanceId = doc.data()!;

    firstName.text = businessClearanceId.firstName;
    middleName.text = businessClearanceId.middleName;
    lastName.text = businessClearanceId.lastName;
    address.text = businessClearanceId.address;
    birthday.set(businessClearanceId.birthday.toDate());
    placeOfBirth.text = businessClearanceId.placeOfBirth;
    precinctNumber.text = businessClearanceId.precinctNumber;
    precinctAddress.text = businessClearanceId.precinctAddress;
    precinctContactNumber.text = businessClearanceId.precinctContactNumber;
    gender.text = businessClearanceId.gender;
    civilStatus.text = businessClearanceId.civilStatus;
    purpose.text = businessClearanceId.purpose;
    height.text = businessClearanceId.height;
    weight.text = businessClearanceId.weight;
    parentFirstName.text = businessClearanceId.parentFirstName;
    parentMiddleName.text = businessClearanceId.parentMiddleName;
    parentLastName.text = businessClearanceId.parentLastName;
    parentAddress.text = businessClearanceId.parentAddress;
    parentContactNumber.text = businessClearanceId.parentContactNumber;
    parentRelationship.text = businessClearanceId.parentRelationship;
    twoByTwoPicture.text = businessClearanceId.twoByTwoPicture;
    firstGovernmentIdType.text = businessClearanceId.firstGovernmentId.type;
    firstGovernmentIdPath.text = businessClearanceId.firstGovernmentId.path;
    secondGovernmentIdType.text = businessClearanceId.secondGovernmentId.type;
    secondGovernmentIdPath.text = businessClearanceId.secondGovernmentId.path;

    return true;
  }

  void submit(BuildContext context) async {
    bool? sure = await showDialog(
      context: context,
      builder: (context) => const AreYouSureDialog(),
    );

    if (sure == null) return;
    if (!sure) return;

    if (isLoading.value) return;
    if (!formKey.currentState!.validate()) return;
    isLoading.value = true;

    DocumentReference<BusinessClearanceId> doc = businessClearanceIdCollection.doc();

    BusinessClearanceId businessClearanceId = BusinessClearanceId(
      id: doc.id,
      uid: widget.resident?.id ?? '',
      firstName: firstName.text,
      middleName: middleName.text,
      lastName: lastName.text,
      address: address.text,
      birthday: Timestamp.fromDate(birthday.value!),
      placeOfBirth: placeOfBirth.text,
      precinctNumber: precinctNumber.text,
      precinctAddress: precinctAddress.text,
      precinctContactNumber: precinctContactNumber.text,
      gender: gender.text,
      civilStatus: civilStatus.text,
      purpose: purpose.text,
      height: height.text,
      weight: weight.text,
      parentFirstName: parentFirstName.text,
      parentMiddleName: parentMiddleName.text,
      parentLastName: parentLastName.text,
      parentAddress: parentAddress.text,
      parentContactNumber: parentContactNumber.text,
      parentRelationship: parentRelationship.text,
      twoByTwoPicture: twoByTwoPicture.text,
      firstGovernmentId: ValidId(type: firstGovernmentIdType.text, path: firstGovernmentIdPath.text),
      secondGovernmentId: ValidId(type: secondGovernmentIdType.text, path: secondGovernmentIdPath.text),
      createdAt: Timestamp.now(),
      updatedAt: Timestamp.now(),
    );

    await setBusinessClearanceId(businessClearanceId, doc: doc);

    if (context.mounted) Navigator.pop(context);
    if (context.mounted) showSnackBar(context, 'Successfully submitted business clearance id form.');
    isLoading.value = false;
  }

  @override
  void initState() {
    super.initState();
    future = load();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: future,
      builder: (context, snapshot) {
        return AlertDialog(
          scrollable: true,
          insetPadding: const EdgeInsets.all(10),
          contentPadding: const EdgeInsets.all(16),
          icon: const Icon(TablerIcons.id_badge_2),
          title: const Text('Business Clearance ID Form'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (snapshot.connectionState == ConnectionState.waiting) const LinearProgressIndicator(),
              SingleChildScrollView(
                child: SizedBox(
                  width: 500,
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
                                readOnly: widget.id != null,
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
                                readOnly: widget.id != null,
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
                        TextFormField(
                          readOnly: widget.id != null,
                          controller: lastName,
                          validator: validate,
                          decoration: InputDecoration(
                            labelText: 'Last name',
                            border: outlineInputBorder(context),
                            enabledBorder: outlineInputBorder(context),
                          ),
                        ),
                        TextFormField(
                          readOnly: widget.id != null,
                          controller: address,
                          validator: validate,
                          decoration: InputDecoration(
                            labelText: 'Address',
                            border: outlineInputBorder(context),
                            enabledBorder: outlineInputBorder(context),
                          ),
                        ),
                        TextFormField(
                          readOnly: widget.id != null,
                          controller: placeOfBirth,
                          validator: validate,
                          decoration: InputDecoration(
                            labelText: 'Place of Birth',
                            border: outlineInputBorder(context),
                            enabledBorder: outlineInputBorder(context),
                          ),
                        ),
                        DropdownFormField(readOnly: widget.id != null, controller: gender, label: 'Gender', values: genders),
                        DropdownFormField(readOnly: widget.id != null, controller: civilStatus, label: 'Civil Status', values: civilStatuses),
                        DatePicker(readOnly: widget.id != null, label: 'Birthday', controller: birthday),
                        RowSeparated(
                          spacing: 16,
                          children: [
                            Expanded(
                              child: TextFormField(
                                readOnly: widget.id != null,
                                controller: height,
                                validator: validate,
                                decoration: InputDecoration(
                                  labelText: 'Height (cm)',
                                  border: outlineInputBorder(context),
                                  enabledBorder: outlineInputBorder(context),
                                ),
                              ),
                            ),
                            Expanded(
                              child: TextFormField(
                                readOnly: widget.id != null,
                                controller: weight,
                                validator: validate,
                                decoration: InputDecoration(
                                  labelText: 'Weight (kg)',
                                  border: outlineInputBorder(context),
                                  enabledBorder: outlineInputBorder(context),
                                ),
                              ),
                            ),
                          ],
                        ),
                        TextFormField(
                          readOnly: widget.id != null,
                          controller: purpose,
                          validator: validate,
                          minLines: 5,
                          maxLines: 10,
                          decoration: InputDecoration(
                            labelText: 'Purpose',
                            border: outlineInputBorder(context),
                            enabledBorder: outlineInputBorder(context),
                          ),
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: Divider(
                                height: 0,
                                color: Theme.of(context).colorScheme.secondaryContainer,
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 4, horizontal: 16),
                              child: Text('Voter\'s Precint Number Information'),
                            ),
                            Expanded(
                              child: Divider(
                                height: 0,
                                color: Theme.of(context).colorScheme.secondaryContainer,
                              ),
                            ),
                          ],
                        ),
                        TextFormField(
                          readOnly: widget.id != null,
                          controller: precinctNumber,
                          validator: validate,
                          decoration: InputDecoration(
                            labelText: 'Number',
                            hintText: '1234-A',
                            border: outlineInputBorder(context),
                            enabledBorder: outlineInputBorder(context),
                          ),
                        ),
                        TextFormField(
                          readOnly: widget.id != null,
                          controller: precinctAddress,
                          validator: validate,
                          decoration: InputDecoration(
                            labelText: 'Address',
                            border: outlineInputBorder(context),
                            enabledBorder: outlineInputBorder(context),
                          ),
                        ),
                        TextFormField(
                          readOnly: widget.id != null,
                          controller: precinctContactNumber,
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
                        Row(
                          children: [
                            Expanded(
                              child: Divider(
                                height: 0,
                                color: Theme.of(context).colorScheme.secondaryContainer,
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 4, horizontal: 16),
                              child: Text('Parent\'s Information'),
                            ),
                            Expanded(
                              child: Divider(
                                height: 0,
                                color: Theme.of(context).colorScheme.secondaryContainer,
                              ),
                            ),
                          ],
                        ),
                        RowSeparated(
                          spacing: 16,
                          children: [
                            Expanded(
                              child: TextFormField(
                                readOnly: widget.id != null,
                                controller: parentFirstName,
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
                                readOnly: widget.id != null,
                                controller: parentMiddleName,
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
                        TextFormField(
                          readOnly: widget.id != null,
                          controller: parentLastName,
                          validator: validate,
                          decoration: InputDecoration(
                            labelText: 'Last name',
                            border: outlineInputBorder(context),
                            enabledBorder: outlineInputBorder(context),
                          ),
                        ),
                        TextFormField(
                          readOnly: widget.id != null,
                          controller: parentAddress,
                          validator: validate,
                          decoration: InputDecoration(
                            labelText: 'Address',
                            border: outlineInputBorder(context),
                            enabledBorder: outlineInputBorder(context),
                          ),
                        ),
                        TextFormField(
                          readOnly: widget.id != null,
                          controller: parentContactNumber,
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
                        TextFormField(
                          readOnly: widget.id != null,
                          controller: parentRelationship,
                          validator: validate,
                          decoration: InputDecoration(
                            labelText: 'Relationship',
                            border: outlineInputBorder(context),
                            enabledBorder: outlineInputBorder(context),
                          ),
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: Divider(
                                height: 0,
                                color: Theme.of(context).colorScheme.secondaryContainer,
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 4, horizontal: 16),
                              child: Text('Documents'),
                            ),
                            Expanded(
                              child: Divider(
                                height: 0,
                                color: Theme.of(context).colorScheme.secondaryContainer,
                              ),
                            ),
                          ],
                        ),
                        if (widget.id == null)
                          FilePickerFormField(
                            leading: const Icon(TablerIcons.id_badge),
                            ref: 'two_by_two_picture',
                            label: '2x2 Picture',
                            controller: twoByTwoPicture,
                            type: FileType.image,
                          ),
                        if (widget.id == null) ValidIdFilePickerListTile(path: firstGovernmentIdPath),
                        if (widget.id == null) ValidIdFilePickerListTile(path: secondGovernmentIdPath),
                        if (widget.id != null) ShowImageListTile(icon: TablerIcons.id_badge, label: '2x2 Picture', url: twoByTwoPicture.text),
                        if (widget.id != null) ShowImageListTile(icon: TablerIcons.id, label: secondGovernmentIdType.text, url: firstGovernmentIdPath.text),
                        if (widget.id != null) ShowImageListTile(icon: TablerIcons.id, label: secondGovernmentIdType.text, url: secondGovernmentIdPath.text),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          actions: widget.isAdmin
              ? [
                  if (!widget.isDone)
                    ValueListenableBuilder(
                      valueListenable: isLoading,
                      builder: (context, value, child) {
                        return TextButton.icon(
                          onPressed: value
                              ? null
                              : () async {
                                  bool? sure = await showDialog(
                                    context: context,
                                    builder: (context) => const AreYouSureDialog(),
                                  );

                                  if (sure == null) return;
                                  if (!sure) return;

                                  if (isLoading.value) return;
                                  if (widget.uid == null) return;
                                  if (widget.requestId == null) return;

                                  isLoading.value = true;

                                  DocumentReference<NotificationMessage> doc = notificationsCollection.doc();

                                  NotificationMessage notification = NotificationMessage(
                                    id: doc.id,
                                    fromUid: 'admin',
                                    toUid: widget.uid!,
                                    title: 'Declined request for Business Clearance ID',
                                    content: 'Your request for business clearance ID was declined. Make sure the details provided are as follows, if you have any questions, feel free to contact the administrators.',
                                    links: [],
                                    createdAt: Timestamp.now(),
                                    updatedAt: Timestamp.now(),
                                  );

                                  await setNotification(notification);
                                  await setRequestStatus(widget.requestId!, 'Declined');

                                  isLoading.value = false;

                                  if (context.mounted) Navigator.pop(context);
                                  if (context.mounted) showSnackBar(context, 'Notification sent.');
                                },
                          icon: value ? const SizedBox.square(dimension: 16, child: CircularProgressIndicator()) : const Icon(TablerIcons.x),
                          label: const Text('DECLINE'),
                        );
                      },
                    ),
                  if (!widget.isDone)
                    ValueListenableBuilder(
                      valueListenable: isLoading,
                      builder: (context, value, child) {
                        return TextButton.icon(
                          onPressed: value
                              ? null
                              : () async {
                                  bool? sure = await showDialog(
                                    context: context,
                                    builder: (context) => const AreYouSureDialog(),
                                  );

                                  if (sure == null) return;
                                  if (!sure) return;

                                  if (isLoading.value) return;
                                  if (widget.uid == null) return;
                                  if (widget.requestId == null) return;

                                  if (widget.request != null && context.mounted) {
                                    String? result = await showDialog(
                                      context: context,
                                      builder: (context) => ORReferenceNumberDialog(),
                                    );
                                    if (result == null) return;
                                    if (result.isEmpty) return;
                                    widget.request!.orReferenceNumber = result;
                                    DocumentReference<Request> doc = requestsCollection.doc(widget.request!.id);
                                    await setRequest(widget.request!, doc: doc);
                                  }

                                  isLoading.value = true;

                                  DocumentReference<NotificationMessage> doc = notificationsCollection.doc();

                                  NotificationMessage notification = NotificationMessage(
                                    id: doc.id,
                                    fromUid: 'admin',
                                    toUid: widget.uid!,
                                    title: 'Approved request for Business Clearance ID',
                                    content: 'Your request for business clearance ID has been approved. Please wait for one of our administrators to contact you through your email, thank you for your patience.',
                                    links: [],
                                    createdAt: Timestamp.now(),
                                    updatedAt: Timestamp.now(),
                                  );

                                  await setNotification(notification);
                                  await setRequestStatus(widget.requestId!, 'Approved');

                                  isLoading.value = false;

                                  if (context.mounted) Navigator.pop(context);
                                  if (context.mounted) showSnackBar(context, 'Notification sent.');
                                },
                          icon: value ? const SizedBox.square(dimension: 16, child: CircularProgressIndicator()) : const Icon(TablerIcons.check),
                          label: const Text('APPROVE'),
                        );
                      },
                    )
                ]
              : widget.id != null
                  ? [
                      if (widget.onCancel != null)
                        TextButton(
                          onPressed: () async {
                            await widget.onCancel!();
                            if (context.mounted) Navigator.pop(context);
                          },
                          child: const Text('CANCEL REQUEST'),
                        ),
                    ]
                  : [
                      TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCEL')),
                      ValueListenableBuilder(
                        valueListenable: isLoading,
                        builder: (context, isLoadingValue, child) {
                          return FilledButton(
                            onPressed: isLoadingValue ? null : () => submit(context),
                            child: isLoadingValue ? const SizedBox.square(dimension: 16, child: CircularProgressIndicator()) : const Text('SEND'),
                          );
                        },
                      ),
                    ],
        );
      },
    );
  }
}
