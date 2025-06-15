import 'package:brgy_bagbag/db_helper.dart';
import 'package:brgy_bagbag/functions.dart';
import 'package:brgy_bagbag/globals.dart';
import 'package:brgy_bagbag/models/admin_account.dart';
import 'package:brgy_bagbag/models/custom_notifier.dart';
import 'package:brgy_bagbag/models/notification_message.dart';
import 'package:brgy_bagbag/models/request.dart';
import 'package:brgy_bagbag/resident/widgets/are_you_sure_dialog.dart';
import 'package:brgy_bagbag/widgets/forms/business_clearance_dialog.dart';
import 'package:brgy_bagbag/widgets/forms/business_clearance_id_dialog.dart';
import 'package:brgy_bagbag/widgets/column_separated.dart';
import 'package:brgy_bagbag/widgets/forms/concern_dialog.dart';
import 'package:brgy_bagbag/widgets/forms/indigency_dialog.dart';
import 'package:brgy_bagbag/widgets/forms/legal_consultation_dialog.dart';
import 'package:brgy_bagbag/widgets/row_separated.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

class ClearanceAndFormsPageView extends StatefulWidget {
  const ClearanceAndFormsPageView({
    super.key,
    required this.admin,
    this.isPortrait = false,
    this.drawer,
  });

  final AdminAccount admin;

  final bool isPortrait;
  final Widget? drawer;

  @override
  State<ClearanceAndFormsPageView> createState() => _ClearanceAndFormsPageViewState();
}

class _ClearanceAndFormsPageViewState extends State<ClearanceAndFormsPageView> {
  late CustomNotifier<Future<AggregateQuerySnapshot>> pending = CustomNotifier(null);
  late CustomNotifier<Future<AggregateQuerySnapshot>> declined = CustomNotifier(null);
  late CustomNotifier<Future<AggregateQuerySnapshot>> approved = CustomNotifier(null);

  final ValueNotifier<bool> isArchived = ValueNotifier(false);

  void loadFutures() {
    pending.set(requestsCollection.where('status', isEqualTo: 'Pending').count().get());
    declined.set(requestsCollection.where('status', isEqualTo: 'Declined').count().get());
    approved.set(requestsCollection.where('status', isEqualTo: 'Approved').count().get());
  }

  @override
  void initState() {
    super.initState();
    loadFutures();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(child: widget.drawer),
      appBar: AppBar(
        leading: widget.isPortrait ? null : const Icon(TablerIcons.notes),
        title: const Text('Request Forms'),
        actions: [
          IconButton(onPressed: loadFutures, icon: const Icon(TablerIcons.refresh)),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!widget.isPortrait)
              Container(
                height: 200,
                padding: const EdgeInsets.all(16),
                child: RowSeparated(
                  spacing: 16,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    RequestStatusCard(
                      future: pending,
                      color: Colors.amber,
                      status: 'Pending',
                      icon: TablerIcons.loader,
                    ),
                    RequestStatusCard(
                      future: declined,
                      color: Colors.red,
                      status: 'Declined',
                      icon: TablerIcons.rosette_discount_check_off,
                    ),
                    RequestStatusCard(
                      future: approved,
                      color: Colors.green,
                      status: 'Approved',
                      icon: TablerIcons.rosette_discount_check,
                    ),
                  ],
                ),
              ),
            if (widget.isPortrait)
              Padding(
                padding: const EdgeInsets.all(16),
                child: ColumnSeparated(
                  spacing: 16,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      height: 200,
                      child: RequestStatusCard(
                        future: pending,
                        color: Colors.amber,
                        status: 'Pending',
                        icon: TablerIcons.loader,
                      ),
                    ),
                    SizedBox(
                      height: 200,
                      child: RequestStatusCard(
                        future: declined,
                        color: Colors.red,
                        status: 'Declined',
                        icon: TablerIcons.rosette_discount_check_off,
                      ),
                    ),
                    SizedBox(
                      height: 200,
                      child: RequestStatusCard(
                        future: approved,
                        color: Colors.green,
                        status: 'Approved',
                        icon: TablerIcons.rosette_discount_check,
                      ),
                    ),
                  ],
                ),
              ),
            ValueListenableBuilder(
              valueListenable: isArchived,
              builder: (context, isArchivedValue, child) {
                return StreamBuilder(
                  stream: requestsCollection.where('status', isNotEqualTo: 'Cancelled').where('archived', isEqualTo: isArchivedValue).orderBy('status').orderBy('createdAt', descending: true).snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            const Expanded(
                              flex: 2,
                              child: ListTile(
                                leading: Icon(TablerIcons.ticket),
                                title: Text('Requests'),
                              ),
                            ),
                            Expanded(
                              child: SwitchListTile(
                                dense: true,
                                value: isArchivedValue,
                                title: const Text(
                                  'Archived',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                onChanged: (value) => isArchived.value = value,
                              ),
                            ),
                          ],
                        ),
                        Builder(
                          builder: (context) {
                            if (snapshot.data!.docs.isEmpty) return const Text('No requests yet');

                            List<Request> requests = snapshot.data!.docs.map((e) => e.data()).toList();
                            return SizedBox(
                              width: double.infinity,
                              child: Theme(
                                data: Theme.of(context).copyWith(
                                  dividerTheme: const DividerThemeData(
                                    color: Colors.transparent,
                                    space: 0,
                                    thickness: 0,
                                    indent: 0,
                                    endIndent: 0,
                                  ),
                                ),
                                child: DataTable(
                                  headingTextStyle: const TextStyle(fontWeight: FontWeight.bold),
                                  columns: const [
                                    // DataColumn(label: Text('#')),
                                    DataColumn(label: Text('ID')),
                                    DataColumn(label: Text('Type')),
                                    DataColumn(label: Text('Status')),
                                    DataColumn(label: Text('Printed')),
                                    DataColumn(label: Text('Picked up')),
                                    DataColumn(label: Text('OR')),
                                    DataColumn(label: Text('Submitted at')),
                                    DataColumn(label: Text('Action')),
                                  ],
                                  rows: List.generate(
                                    requests.length,
                                    (index) {
                                      Request request = requests[index];

                                      return DataRow(
                                        cells: [
                                          // DataCell(Text(index.toString())),
                                          DataCell(
                                            SizedBox(
                                              width: 50,
                                              child: Text(
                                                request.id,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ),
                                          DataCell(
                                            RowSeparated(
                                              spacing: 16,
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(collectionIcons[request.collection]),
                                                Expanded(
                                                  child: Text(
                                                    collectionNames[request.collection] ?? '',
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          DataCell(
                                            Tooltip(
                                              message: request.status,
                                              child: Icon(
                                                request.status == 'Pending'
                                                    ? TablerIcons.loader
                                                    : request.status == 'Approved'
                                                        ? TablerIcons.rosette_discount_check
                                                        : TablerIcons.rosette_discount_check_off,
                                                color: request.status == 'Pending'
                                                    ? Colors.amber
                                                    : request.status == 'Approved'
                                                        ? Colors.green
                                                        : Colors.red,
                                              ),
                                            ),
                                          ),
                                          DataCell(
                                            Text(
                                              request.isPrinted ? 'Yes' : 'No',
                                              style: TextStyle(color: request.isPrinted ? Colors.green : Theme.of(context).disabledColor),
                                            ),
                                          ),
                                          DataCell(
                                            Text(
                                              request.isPickedUp ? 'Yes' : 'No',
                                              style: TextStyle(color: request.isPickedUp ? Colors.green : Theme.of(context).disabledColor),
                                            ),
                                          ),
                                          DataCell(
                                            request.orReferenceNumber == null
                                                ? Icon(
                                                    TablerIcons.receipt,
                                                    color: Theme.of(context).disabledColor,
                                                  )
                                                : Tooltip(
                                                    message: request.orReferenceNumber,
                                                    child: const Icon(TablerIcons.receipt),
                                                  ),
                                          ),
                                          DataCell(Text(
                                            request.createdAt.format(),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          )),
                                          DataCell(
                                            Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                IconButton(
                                                  onPressed: () {
                                                    bool isDone = [
                                                      'Approved',
                                                      'Declined'
                                                    ].contains(request.status);

                                                    switch (request.collection) {
                                                      case concernsName:
                                                        showDialog(
                                                          context: context,
                                                          builder: (context) => ConcernDialog(
                                                            id: request.collectionId,
                                                            requestId: request.id,
                                                            uid: request.uid,
                                                            isAdmin: widget.admin.isSuper,
                                                            isDone: isDone,
                                                            request: request,
                                                          ),
                                                        );
                                                        break;
                                                      case legalConsultationName:
                                                        showDialog(
                                                          context: context,
                                                          builder: (context) => LegalConsultationDialog(
                                                            id: request.collectionId,
                                                            requestId: request.id,
                                                            uid: request.uid,
                                                            isAdmin: widget.admin.isSuper,
                                                            isDone: isDone,
                                                            request: request,
                                                          ),
                                                        );
                                                        break;
                                                      case indigenciesName:
                                                        showDialog(
                                                          context: context,
                                                          builder: (context) => IndigencyDialog(
                                                            id: request.collectionId,
                                                            requestId: request.id,
                                                            uid: request.uid,
                                                            isAdmin: widget.admin.isSuper,
                                                            isDone: isDone,
                                                            isPrinted: request.isPrinted,
                                                            onPrint: () async {
                                                              request.isPrinted = true;
                                                              DocumentReference<Request>? doc = requestsCollection.doc(request.id);
                                                              await setRequest(request, doc: doc);
                                                            },
                                                            request: request,
                                                          ),
                                                        );
                                                        break;
                                                      case businessClearancesName:
                                                        showDialog(
                                                          context: context,
                                                          builder: (context) => BusinessClearanceDialog(
                                                            id: request.collectionId,
                                                            requestId: request.id,
                                                            uid: request.uid,
                                                            isAdmin: widget.admin.isSuper,
                                                            isDone: isDone,
                                                            isPrinted: request.isPrinted,
                                                            request: request,
                                                            onPrint: () async {
                                                              request.isPrinted = true;
                                                              DocumentReference<Request>? doc = requestsCollection.doc(request.id);
                                                              await setRequest(request, doc: doc);
                                                            },
                                                          ),
                                                        );
                                                        break;
                                                      case businessClearanceIdName:
                                                        showDialog(
                                                          context: context,
                                                          builder: (context) => BusinessClearanceIdDialog(
                                                            id: request.collectionId,
                                                            requestId: request.id,
                                                            uid: request.uid,
                                                            isAdmin: widget.admin.isSuper,
                                                            isDone: isDone,
                                                            request: request,
                                                          ),
                                                        );
                                                        break;
                                                      default:
                                                    }
                                                  },
                                                  icon: const Icon(TablerIcons.eye),
                                                ),
                                                if (widget.admin.isSuper &&
                                                    [
                                                      'Approved',
                                                    ].contains(request.status))
                                                  PopupMenuButton(
                                                    tooltip: request.isPickedUp ? 'Already picked-up' : 'Available for pickup',
                                                    icon: const Icon(TablerIcons.package),
                                                    enabled: !request.isPickedUp,
                                                    itemBuilder: (context) => [
                                                      PopupMenuItem(
                                                        onTap: () async {
                                                          // await removeIncidentReport(incidentReport.id);
                                                          DocumentReference<NotificationMessage> doc = notificationsCollection.doc();

                                                          String form = '';

                                                          switch (request.collection) {
                                                            case concernsName:
                                                              form = 'Concern';
                                                              break;
                                                            case legalConsultationName:
                                                              form = 'Legal Consultation';
                                                              break;
                                                            case indigenciesName:
                                                              form = 'Indigency';
                                                              break;
                                                            case businessClearancesName:
                                                              form = 'Barangay Business Clearance';
                                                              break;
                                                            case businessClearanceIdName:
                                                              form = 'Business Clearance ID';
                                                              break;
                                                            default:
                                                          }

                                                          NotificationMessage notification = NotificationMessage(
                                                            id: doc.id,
                                                            fromUid: 'admin',
                                                            toUid: request.uid,
                                                            title: '$form is ready for pickup!',
                                                            content: 'Your document is now available for pickup, go to our main office at your own pace and show your reference number to one of our staffs. Thank you!',
                                                            links: [],
                                                            createdAt: Timestamp.now(),
                                                            updatedAt: Timestamp.now(),
                                                          );

                                                          await setNotification(notification);
                                                        },
                                                        child: const Text('Notify Ready-for-Pickup'),
                                                      ),
                                                      if (!request.isPickedUp)
                                                        PopupMenuItem(
                                                          onTap: () async {
                                                            request.isPickedUp = true;
                                                            DocumentReference<Request>? doc = requestsCollection.doc(request.id);
                                                            await setRequest(request, doc: doc);
                                                          },
                                                          child: const Text('Mark as Picked-up'),
                                                        ),
                                                    ],
                                                  ),
                                                // IconButton(
                                                //   onPressed: () async {
                                                //     // await removeIncidentReport(incidentReport.id);
                                                //     DocumentReference<NotificationMessage> doc = notificationsCollection.doc();

                                                //     String form = '';

                                                //     switch (request.collection) {
                                                //       case concernsName:
                                                //         form = 'Concern';
                                                //         break;
                                                //       case legalConsultationName:
                                                //         form = 'Legal Consultation';
                                                //         break;
                                                //       case indigenciesName:
                                                //         form = 'Indigency';
                                                //         break;
                                                //       case businessClearancesName:
                                                //         form = 'Barangay Business Clearance';
                                                //         break;
                                                //       case businessClearanceIdName:
                                                //         form = 'Business Clearance ID';
                                                //         break;
                                                //       default:
                                                //     }

                                                //     NotificationMessage notification = NotificationMessage(
                                                //       id: doc.id,
                                                //       fromUid: 'admin',
                                                //       toUid: request.uid,
                                                //       title: '$form is ready for pickup!',
                                                //       content: 'Your document is now available for pickup, go to our main office at your own pace and show your reference number to one of our staffs. Thank you!',
                                                //       links: [],
                                                //       createdAt: Timestamp.now(),
                                                //       updatedAt: Timestamp.now(),
                                                //     );

                                                //     await setNotification(notification);
                                                //   },
                                                //   tooltip: 'Notify Ready-for-Pickup',
                                                //   icon: const Icon(TablerIcons.package),
                                                // ),
                                                // IconButton(
                                                //   onPressed: () async {
                                                //     // await removeIncidentReport(incidentReport.id);
                                                //     DocumentReference<NotificationMessage> doc = notificationsCollection.doc();

                                                //     String form = '';

                                                //     switch (request.collection) {
                                                //       case concernsName:
                                                //         form = 'Concern';
                                                //         break;
                                                //       case legalConsultationName:
                                                //         form = 'Legal Consultation';
                                                //         break;
                                                //       case indigenciesName:
                                                //         form = 'Indigency';
                                                //         break;
                                                //       case businessClearancesName:
                                                //         form = 'Barangay Business Clearance';
                                                //         break;
                                                //       case businessClearanceIdName:
                                                //         form = 'Business Clearance ID';
                                                //         break;
                                                //       default:
                                                //     }

                                                //     NotificationMessage notification = NotificationMessage(
                                                //       id: doc.id,
                                                //       fromUid: 'admin',
                                                //       toUid: request.uid,
                                                //       title: '$form is ready for pickup!',
                                                //       content: 'Your document is now available for pickup, go to our main office at your own pace and show your reference number to one of our staffs. Thank you!',
                                                //       links: [],
                                                //       createdAt: Timestamp.now(),
                                                //       updatedAt: Timestamp.now(),
                                                //     );

                                                //     await setNotification(notification);
                                                //   },
                                                //   tooltip: 'Notify Ready-for-Pickup',
                                                //   icon: const Icon(TablerIcons.package),
                                                // ),
                                                if (widget.admin.isSuper)
                                                  IconButton(
                                                    onPressed: () async {
                                                      bool? sure = await showDialog(
                                                        context: context,
                                                        builder: (context) => const AreYouSureDialog(),
                                                      );

                                                      if (sure == null) return;
                                                      if (!sure) return;

                                                      // await removeIncidentReport(incidentReport.id);
                                                      request.archived = !request.archived;
                                                      DocumentReference<Request> doc = requestsCollection.doc(request.id);
                                                      await setRequest(request, doc: doc);
                                                    },
                                                    tooltip: request.archived ? 'Restore' : 'Archive',
                                                    icon: Icon(
                                                      request.archived ? TablerIcons.archive_off : TablerIcons.archive,
                                                      color: Colors.pink,
                                                    ),
                                                  ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class RequestStatusCard extends StatelessWidget {
  const RequestStatusCard({
    super.key,
    required this.future,
    required this.color,
    required this.icon,
    required this.status,
  });

  final CustomNotifier<Future<AggregateQuerySnapshot>> future;
  final IconData icon;
  final Color color;
  final String status;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: future,
      builder: (context, value, child) {
        if (value == null) return const Center(child: CircularProgressIndicator());

        return FutureBuilder(
          future: value,
          builder: (context, snapshot) {
            return Expanded(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Theme.of(context).colorScheme.secondaryContainer,
                ),
                child: RowSeparated(
                  spacing: 16,
                  children: [
                    Expanded(
                      child: ColumnSeparated(
                        spacing: 16,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            icon,
                            size: 60,
                            color: color,
                          ),
                          Text(
                            status,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    if (snapshot.connectionState == ConnectionState.waiting) const SizedBox.square(dimension: 50, child: CircularProgressIndicator()),
                    if (snapshot.hasData && snapshot.connectionState == ConnectionState.done)
                      Text(
                        (snapshot.data!.count ?? 0).toString(),
                        style: const TextStyle(
                          fontSize: 50,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
