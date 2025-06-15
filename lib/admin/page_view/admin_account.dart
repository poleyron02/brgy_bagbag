import 'package:brgy_bagbag/admin/widgets/admin_account_dialog.dart';
import 'package:brgy_bagbag/db_helper.dart';
import 'package:brgy_bagbag/models/admin_account.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

class AdminAccountPageView extends StatelessWidget {
  AdminAccountPageView({
    super.key,
    this.isPortrait = false,
    this.drawer,
  });

  final bool isPortrait;
  final Widget? drawer;

  final TextEditingController search = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(child: drawer),
      appBar: AppBar(
        leading: isPortrait ? null : const Icon(TablerIcons.users),
        title: const Text('Accounts'),
        actions: [
          TextButton.icon(
            onPressed: () => showDialog(
              context: context,
              builder: (context) => AdminAccountDialog(),
            ),
            icon: const Icon(TablerIcons.users),
            label: const Text('Add Account'),
          ),
        ],
      ),
      body: StreamBuilder(
        stream: adminAccountsCollection.where('position', isNotEqualTo: 'Admin').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          if (snapshot.data!.docs.isEmpty) return const Center(child: Text('No admins yet.'));

          List<AdminAccount> admins = snapshot.data!.docs.map((e) => e.data()).toList();

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextFormField(
                  controller: search,
                  // textAlignVertical: TextAlignVertical.center,
                  decoration: const InputDecoration(
                    icon: Icon(TablerIcons.search),
                    border: InputBorder.none,
                    hintText: 'Search name...',
                  ),
                ),
              ),
              Expanded(
                child: ValueListenableBuilder(
                  valueListenable: search,
                  builder: (context, searchValue, child) {
                    List<AdminAccount> searchAdmins = searchValue.text.isEmpty ? admins : admins.where((element) => element.fullName.toLowerCase().contains(searchValue.text.toLowerCase())).toList();
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
                            DataColumn(label: Text('Name')),
                            DataColumn(label: Text('Username')),
                            DataColumn(label: Text('Email Address')),
                            DataColumn(label: Text('ID')),
                            DataColumn(label: Text('Password')),
                            DataColumn(label: Text('Position')),
                            DataColumn(label: Text('Action')),
                          ],
                          rows: List.generate(
                            searchAdmins.length,
                            (index) {
                              AdminAccount admin = searchAdmins[index];

                              return DataRow(
                                cells: [
                                  DataCell(Text(index.toString())),
                                  DataCell(Text(
                                    admin.fullName,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  )),
                                  DataCell(Text(admin.username)),
                                  DataCell(Text(admin.email)),
                                  DataCell(Text(admin.deviceId)),
                                  DataCell(Text(admin.password)),
                                  DataCell(Text(admin.position)),
                                  DataCell(
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          onPressed: () {
                                            showDialog(
                                              context: context,
                                              builder: (context) => AdminAccountDialog(
                                                adminAccount: admin,
                                              ),
                                            );
                                          },
                                          icon: const Icon(TablerIcons.edit),
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
              ),
            ],
          );
        },
      ),
    );
  }
}
