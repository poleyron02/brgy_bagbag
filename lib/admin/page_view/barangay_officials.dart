import 'package:brgy_bagbag/admin/widgets/barangay_official_dialog.dart';
import 'package:brgy_bagbag/db_helper.dart';
import 'package:brgy_bagbag/models/admin_account.dart';
import 'package:brgy_bagbag/models/barangay_official.dart';
import 'package:brgy_bagbag/resident/widgets/are_you_sure_dialog.dart';
import 'package:brgy_bagbag/widgets/column_separated.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

class BarangayOfficialsPageView extends StatelessWidget {
  const BarangayOfficialsPageView({
    super.key,
    required this.admin,
    this.isPortrait = false,
    this.drawer,
  });

  final AdminAccount admin;

  final bool isPortrait;
  final Widget? drawer;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(child: drawer),
      appBar: AppBar(
        leading: isPortrait ? null : const Icon(TablerIcons.discount_check),
        title: const Text('Barangay Officials'),
        actions: !admin.isSuper
            ? null
            : [
                TextButton.icon(
                  onPressed: () => showDialog(
                    context: context,
                    builder: (context) => BarangayOfficialDialog(),
                  ),
                  icon: const Icon(TablerIcons.plus),
                  label: const Text('Add Barangay Official'),
                ),
              ],
      ),
      body: StreamBuilder(
        stream: barangayOfficialCollection.orderBy('createdAt', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No barangay officials yet.'));
          }

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: isPortrait ? 2 : 3,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
            ),
            itemCount: snapshot.data!.size,
            itemBuilder: (context, index) {
              BarangayOfficial barangayOfficial = snapshot.data!.docs[index].data();

              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Theme.of(context).colorScheme.secondaryContainer),
                ),
                child: Center(
                  child: ColumnSeparated(
                    spacing: 8,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: AspectRatio(
                            aspectRatio: 1,
                            child: Image.network(
                              barangayOfficial.image,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                      Text(
                        barangayOfficial.fullName,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '${barangayOfficial.position} - Since ${barangayOfficial.appointedAt.toDate().year}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                      if (admin.isSuper)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextButton.icon(
                              onPressed: () => showDialog(context: context, builder: (context) => BarangayOfficialDialog(barangayOfficial: barangayOfficial)),
                              icon: const Icon(TablerIcons.edit),
                              label: const Text('Edit'),
                            ),
                            TextButton.icon(
                              onPressed: () async {
                                bool? sure = await showDialog(
                                  context: context,
                                  builder: (context) => const AreYouSureDialog(),
                                );

                                if (sure == null) return;
                                if (!sure) return;
                                removeBarangayOfficial(barangayOfficial.id);
                              },
                              icon: const Icon(TablerIcons.trash),
                              label: const Text('Delete'),
                              style: const ButtonStyle(foregroundColor: WidgetStatePropertyAll(Colors.pink)),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
