import 'package:brgy_bagbag/db_helper.dart';
import 'package:brgy_bagbag/functions.dart';
import 'package:brgy_bagbag/globals.dart';
import 'package:brgy_bagbag/models/request.dart';
import 'package:brgy_bagbag/models/resident.dart';
import 'package:brgy_bagbag/widgets/forms/business_clearance_dialog.dart';
import 'package:brgy_bagbag/widgets/forms/business_clearance_id_dialog.dart';
import 'package:brgy_bagbag/widgets/forms/concern_dialog.dart';
import 'package:brgy_bagbag/widgets/forms/indigency_dialog.dart';
import 'package:brgy_bagbag/widgets/forms/legal_consultation_dialog.dart';
import 'package:brgy_bagbag/widgets/column_separated.dart';
import 'package:brgy_bagbag/widgets/row_separated.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

class ResidentFormsPageView extends StatelessWidget {
  const ResidentFormsPageView({
    super.key,
    required this.resident,
    this.drawer,
    this.isPortrait = false,
  });

  final Resident resident;
  final Widget? drawer;
  final bool isPortrait;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(child: drawer),
      appBar: AppBar(
        leading: isPortrait ? null : const Icon(TablerIcons.notes),
        title: const Text('Forms'),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  FormCard(
                    icon: TablerIcons.bubble,
                    label: 'Concerns Form',
                    description: 'Submit your issues, complaints, or requests for assistance to the barangay for prompt action.',
                    dialog: ConcernDialog(resident: resident),
                  ),
                  FormCard(
                    icon: TablerIcons.contract,
                    label: 'Legal Consultation Form',
                    description: 'Schedule a consultation with the barangay\'s legal team for advice on various legal matters.',
                    dialog: LegalConsultationDialog(resident: resident),
                  ),
                  FormCard(
                    icon: TablerIcons.certificate_2,
                    label: 'Indigency Form',
                    description: 'Apply for a Certificate of Indigency to avail of government services and assistance programs.',
                    dialog: IndigencyDialog(resident: resident),
                  ),
                  FormCard(
                    icon: TablerIcons.building,
                    label: 'Barangay Business Clearance Form',
                    description: 'Obtain a clearance from the barangay for your business operations, ensuring compliance with local regulations.',
                    dialog: BusinessClearanceDialog(resident: resident),
                  ),
                  FormCard(
                    icon: TablerIcons.id_badge_2,
                    label: 'Business Clearance ID Form',
                    description: 'Request a Business Clearance ID as proof of your business\'s legitimacy and barangay approval.',
                    dialog: BusinessClearanceIdDialog(resident: resident),
                  ),
                ],
              ),
            ),
            const ListTile(
              leading: Icon(TablerIcons.ticket),
              title: Text('Requests'),
            ),
            StreamBuilder(
              stream: requestsCollection.where('uid', isEqualTo: resident.id).orderBy('createdAt', descending: true).snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

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
                        DataColumn(label: Text('#')),
                        DataColumn(label: Text('ID')),
                        DataColumn(label: Text('Type')),
                        DataColumn(label: Text('Status')),
                        DataColumn(label: Text('Submitted at')),
                        DataColumn(label: Text('Action')),
                      ],
                      rows: List.generate(
                        requests.length,
                        (index) {
                          Request request = requests[index];

                          return DataRow(
                            cells: [
                              DataCell(Text(index.toString())),
                              DataCell(Text(
                                request.id,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              )),
                              DataCell(
                                RowSeparated(
                                  spacing: 16,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(collectionIcons[request.collection]),
                                    Text(
                                      collectionNames[request.collection] ?? '',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
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
                                            : request.status == 'Cancelled'
                                                ? TablerIcons.cancel
                                                : TablerIcons.rosette_discount_check_off,
                                    color: request.status == 'Pending'
                                        ? Colors.amber
                                        : request.status == 'Approved'
                                            ? Colors.green
                                            : request.status == 'Cancelled'
                                                ? Colors.red
                                                : Colors.red,
                                  ),
                                ),
                              ),
                              DataCell(Text(
                                request.createdAt.format(),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              )),
                              DataCell(
                                IconButton(
                                  onPressed: () {
                                    bool isDone = [
                                      'Approved',
                                      'Declined',
                                      'Cancelled'
                                    ].contains(request.status);

                                    Future<void> cancel() async {
                                      request.status = 'Cancelled';
                                      await setRequest(request);
                                      if (context.mounted) showSnackBar(context, 'Your request is cancelled.');
                                    }

                                    switch (request.collection) {
                                      case concernsName:
                                        showDialog(
                                          context: context,
                                          builder: (context) => ConcernDialog(
                                            resident: resident,
                                            id: request.collectionId,
                                            onCancel: isDone ? null : cancel,
                                          ),
                                        );
                                        break;
                                      case legalConsultationName:
                                        showDialog(
                                          context: context,
                                          builder: (context) => LegalConsultationDialog(
                                            resident: resident,
                                            id: request.collectionId,
                                            onCancel: isDone ? null : cancel,
                                          ),
                                        );
                                        break;
                                      case indigenciesName:
                                        showDialog(
                                          context: context,
                                          builder: (context) => IndigencyDialog(
                                            resident: resident,
                                            id: request.collectionId,
                                            onCancel: isDone ? null : cancel,
                                          ),
                                        );
                                        break;
                                      case businessClearancesName:
                                        showDialog(
                                          context: context,
                                          builder: (context) => BusinessClearanceDialog(
                                            resident: resident,
                                            id: request.collectionId,
                                            onCancel: isDone ? null : cancel,
                                          ),
                                        );
                                        break;
                                      case businessClearanceIdName:
                                        showDialog(
                                          context: context,
                                          builder: (context) => BusinessClearanceIdDialog(
                                            resident: resident,
                                            id: request.collectionId,
                                            onCancel: isDone ? null : cancel,
                                          ),
                                        );
                                        break;
                                      default:
                                    }
                                  },
                                  icon: const Icon(TablerIcons.eye),
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
        ),
      ),
    );
  }
}

class FormCard extends StatelessWidget {
  const FormCard({
    super.key,
    required this.icon,
    required this.label,
    required this.description,
    required this.dialog,
  });

  final IconData icon;
  final String label;
  final String description;
  final Widget dialog;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 150,
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: Material(
          borderRadius: BorderRadius.circular(8),
          color: Theme.of(context).colorScheme.secondaryContainer,
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () => showDialog(context: context, builder: (context) => dialog),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: ColumnSeparated(
                  spacing: 8,
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      icon,
                      size: 40,
                      color: Theme.of(context).colorScheme.onSecondaryContainer,
                    ),
                    Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
