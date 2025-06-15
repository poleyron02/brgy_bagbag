import 'package:brgy_bagbag/db_helper.dart';
import 'package:brgy_bagbag/functions.dart';
import 'package:brgy_bagbag/models/admin_log.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

class AdminLogsPageView extends StatelessWidget {
  const AdminLogsPageView({
    super.key,
    this.isPortrait = false,
    this.drawer,
  });

  final bool isPortrait;
  final Widget? drawer;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(child: drawer),
      appBar: AppBar(
        leading: isPortrait ? null : const Icon(TablerIcons.logs),
        title: const Text('Logs'),
      ),
      body: SingleChildScrollView(
        child: StreamBuilder(
          stream: adminLogsCollection.orderBy('createdAt', descending: true).snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

            if (snapshot.data!.docs.isEmpty) return const Center(child: Text('No logs yet.'));

            List<AdminLog> logs = snapshot.data!.docs.map((e) => e.data()).toList();

            return SingleChildScrollView(
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
                    DataColumn(label: Text('ID')),
                    DataColumn(label: Text('Name')),
                    DataColumn(label: Text('Action')),
                    DataColumn(label: Text('Logged At')),
                  ],
                  rows: List.generate(
                    logs.length,
                    (index) {
                      AdminLog log = logs[index];

                      return DataRow(
                        cells: [
                          DataCell(Text(index.toString())),
                          DataCell(Text(
                            log.id,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          )),
                          DataCell(Text(
                            log.adminName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          )),
                          DataCell(Text(
                            log.action,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          )),
                          DataCell(Text(
                            log.loggedAt.format(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          )),
                        ],
                      );
                    },
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
