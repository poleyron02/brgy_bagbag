import 'package:brgy_bagbag/db_helper.dart';
import 'package:brgy_bagbag/functions.dart';
import 'package:brgy_bagbag/globals.dart';
import 'package:brgy_bagbag/models/forms/business_clearance.dart';
import 'package:brgy_bagbag/models/notification_link.dart';
import 'package:brgy_bagbag/models/notification_message.dart';
import 'package:brgy_bagbag/models/request.dart';
import 'package:brgy_bagbag/models/resident.dart';
import 'package:brgy_bagbag/models/valid_id.dart';
import 'package:brgy_bagbag/resident/widgets/are_you_sure_dialog.dart';
import 'package:brgy_bagbag/storage_helper.dart';
import 'package:brgy_bagbag/widgets/column_separated.dart';
import 'package:brgy_bagbag/widgets/file_picker_form_field.dart';
import 'package:brgy_bagbag/widgets/row_separated.dart';
import 'package:brgy_bagbag/widgets/show_image_list_tile.dart';
import 'package:brgy_bagbag/widgets/valid_id_file_picker_list_tile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

class BusinessClearanceDialog extends StatefulWidget {
  const BusinessClearanceDialog({
    super.key,
    this.resident,
    this.id,
    this.uid,
    this.requestId,
    this.isAdmin = false,
    this.isDone = false,
    this.onCancel,
    this.onPrint,
    this.request,
    this.isPrinted = false,
  });

  final String? id;
  final String? uid;
  final String? requestId;
  final Resident? resident;
  final bool isAdmin;
  final bool isDone;
  final Future<void> Function()? onCancel;
  final Future<void> Function()? onPrint;
  final Request? request;
  final bool isPrinted;

  @override
  State<BusinessClearanceDialog> createState() => _BusinessClearanceDialogState();
}

class _BusinessClearanceDialogState extends State<BusinessClearanceDialog> {
  late Future<bool> future;

  final GlobalKey<FormState> formKey = GlobalKey();

  late TextEditingController ownerFirstName = TextEditingController(text: widget.resident?.firstName);
  late TextEditingController ownerMiddleName = TextEditingController(text: widget.resident?.middleName);
  late TextEditingController ownerLastName = TextEditingController(text: widget.resident?.lastName);
  late TextEditingController ownerAddress = TextEditingController(text: widget.resident?.address);
  final TextEditingController businessName = TextEditingController();
  final TextEditingController businessAddress = TextEditingController();
  final TextEditingController businessType = TextEditingController();
  final TextEditingController contactNumber = TextEditingController();
  final TextEditingController property = TextEditingController();
  final TextEditingController dtiSecRegNumber = TextEditingController();
  final TextEditingController twoByTwoPicture = TextEditingController();
  final TextEditingController firstGovernmentIdType = TextEditingController();
  final TextEditingController firstGovernmentIdPath = TextEditingController();
  final TextEditingController secondGovernmentIdType = TextEditingController();
  final TextEditingController secondGovernmentIdPath = TextEditingController();

  final ValueNotifier<bool> isLoading = ValueNotifier(false);

  Future<bool> load() async {
    if (widget.id == null) return false;
    var doc = await businessClearancesCollection.doc(widget.id).get();
    if (!doc.exists) return false;

    var businessClearance = doc.data()!;

    ownerFirstName.text = businessClearance.ownerFirstName;
    ownerMiddleName.text = businessClearance.ownerMiddleName;
    ownerLastName.text = businessClearance.ownerLastName;
    ownerAddress.text = businessClearance.ownerAddress;
    businessName.text = businessClearance.businessName;
    businessAddress.text = businessClearance.businessAddress;
    businessType.text = businessClearance.businessType;
    contactNumber.text = businessClearance.contactNumber;
    property.text = businessClearance.property;
    dtiSecRegNumber.text = businessClearance.dtiSecRegNumber;
    twoByTwoPicture.text = businessClearance.twoByTwoPicture;
    firstGovernmentIdType.text = businessClearance.firstGovernmentId.type;
    firstGovernmentIdPath.text = businessClearance.firstGovernmentId.path;
    secondGovernmentIdType.text = businessClearance.secondGovernmentId.type;
    secondGovernmentIdPath.text = businessClearance.secondGovernmentId.path;

    return true;
  }

  void submit(BuildContext context) async {
    bool? sure = await showDialog(
      context: context,
      builder: (context) => const AreYouSureDialog(),
    );

    if (sure == null) return;
    if (!sure) return;

    if (!formKey.currentState!.validate()) return;
    if (isLoading.value) return;
    isLoading.value = true;

    DocumentReference<BusinessClearance> doc = businessClearancesCollection.doc();

    BusinessClearance businessClearance = BusinessClearance(
      id: doc.id,
      uid: widget.resident?.id ?? '',
      ownerFirstName: ownerFirstName.text,
      ownerMiddleName: ownerMiddleName.text,
      ownerLastName: ownerLastName.text,
      ownerAddress: ownerAddress.text,
      businessName: businessName.text,
      businessAddress: businessAddress.text,
      businessType: businessType.text,
      contactNumber: contactNumber.text,
      property: property.text,
      dtiSecRegNumber: dtiSecRegNumber.text,
      twoByTwoPicture: twoByTwoPicture.text,
      firstGovernmentId: ValidId(type: firstGovernmentIdType.text, path: firstGovernmentIdPath.text),
      secondGovernmentId: ValidId(type: secondGovernmentIdType.text, path: secondGovernmentIdPath.text),
      createdAt: Timestamp.now(),
      updatedAt: Timestamp.now(),
    );

    await setBusinessClearance(businessClearance, doc: doc);

    isLoading.value = false;
    if (context.mounted) Navigator.pop(context);
    if (context.mounted) showSnackBar(context, 'Successfully submitted business clearance form.');
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
          icon: const Icon(TablerIcons.building),
          title: const Text('Business Clearance Form'),
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
                              child: Text('Owner\'s Information'),
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
                                controller: ownerFirstName,
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
                                controller: ownerMiddleName,
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
                          controller: ownerLastName,
                          validator: validate,
                          decoration: InputDecoration(
                            labelText: 'Last name',
                            border: outlineInputBorder(context),
                            enabledBorder: outlineInputBorder(context),
                          ),
                        ),
                        TextFormField(
                          readOnly: widget.id != null,
                          controller: ownerAddress,
                          validator: validate,
                          decoration: InputDecoration(
                            labelText: 'Address',
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
                              child: Text('Business\' Information'),
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
                          controller: businessName,
                          validator: validate,
                          decoration: InputDecoration(
                            labelText: 'Name',
                            border: outlineInputBorder(context),
                            enabledBorder: outlineInputBorder(context),
                          ),
                        ),
                        TextFormField(
                          readOnly: widget.id != null,
                          controller: businessAddress,
                          validator: validate,
                          decoration: InputDecoration(
                            labelText: 'Business Address',
                            border: outlineInputBorder(context),
                            enabledBorder: outlineInputBorder(context),
                          ),
                        ),
                        TextFormField(
                          readOnly: widget.id != null,
                          controller: businessType,
                          validator: validate,
                          decoration: InputDecoration(
                            labelText: 'Type',
                            border: outlineInputBorder(context),
                            enabledBorder: outlineInputBorder(context),
                          ),
                        ),
                        TextFormField(
                          readOnly: widget.id != null,
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
                            labelText: 'Business Contact Number',
                            border: outlineInputBorder(context),
                            enabledBorder: outlineInputBorder(context),
                          ),
                        ),
                        TextFormField(
                          readOnly: widget.id != null,
                          controller: property,
                          validator: validate,
                          decoration: InputDecoration(
                            labelText: 'Property',
                            border: outlineInputBorder(context),
                            enabledBorder: outlineInputBorder(context),
                          ),
                        ),
                        TextFormField(
                          readOnly: widget.id != null,
                          controller: dtiSecRegNumber,
                          validator: validate,
                          decoration: InputDecoration(
                            labelText: 'DTI/SEC Reg No.',
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
                  TextButton.icon(
                    onPressed: () async {
                      if (widget.isPrinted) {
                        bool? result = await showDialog(context: context, builder: (context) => const AreYouSureDialog());
                        if (result != null && !result) return;
                      }

                      printCertificate(
                        fileName: 'barangay_business_clearance_${widget.id}',
                        title: 'BARANGAY BUSINESS CLEARANCE',
                        content: 'To whom it may concern:\n\n#This is to certify that Mr./ Ms./ Mrs. * ${ownerFirstName.text.toUpperCase()} ${ownerMiddleName.text[0].toUpperCase()} ${ownerLastName.text.toUpperCase()}* (Operator / Owner) of *${businessName.text.toUpperCase()}* with the office address at *${businessAddress.text.toUpperCase()}* is hereby permitted to continue his business subject to the rules and regulation provided for under the existing ordinances, rules, and regulation being enforced in the Barangay.\n\n#This certify further that he / she is known to be a person of good moral character, law abiding citizen and has not been involved nor convicted in any crime.\n\n#Issued this *${Timestamp.now().format().toUpperCase()}* at *BAGBAG QUEZON CITY, METRO MANILA*.',
                        persons: personPositions,
                      );

                      if (context.mounted) Navigator.pop(context);

                      if (widget.onPrint != null) widget.onPrint!();
                    },
                    icon: const Icon(TablerIcons.printer),
                    label: Text(widget.isPrinted ? 'PRINT AGAIN' : 'PRINT'),
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

                                  isLoading.value = true;

                                  DocumentReference<NotificationMessage> doc = notificationsCollection.doc();

                                  NotificationMessage notification = NotificationMessage(
                                    id: doc.id,
                                    fromUid: 'admin',
                                    toUid: widget.uid!,
                                    title: 'Declined request for Barangay Business Clearance',
                                    content: 'Your request for the barangay business clearance was declined. Make sure the details provided are as follows, if you have any questions, feel free to contact the administrators.',
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
                      builder: (context, isLoadingValue, child) {
                        return TextButton.icon(
                          onPressed: () async {
                            bool? sure = await showDialog(
                              context: context,
                              builder: (context) => const AreYouSureDialog(),
                            );

                            if (sure == null) return;
                            if (!sure) return;

                            if (isLoadingValue) return;
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

                            String name = 'barangay_business_clearance_${widget.id}.pdf';

                            Uint8List bytes = await createCertificate(
                              title: 'BARANGAY BUSINESS CLEARANCE',
                              content: 'To whom it may concern:\n\n#This is to certify that Mr./ Ms./ Mrs. * ${ownerFirstName.text.toUpperCase()} ${ownerMiddleName.text[0].toUpperCase()} ${ownerLastName.text.toUpperCase()}* (Operator / Owner) of *${businessName.text.toUpperCase()}* with the office address at *${businessAddress.text.toUpperCase()}* is hereby permitted to continue his business subject to the rules and regulation provided for under the existing ordinances, rules, and regulation being enforced in the Barangay.\n\n#This certify further that he / she is known to be a person of good moral character, law abiding citizen and has not been involved nor convicted in any crime.\n\n#Issued this *${Timestamp.now().format().toUpperCase()}* at *BAGBAG QUEZON CITY, METRO MANILA*.',
                              persons: personPositions,
                            );

                            await setFile(ref: 'documents', name: name, bytes: bytes);

                            String url = await getDownloadUrl(ref: 'documents', name: name);

                            DocumentReference<NotificationMessage> doc = notificationsCollection.doc();

                            NotificationMessage notification = NotificationMessage(
                              id: doc.id,
                              fromUid: 'admin',
                              toUid: widget.uid!,
                              title: 'Approved request for Barangay Business Clearance',
                              content: 'Your request for the barangay business clearance has been approved, see the attached link below for the PDF file.',
                              links: [
                                NotificationLink(name: name, url: url)
                              ],
                              createdAt: Timestamp.now(),
                              updatedAt: Timestamp.now(),
                            );

                            await setNotification(notification);
                            await setRequestStatus(widget.requestId!, 'Approved');

                            isLoading.value = false;

                            if (context.mounted) Navigator.pop(context);
                            if (context.mounted) showSnackBar(context, 'Notification sent.');
                          },
                          icon: isLoadingValue ? const SizedBox.square(dimension: 16, child: CircularProgressIndicator()) : const Icon(TablerIcons.check),
                          label: const Text('APPROVE'),
                        );
                      },
                    ),
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

class ORReferenceNumberDialog extends StatelessWidget {
  ORReferenceNumberDialog({
    super.key,
  });

  final GlobalKey<FormState> formKey = GlobalKey();
  final TextEditingController text = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      icon: const Icon(TablerIcons.hash),
      title: const Text('OR Reference Number'),
      content: SizedBox(
        width: 500,
        child: Form(
          key: formKey,
          child: TextFormField(
            controller: text,
            validator: validate,
            decoration: InputDecoration(
              border: outlineInputBorder(context),
            ),
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCEL')),
        FilledButton(
          onPressed: () {
            if (!formKey.currentState!.validate()) return;
            Navigator.pop(context, text.text);
          },
          child: const Text('CONFIRM'),
        ),
      ],
    );
  }
}
