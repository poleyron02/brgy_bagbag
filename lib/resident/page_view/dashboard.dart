import 'package:brgy_bagbag/db_helper.dart';
import 'package:brgy_bagbag/functions.dart';
import 'package:brgy_bagbag/models/announcement.dart';
import 'package:brgy_bagbag/models/barangay_official.dart';
import 'package:brgy_bagbag/models/resident.dart';
import 'package:brgy_bagbag/widgets/announcement_card.dart';
import 'package:brgy_bagbag/widgets/column_separated.dart';
import 'package:brgy_bagbag/widgets/row_separated.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

class ResidentDashboardPageView extends StatelessWidget {
  ResidentDashboardPageView({
    super.key,
    required this.resident,
    this.isPortrait = false,
    this.drawer,
  });

  final Resident resident;

  final ScrollController scrollController = ScrollController();
  final bool isPortrait;
  final Widget? drawer;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(child: drawer),
      appBar: AppBar(
        leading: isPortrait ? null : const Icon(TablerIcons.dashboard),
        title: const Text('Dashboard'),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: isPortrait ? 16 : 100),
              child: SizedBox(
                height: isPortrait ? null : 400,
                child: Center(
                  child: isPortrait
                      ? ColumnSeparated(
                          spacing: 16,
                          children: [
                            Icon(
                              TablerIcons.hand_love_you,
                              size: 80,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            WelcomeBox(resident: resident),
                          ],
                        )
                      : RowSeparated(
                          spacing: 40,
                          children: [
                            Icon(
                              TablerIcons.hand_love_you,
                              size: 80,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            Expanded(child: WelcomeBox(resident: resident)),
                          ],
                        ),
                ),
              ),
            ),
            const ListTile(
              leading: Icon(TablerIcons.speakerphone),
              title: Text('Announcements'),
            ),
            SizedBox(
              height: 300,
              child: StreamBuilder(
                stream: announcementsStream,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

                  if (snapshot.data!.docs.isEmpty) return const Text('No announcements yet.');

                  List<Announcement> announcements = snapshot.data!.docs.map((e) => e.data()).toList();

                  return PageView.builder(
                    padEnds: false,
                    controller: PageController(
                      viewportFraction: 0.9,
                      initialPage: 0,
                    ),
                    itemCount: announcements.length,
                    itemBuilder: (context, index) {
                      Announcement announcement = announcements[index];

                      return AnnouncementCard(announcement: announcement);
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            const ListTile(
              leading: Icon(TablerIcons.discount_check),
              title: Text('Barangay Officials'),
            ),
            SizedBox(
              height: 200,
              child: StreamBuilder(
                stream: barangayOfficialCollection.orderBy('createdAt', descending: true).snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

                  if (snapshot.data!.docs.isEmpty) return const Center(child: Text('No barangay officials yet.'));

                  List<BarangayOfficial> barangayOfficials = snapshot.data!.docs.map((e) => e.data()).toList();

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        IconButton(onPressed: () => scrollController.animateTo(scrollController.offset - 1000, duration: const Duration(milliseconds: 200), curve: Curves.fastOutSlowIn), icon: const Icon(TablerIcons.chevron_left)),
                        Expanded(
                          child: SingleChildScrollView(
                            controller: scrollController,
                            scrollDirection: Axis.horizontal,
                            child: Wrap(
                              // crossAxisAlignment: WrapCrossAlignment.center,
                              // runAlignment: WrapAlignment.start,
                              // alignment: WrapAlignment.spaceEvenly,
                              spacing: 16,
                              runSpacing: 16,
                              children: List.generate(
                                barangayOfficials.length,
                                (index) {
                                  BarangayOfficial barangayOfficial = barangayOfficials[index];

                                  return SizedBox.square(
                                    dimension: 200,
                                    child: ColumnSeparated(
                                      spacing: 8,
                                      // crossAxisAlignment: CrossAxisAlignment.stretch,
                                      children: [
                                        Expanded(
                                          child: Container(
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              image: DecorationImage(
                                                image: NetworkImage(barangayOfficial.image),
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ),
                                        ),
                                        Text(
                                          barangayOfficial.fullName,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Text(
                                          barangayOfficial.position,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Theme.of(context).colorScheme.secondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                        IconButton(onPressed: () => scrollController.animateTo(scrollController.offset + 1000, duration: const Duration(milliseconds: 200), curve: Curves.fastOutSlowIn), icon: const Icon(TablerIcons.chevron_right)),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class WelcomeBox extends StatelessWidget {
  const WelcomeBox({
    super.key,
    required this.resident,
  });

  final Resident resident;

  @override
  Widget build(BuildContext context) {
    return ColumnSeparated(
      spacing: 16,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            const Text(
              'Hi, ',
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              resident.firstName,
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
            const Text(
              '!',
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const Text(
          '''Welcome to the official web portal of Barangay Bagbag. We're here to serve you with the latest updates, community services, and essential information. Explore our site to stay connected with your barangay and be an active part of our growing community. Together, let's continue to make Barangay Bagbag a safe, vibrant, and welcoming place for everyone.''',
          // maxLines: 3,
          // overflow: TextOverflow.ellipsis,
          style: TextStyle(height: 2),
        ),
      ],
    );
  }
}
