import 'package:brgy_bagbag/db_helper.dart';
import 'package:brgy_bagbag/globals.dart';
import 'package:brgy_bagbag/models/resident.dart';
import 'package:brgy_bagbag/resident/page_view/dashboard.dart';
import 'package:brgy_bagbag/resident/page_view/notifications.dart';
import 'package:brgy_bagbag/resident/page_view/pending_request.dart';
import 'package:brgy_bagbag/resident/page_view/forms.dart';
import 'package:brgy_bagbag/resident/page_view/profile.dart';
import 'package:brgy_bagbag/widgets/column_separated.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

class ResidentPortalPage extends StatelessWidget {
  ResidentPortalPage({
    super.key,
    required this.id,
  });

  final String id;

  final ValueNotifier<int?> firstNavigationRailIndex = ValueNotifier(0);
  final ValueNotifier<int?> secondNavigationRailIndex = ValueNotifier(null);
  final PageController pageController = PageController();

  final pages = [
    // const ResidentDashboardPageView(),
    //  ResidentNotificationsPageView(),
    //  ResidentNotificationsPageView(),
    // const ResidentRequestServicesPageView(),
    // const ResidentSettingsPageView(),
    // const ResidentPendingRequestPageView(),
    const ResidentPendingRequestPageView(),
    const ResidentPendingRequestPageView(),
    const ResidentPendingRequestPageView(),
  ];

  void moveToPage(int value) {
    secondNavigationRailIndex.value = null;
    firstNavigationRailIndex.value = value;
    pageController.animateToPage(value, duration: const Duration(milliseconds: 200), curve: Curves.fastOutSlowIn);
  }

  void processTo(int value) async {
    firstNavigationRailIndex.value = null;
    secondNavigationRailIndex.value = value;
    if (value == 0) {
      darkMode.value = !darkMode.value;
    }
    if (value == 1) {
      await FirebaseAuth.instance.signOut();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // drawer: NavigationSide(
      //   firstNavigationRailIndex: firstNavigationRailIndex,
      //   moveToPage: moveToPage,
      //   processTo: processTo,
      // ),
      body: StreamBuilder(
        stream: residentsCollection.doc(id).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          Resident resident = snapshot.data!.data()!;

          if (resident.status == 'Declined') {
            return Center(
              child: SingleChildScrollView(
                child: SizedBox(
                  width: 500,
                  child: ColumnSeparated(
                    spacing: 16,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(TablerIcons.rosette_discount_off),
                      Text('Resident Declined', style: Theme.of(context).textTheme.headlineLarge),
                      const Text('We regret to inform you that your request to use our services has been declined. If you believe this decision was made in error, please contact one of our administrators for further assistance.'),
                      Text('Reason: ${resident.reasonForDecline}'),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: () async {
                            await FirebaseAuth.instance.currentUser?.delete();
                          },
                          child: const Padding(
                            padding: EdgeInsets.all(8),
                            child: Text('GO BACK'),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          return LayoutBuilder(
            builder: (context, constraints) {
              bool isPortrait = constraints.maxWidth < constraints.maxHeight;
              print(isPortrait);
              return Row(
                children: [
                  if (!isPortrait)
                    NavigationSide(
                      firstNavigationRailIndex: firstNavigationRailIndex,
                      moveToPage: moveToPage,
                      processTo: processTo,
                    ),
                  if (!isPortrait) const VerticalDivider(width: .5),
                  Expanded(
                    child: PageView(
                      controller: pageController,
                      scrollDirection: Axis.vertical,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        ResidentDashboardPageView(
                          resident: resident,
                          isPortrait: isPortrait,
                          drawer: NavigationSide(
                            firstNavigationRailIndex: firstNavigationRailIndex,
                            processTo: processTo,
                            moveToPage: moveToPage,
                          ),
                        ),
                        ResidentNotificationsPageView(
                          resident: resident,
                          isPortrait: isPortrait,
                          drawer: NavigationSide(
                            firstNavigationRailIndex: firstNavigationRailIndex,
                            processTo: processTo,
                            moveToPage: moveToPage,
                          ),
                        ),
                        ResidentFormsPageView(
                          resident: resident,
                          isPortrait: isPortrait,
                          drawer: NavigationSide(
                            firstNavigationRailIndex: firstNavigationRailIndex,
                            processTo: processTo,
                            moveToPage: moveToPage,
                          ),
                        ),
                        ResidentProfilePageView(
                          resident: resident,
                          isPortrait: isPortrait,
                          drawer: NavigationSide(
                            firstNavigationRailIndex: firstNavigationRailIndex,
                            processTo: processTo,
                            moveToPage: moveToPage,
                          ),
                        ),
                        // const ResidentPendingRequestPageView(),
                        // const ResidentSettingsPageView(),
                      ],
                    ),
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

class NavigationSide extends StatelessWidget {
  const NavigationSide({
    super.key,
    required this.firstNavigationRailIndex,
    this.moveToPage,
    this.processTo,
  });

  final ValueNotifier<int?> firstNavigationRailIndex;
  final void Function(int)? moveToPage;
  final void Function(int)? processTo;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: firstNavigationRailIndex,
      builder: (context, firstIndex, child) {
        return NavigationRail(
          extended: true,
          groupAlignment: 0,
          selectedIndex: firstIndex,
          onDestinationSelected: moveToPage,
          leading: SizedBox.square(dimension: 150, child: Image.asset('images/logo.png')),
          destinations: const [
            NavigationRailDestination(icon: Icon(TablerIcons.dashboard), label: Text('Dashboard')),
            NavigationRailDestination(icon: Icon(TablerIcons.bell), label: Text('Notifications')),
            NavigationRailDestination(icon: Icon(TablerIcons.notes), label: Text('Forms')),
            NavigationRailDestination(icon: Icon(TablerIcons.user), label: Text('Profile')),
            // NavigationRailDestination(icon: Icon(TablerIcons.loader), label: Text('Pending Requests')),
          ],
          trailing: Expanded(
            child: ValueListenableBuilder(
              valueListenable: darkMode,
              builder: (context, value, child) {
                return NavigationRail(
                  extended: true,
                  groupAlignment: 1,
                  selectedIndex: null,
                  onDestinationSelected: processTo,
                  destinations: [
                    NavigationRailDestination(icon: Icon(value ? TablerIcons.moon : TablerIcons.sun), label: const Text('Dark Mode')),
                    const NavigationRailDestination(icon: Icon(TablerIcons.logout), label: Text('Logout')),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }
}
