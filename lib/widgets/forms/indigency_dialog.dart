import 'package:brgy_bagbag/db_helper.dart';
import 'package:brgy_bagbag/functions.dart';
import 'package:brgy_bagbag/globals.dart';
import 'package:brgy_bagbag/models/forms/indigency.dart';
import 'package:brgy_bagbag/models/notification_link.dart';
import 'package:brgy_bagbag/models/notification_message.dart';
import 'package:brgy_bagbag/models/request.dart';
import 'package:brgy_bagbag/models/resident.dart';
import 'package:brgy_bagbag/resident/widgets/are_you_sure_dialog.dart';
import 'package:brgy_bagbag/storage_helper.dart';
import 'package:brgy_bagbag/widgets/column_separated.dart';
import 'package:brgy_bagbag/widgets/forms/business_clearance_dialog.dart';
import 'package:brgy_bagbag/widgets/row_separated.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

class IndigencyDialog extends StatefulWidget {
  const IndigencyDialog({
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
  final Request? request;
  final bool isAdmin;
  final bool isDone;
  final Future<void> Function()? onCancel;
  final Future<void> Function()? onPrint;
  final bool isPrinted;

  @override
  State<IndigencyDialog> createState() => _IndigencyDialogState();
}

class _IndigencyDialogState extends State<IndigencyDialog> {
  late Future<void> future;

  final GlobalKey<FormState> formKey = GlobalKey();

  late TextEditingController firstName = TextEditingController(text: widget.resident?.firstName);
  late TextEditingController middleName = TextEditingController(text: widget.resident?.middleName);
  late TextEditingController lastName = TextEditingController(text: widget.resident?.lastName);
  late TextEditingController address = TextEditingController(text: widget.resident?.address);
  late TextEditingController yearsOfStay = TextEditingController(text: widget.resident?.residentSince.toString());
  final TextEditingController purpose = TextEditingController();
  final TextEditingController studentName = TextEditingController();
  final TextEditingController studentAddress = TextEditingController();
  final TextEditingController studentContactNumber = TextEditingController();
  final TextEditingController relationshipWithStudent = TextEditingController();

  final ValueNotifier<bool> isLoading = ValueNotifier(false);
  final ValueNotifier<bool> sameAsAbove = ValueNotifier(false);

  Future<bool> load() async {
    if (widget.id == null) return false;
    var doc = await indigenciesCollection.doc(widget.id).get();
    if (!doc.exists) return false;

    var indigency = doc.data()!;

    firstName.text = indigency.firstName;
    middleName.text = indigency.middleName;
    lastName.text = indigency.lastName;
    address.text = indigency.address;
    yearsOfStay.text = indigency.yearsOfStay;
    purpose.text = indigency.purpose;
    studentName.text = indigency.studentName;
    studentAddress.text = indigency.studentAddress;
    studentContactNumber.text = indigency.studentContactNumber;
    relationshipWithStudent.text = indigency.relationshipWithStudent;

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

    DocumentReference<Indigency> doc = indigenciesCollection.doc();

    Indigency indigency = Indigency(
      id: doc.id,
      uid: widget.resident?.id ?? '',
      firstName: firstName.text,
      middleName: middleName.text,
      lastName: lastName.text,
      address: address.text,
      yearsOfStay: yearsOfStay.text,
      purpose: purpose.text,
      studentName: studentName.text,
      studentAddress: studentAddress.text,
      studentContactNumber: studentContactNumber.text,
      relationshipWithStudent: relationshipWithStudent.text,
      createdAt: Timestamp.now(),
      updatedAt: Timestamp.now(),
    );

    await setIndigency(indigency, doc: doc);

    isLoading.value = false;

    if (context.mounted) Navigator.pop(context);
    if (context.mounted) showSnackBar(context, 'Successfully submitted indigency form.');
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
          icon: const Icon(TablerIcons.certificate_2),
          title: const Text('Indigency Form'),
          content: Column(
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
                          controller: yearsOfStay,
                          validator: validate,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          decoration: InputDecoration(
                            labelText: 'Years of Stay',
                            border: outlineInputBorder(context),
                            enabledBorder: outlineInputBorder(context),
                          ),
                        ),
                        TextFormField(
                          readOnly: widget.id != null,
                          controller: purpose,
                          validator: validate,
                          minLines: 5,
                          maxLines: 5,
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
                              child: Text('Applicant\'s Information'),
                            ),
                            Expanded(
                              child: Divider(
                                height: 0,
                                color: Theme.of(context).colorScheme.secondaryContainer,
                              ),
                            ),
                          ],
                        ),
                        ValueListenableBuilder(
                          valueListenable: sameAsAbove,
                          builder: (context, value, child) {
                            return SwitchListTile(
                              value: value,
                              title: const Text('Same as Above'),
                              onChanged: (value) {
                                sameAsAbove.value = value;
                                if (!value) {
                                  studentName.clear();
                                  studentAddress.clear();
                                  studentContactNumber.clear();
                                } else {
                                  studentName.text = '${firstName.text} ${middleName.text} ${lastName.text}';
                                  studentAddress.text = address.text;
                                  if (widget.resident != null) studentContactNumber.text = widget.resident!.contactNumber;
                                }
                              },
                            );
                          },
                        ),
                        TextFormField(
                          readOnly: widget.id != null,
                          controller: studentName,
                          validator: validate,
                          decoration: InputDecoration(
                            labelText: 'Name',
                            border: outlineInputBorder(context),
                            enabledBorder: outlineInputBorder(context),
                          ),
                        ),
                        TextFormField(
                          readOnly: widget.id != null,
                          controller: studentAddress,
                          validator: validate,
                          decoration: InputDecoration(
                            labelText: 'Address',
                            border: outlineInputBorder(context),
                            enabledBorder: outlineInputBorder(context),
                          ),
                        ),
                        TextFormField(
                          readOnly: widget.id != null,
                          controller: studentContactNumber,
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
                          controller: relationshipWithStudent,
                          validator: validate,
                          decoration: InputDecoration(
                            labelText: 'Relationship with student',
                            border: outlineInputBorder(context),
                            enabledBorder: outlineInputBorder(context),
                          ),
                        ),
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
                        fileName: 'indigency_${widget.id}',
                        title: 'CERTIFICATE OF INDIGENCY',
                        content: 'To whom it may concern:\n\n#This is to certify that Mr./ Ms./ Mrs. *${studentName.text.toUpperCase()}* residing at *${studentAddress.text.toUpperCase()}* is known to be a person of good moral character and law abiding citizen.\n\n#Certify further that he / she is one among our indigent citizen without source of income or scarce income. This certificate was requested for the purpose of *${purpose.text.toUpperCase()}*.\n\n#Issued this *${Timestamp.now().format().toUpperCase()}* at *BAGBAG QUEZON CITY, METRO MANILA*.',
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
                                    title: 'Declined request for Certificate of Indigency',
                                    content: 'Your request for the certificate of indigency was declined. Make sure the details provided are as follows, if you have any questions, feel free to contact the administrators.',
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

                            String name = 'indigency_${widget.id}.pdf';

                            Uint8List bytes = await createCertificate(
                              title: 'CERTIFICATE OF INDIGENCY',
                              content: 'To whom it may concern:\n\n#This is to certify that Mr./ Ms./ Mrs. *${studentName.text.toUpperCase()}* residing at *${studentAddress.text.toUpperCase()}* is known to be a person of good moral character and law abiding citizen.\n\n#Certify further that he / she is one among our indigent citizen without source of income or scarce income.\n\n#Issued this *${Timestamp.now().format().toUpperCase()}* at *BAGBAG QUEZON CITY, METRO MANILA*.',
                              persons: personPositions,
                            );

                            await setFile(ref: 'documents', name: name, bytes: bytes);

                            String url = await getDownloadUrl(ref: 'documents', name: name);

                            DocumentReference<NotificationMessage> doc = notificationsCollection.doc();

                            NotificationMessage notification = NotificationMessage(
                              id: doc.id,
                              fromUid: 'admin',
                              toUid: widget.uid!,
                              title: 'Approved request for Certificate of Indigency',
                              content: 'Your request for the certificate of indigency has been approved, see the attached link below for the PDF file.',
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
                            onPressed: () => submit(context),
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
