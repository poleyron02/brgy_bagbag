import 'package:brgy_bagbag/db_helper.dart';
import 'package:brgy_bagbag/functions.dart';
import 'package:brgy_bagbag/globals.dart';
import 'package:brgy_bagbag/models/custom_notifier.dart';
import 'package:brgy_bagbag/models/forms/concern.dart';
import 'package:brgy_bagbag/models/notification_message.dart';
import 'package:brgy_bagbag/models/request.dart';
import 'package:brgy_bagbag/models/resident.dart';
import 'package:brgy_bagbag/resident/widgets/are_you_sure_dialog.dart';
import 'package:brgy_bagbag/widgets/column_separated.dart';
import 'package:brgy_bagbag/widgets/forms/business_clearance_dialog.dart';
import 'package:brgy_bagbag/widgets/row_separated.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

class ConcernDialog extends StatefulWidget {
  const ConcernDialog({
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

  final Resident? resident;
  final String? id;
  final String? uid;
  final String? requestId;
  final bool isAdmin;
  final bool isDone;
  final Request? request;
  final Future<void> Function()? onCancel;

  @override
  State<ConcernDialog> createState() => _ConcernDialogState();
}

class _ConcernDialogState extends State<ConcernDialog> {
  late Future<bool> future;

  final GlobalKey<FormState> formKey = GlobalKey();

  late TextEditingController firstName = TextEditingController(text: widget.resident?.firstName);
  late TextEditingController middleName = TextEditingController(text: widget.resident?.middleName);
  late TextEditingController lastName = TextEditingController(text: widget.resident?.lastName);
  final TextEditingController email = TextEditingController();
  late TextEditingController contactNumber = TextEditingController(text: widget.resident?.contactNumber);
  final TextEditingController messages = TextEditingController();

  final ValueNotifier<bool> isLoading = ValueNotifier(false);

  Future<bool> load() async {
    if (widget.id == null) return false;
    var doc = await concernsCollection.doc(widget.id).get();
    if (!doc.exists) return false;

    var concern = doc.data()!;

    firstName.text = concern.firstName;
    middleName.text = concern.middleName;
    lastName.text = concern.lastName;
    email.text = concern.email;
    contactNumber.text = concern.contactNumber;
    messages.text = concern.messages;

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

    DocumentReference<Concern> doc = concernsCollection.doc();

    Concern concern = Concern(
      id: doc.id,
      uid: widget.resident?.id ?? '',
      firstName: firstName.text,
      middleName: middleName.text,
      lastName: lastName.text,
      email: email.text,
      contactNumber: contactNumber.text,
      messages: messages.text,
      createdAt: Timestamp.now(),
      updatedAt: Timestamp.now(),
    );

    await setConcern(concern, doc: doc);

    if (context.mounted) Navigator.pop(context);
    if (context.mounted) showSnackBar(context, 'Successfully submitted concerns form.');
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
          icon: const Icon(TablerIcons.bubble),
          title: const Text('Concern Form'),
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
                        TextFormField(
                          readOnly: widget.id != null,
                          controller: email,
                          validator: validate,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(TablerIcons.mail),
                            labelText: 'Email',
                            border: outlineInputBorder(context),
                            enabledBorder: outlineInputBorder(context),
                          ),
                        ),
                        TextFormField(
                          readOnly: widget.id != null,
                          controller: messages,
                          validator: validate,
                          minLines: 5,
                          maxLines: 10,
                          decoration: InputDecoration(
                            labelText: 'Messages',
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

                                  if (isLoading.value = true) return;
                                  if (widget.uid == null) return;
                                  if (widget.requestId == null) return;

                                  isLoading.value = true;

                                  DocumentReference<NotificationMessage> doc = notificationsCollection.doc();

                                  NotificationMessage notification = NotificationMessage(
                                    id: doc.id,
                                    fromUid: 'admin',
                                    toUid: widget.uid!,
                                    title: 'Declined request for Concern',
                                    content: 'Your request for concern was declined. Make sure the details provided are as follows, if you have any questions, feel free to contact the administrators.',
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

                                    if (context.mounted) {
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
                                      title: 'Approved request for Concern',
                                      content: 'Your request for concern has been approved. Please wait for one of our administrators to contact you through your email, thank you for your patience.',
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
                        })
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
