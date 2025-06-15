import 'package:brgy_bagbag/admin/widgets/incident_report_dialog.dart';
import 'package:brgy_bagbag/db_helper.dart';
import 'package:brgy_bagbag/functions.dart';
import 'package:brgy_bagbag/globals.dart';
import 'package:brgy_bagbag/models/incident_report.dart';
import 'package:brgy_bagbag/resident/widgets/are_you_sure_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

class PeaceAndOrderPageView extends StatelessWidget {
  PeaceAndOrderPageView({
    super.key,
    this.isPortrait = false,
    this.drawer,
  });

  final TextEditingController search = TextEditingController();
  final ValueNotifier<bool> isArchived = ValueNotifier(false);

  final bool isPortrait;
  final Widget? drawer;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(child: drawer),
      appBar: AppBar(
        leading: isPortrait ? null : const Icon(TablerIcons.gavel),
        title: const Text('Peace and Order'),
        actions: [
          TextButton.icon(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => IncidentReportDialog(),
              );
            },
            icon: const Icon(TablerIcons.plus),
            label: const Text('Add Incident Report'),
          ),
        ],
      ),
      body: ValueListenableBuilder(
        valueListenable: isArchived,
        builder: (context, isArchivedValue, child) {
          return StreamBuilder(
            stream: incidentReportCollection.where('archived', isEqualTo: isArchivedValue).snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: TextFormField(
                            controller: search,
                            // textAlignVertical: TextAlignVertical.center,
                            decoration: const InputDecoration(
                              icon: Icon(TablerIcons.search),
                              border: InputBorder.none,
                              hintText: 'Search title...',
                            ),
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
                  ),
                  Expanded(
                    child: Builder(builder: (context) {
                      if (snapshot.data!.docs.isEmpty) return const Center(child: Text('No incident reports yet.'));

                      List<IncidentReport> incidentReports = snapshot.data!.docs.map((e) => e.data()).toList();

                      return ValueListenableBuilder(
                        valueListenable: search,
                        builder: (context, searchValue, child) {
                          List<IncidentReport> searchIncidentReports = searchValue.text.isEmpty ? incidentReports : incidentReports.where((element) => element.title.toLowerCase().contains(searchValue.text.toLowerCase())).toList();

                          return SingleChildScrollView(
                            // constraints: BoxConstraints(minWidth: constraints.minWidth),
                            scrollDirection: Axis.horizontal,
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
                                  DataColumn(label: Text('Blotter Type')),
                                  DataColumn(label: Text('Title')),
                                  DataColumn(label: Text('Complainant/s')),
                                  DataColumn(label: Text('Offender/s')),
                                  DataColumn(label: Text('Date Reported')),
                                  DataColumn(label: Text('Date Occurred')),
                                  DataColumn(label: Text('Status')),
                                  DataColumn(label: Text('Action')),
                                ],
                                rows: List.generate(
                                  searchIncidentReports.length,
                                  (index) {
                                    IncidentReport incidentReport = searchIncidentReports[index];

                                    return DataRow(
                                      cells: [
                                        DataCell(Text(index.toString())),
                                        DataCell(Text(
                                          incidentReport.blotterType,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        )),
                                        DataCell(Text(incidentReport.title)),
                                        DataCell(Text(
                                          incidentReport.complainants.map((e) => e.name).join(', '),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        )),
                                        DataCell(Text(
                                          incidentReport.offenders.map((e) => e.name).join(', '),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        )),
                                        DataCell(Text(
                                          incidentReport.createdAt.format(),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        )),
                                        DataCell(Text(
                                          incidentReport.occurredAt.format(),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        )),
                                        DataCell(
                                          DropdownButton(
                                            value: incidentReport.status,
                                            onChanged: (value) async {
                                              incidentReport.status = value!;
                                              DocumentReference<IncidentReport> doc = incidentReportCollection.doc(incidentReport.id);
                                              await setIncidentReport(incidentReport, doc: doc);
                                            },
                                            items: List.generate(
                                              incidentStatuses.length,
                                              (index) {
                                                return DropdownMenuItem(
                                                    value: incidentStatuses[index],
                                                    child: Text(
                                                      incidentStatuses[index],
                                                      maxLines: 1,
                                                      overflow: TextOverflow.ellipsis,
                                                    ));
                                              },
                                            ),
                                          ),
                                        ),
                                        DataCell(
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              IconButton(
                                                onPressed: () {
                                                  showDialog(
                                                    context: context,
                                                    builder: (context) => IncidentReportDialog(
                                                      incidentReport: incidentReport,
                                                    ),
                                                  );
                                                },
                                                icon: const Icon(TablerIcons.edit),
                                              ),
                                              IconButton(
                                                onPressed: () {
                                                  downloadIncidentReport(incidentReport);
                                                },
                                                icon: const Icon(TablerIcons.printer),
                                              ),
                                              IconButton(
                                                onPressed: () async {
                                                  bool? sure = await showDialog(
                                                    context: context,
                                                    builder: (context) => const AreYouSureDialog(),
                                                  );

                                                  if (sure == null) return;
                                                  if (!sure) return;

                                                  // await removeIncidentReport(incidentReport.id);
                                                  incidentReport.archived = !incidentReport.archived;
                                                  DocumentReference<IncidentReport> doc = incidentReportCollection.doc(incidentReport.id);
                                                  await setIncidentReport(incidentReport, doc: doc);
                                                },
                                                tooltip: incidentReport.archived ? 'Restore' : 'Archive',
                                                icon: Icon(
                                                  incidentReport.archived ? TablerIcons.archive_off : TablerIcons.archive,
                                                  color: incidentReport.archived ? Colors.green : Colors.pink,
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
                      );
                    }),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
