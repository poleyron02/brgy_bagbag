import 'package:brgy_bagbag/admin/widgets/resident_dialog.dart';
import 'package:brgy_bagbag/db_helper.dart';
import 'package:brgy_bagbag/functions.dart';
import 'package:brgy_bagbag/models/admin_account.dart';
import 'package:brgy_bagbag/models/resident.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

class ResidentProfilingPageView extends StatelessWidget {
  ResidentProfilingPageView({
    super.key,
    required this.admin,
    this.isPortrait = false,
    this.drawer,
  });

  final AdminAccount admin;

  final TextEditingController search = TextEditingController();

  final bool isPortrait;
  final Widget? drawer;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(child: drawer),
      appBar: AppBar(
        leading: isPortrait ? null : const Icon(TablerIcons.users),
        title: const Text('Resident Profiling'),
      ),
      body: StreamBuilder(
        stream: residentsCollection.snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          if (snapshot.data!.docs.isEmpty) return const Center(child: Text('No residents yet.'));

          List<Resident> residents = snapshot.data!.docs.map((e) => e.data()).toList();

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
                    List<Resident> searchResidents = searchValue.text.isEmpty ? residents : residents.where((element) => element.fullName.toLowerCase().contains(searchValue.text.toLowerCase())).toList();
                    return SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: SingleChildScrollView(
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
                              DataColumn(label: Text('#'), numeric: true),
                              DataColumn(label: Text('Name')),
                              DataColumn(label: Text('Gender')),
                              DataColumn(label: Text('Birthday')),
                              DataColumn(label: Text('Contact No.')),
                              DataColumn(label: Text('Address')),
                              // DataColumn(label: Text('Place of Birth')),
                              // DataColumn(label: Text('Occupation')),
                              DataColumn(label: Text('Voter')),
                              // DataColumn(numeric: true, label: Text('Purok No.')),
                              DataColumn(label: Text('Resident since')),
                              DataColumn(label: Text('Verified')),
                              // DataColumn(label: Text('Registered at')),
                              DataColumn(label: Text('Action')),
                            ],
                            rows: List.generate(
                              searchResidents.length,
                              (index) {
                                Resident resident = searchResidents[index];

                                return DataRow(
                                  cells: [
                                    DataCell(
                                      SizedBox(width: 20, child: Text('$index')),
                                    ),
                                    DataCell(Text(
                                      resident.fullName,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    )),
                                    DataCell(Text(resident.gender)),
                                    DataCell(Text(
                                      resident.birthday.format(showTime: false),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    )),
                                    DataCell(Text(
                                      resident.contactNumber,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    )),
                                    DataCell(
                                      Text(
                                        resident.address,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    // DataCell(Text(
                                    //   resident.placeOfBirth,
                                    //   maxLines: 1,
                                    //   overflow: TextOverflow.ellipsis,
                                    // )),
                                    // DataCell(Text(resident.occupation)),
                                    DataCell(Text(resident.isVoter ? 'Yes' : 'No')),
                                    // DataCell(Text(resident.purokNumber)),
                                    DataCell(Text(
                                      resident.residentSince,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    )),

                                    DataCell(
                                      Tooltip(
                                        message: resident.status != 'Declined' ? resident.status : 'Reason: ${resident.reasonForDecline}',
                                        child: Icon(
                                          resident.status == 'Pending'
                                              ? TablerIcons.loader
                                              : resident.status == 'Approved'
                                                  ? TablerIcons.rosette_discount_check
                                                  : TablerIcons.rosette_discount_check_off,
                                          color: resident.status == 'Pending'
                                              ? Colors.amber
                                              : resident.status == 'Approved'
                                                  ? Colors.green
                                                  : Colors.red,
                                        ),
                                      ),
                                    ),
                                    // DataCell(Text(
                                    //   resident.createdAt.format(),
                                    //   maxLines: 1,
                                    //   overflow: TextOverflow.ellipsis,
                                    // )),

                                    DataCell(
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            onPressed: () {
                                              showDialog(
                                                context: context,
                                                builder: (context) => ResidentDialog(
                                                  resident: resident,
                                                  isAdmin: admin.isSuper,
                                                ),
                                              );
                                            },
                                            icon: Icon(admin.isSuper ? TablerIcons.edit : TablerIcons.eye),
                                          ),
                                          // IconButton(
                                          //   onPressed: () async {
                                          //     await removeResident(resident.id);
                                          //   },
                                          //   icon: const Icon(
                                          //     TablerIcons.trash,
                                          //     color: Colors.pink,
                                          //   ),
                                          // ),
                                        ],
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
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
