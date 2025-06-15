import 'package:brgy_bagbag/admin/login.dart';
import 'package:brgy_bagbag/admin/page_view/account_setting.dart';
import 'package:brgy_bagbag/admin/page_view/admin_account.dart';
import 'package:brgy_bagbag/admin/page_view/admin_logs.dart';
import 'package:brgy_bagbag/admin/page_view/announcement.dart';
import 'package:brgy_bagbag/admin/page_view/barangay_officials.dart';
import 'package:brgy_bagbag/admin/page_view/clearance_and_forms.dart';
import 'package:brgy_bagbag/admin/page_view/dashboard.dart';
import 'package:brgy_bagbag/admin/page_view/peace_and_order.dart';
import 'package:brgy_bagbag/admin/page_view/reports.dart';
import 'package:brgy_bagbag/admin/page_view/resident_profiling.dart';
import 'package:brgy_bagbag/db_helper.dart';
import 'package:brgy_bagbag/globals.dart';
import 'package:brgy_bagbag/models/admin_account.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

class AdminHomePage extends StatelessWidget {
  AdminHomePage({
    super.key,
    required this.admin,
  });

  final AdminAccount admin;

  final ValueNotifier<int?> firstNavigationRailIndex = ValueNotifier(0);
  final ValueNotifier<int?> secondNavigationRailIndex = ValueNotifier(0);
  final PageController pageController = PageController();

  late var pages = [
    DashboardPageView(
      drawer: NavigationSide(
        admin: admin,
        firstNavigationRailIndex: firstNavigationRailIndex,
        processTo: processTo,
        moveToPage: moveToPage,
      ),
    ),
    // const AccountPageView(),
    if (admin.isSuper) AdminAccountPageView(),
    ClearanceAndFormsPageView(admin: admin),
    PeaceAndOrderPageView(),
    ResidentProfilingPageView(admin: admin),
    AnnouncementPageView(admin: admin),
    BarangayOfficialsPageView(admin: admin),
    if (admin.isSuper) const AdminLogsPageView(),
    // const ReportsPageView(),
    const AccountSettingPageView(),
  ];

  void moveToPage(int value) {
    secondNavigationRailIndex.value = null;
    firstNavigationRailIndex.value = value;
    pageController.animateToPage(value, duration: const Duration(milliseconds: 200), curve: Curves.fastOutSlowIn);
  }

  void processTo(BuildContext context, int value) async {
    firstNavigationRailIndex.value = null;
    secondNavigationRailIndex.value = value;
    if (value == 0) {
      darkMode.value = !darkMode.value;
    }
    if (value == 1) {
      isAdminLogin.value = false;
      await logAdminAction(admin, 'Logged out');
      if (context.mounted) Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => AdminLoginPage()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      bool isPortrait = constraints.maxHeight > constraints.maxWidth;

      return Scaffold(
        body: Row(
          children: [
            if (!isPortrait)
              NavigationSide(
                admin: admin,
                firstNavigationRailIndex: firstNavigationRailIndex,
                processTo: processTo,
                moveToPage: moveToPage,
              ),
            if (!isPortrait) const VerticalDivider(width: .5),
            Expanded(
              child: PageView(
                controller: pageController,
                scrollDirection: Axis.vertical,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  DashboardPageView(
                    isPortrait: isPortrait,
                    drawer: NavigationSide(
                      admin: admin,
                      firstNavigationRailIndex: firstNavigationRailIndex,
                      processTo: processTo,
                      moveToPage: moveToPage,
                    ),
                  ),
                  // const AccountPageView(),
                  if (admin.isSuper)
                    AdminAccountPageView(
                      isPortrait: isPortrait,
                      drawer: NavigationSide(
                        admin: admin,
                        firstNavigationRailIndex: firstNavigationRailIndex,
                        processTo: processTo,
                        moveToPage: moveToPage,
                      ),
                    ),
                  ClearanceAndFormsPageView(
                    admin: admin,
                    isPortrait: isPortrait,
                    drawer: NavigationSide(
                      admin: admin,
                      firstNavigationRailIndex: firstNavigationRailIndex,
                      processTo: processTo,
                      moveToPage: moveToPage,
                    ),
                  ),
                  PeaceAndOrderPageView(
                    isPortrait: isPortrait,
                    drawer: NavigationSide(
                      admin: admin,
                      firstNavigationRailIndex: firstNavigationRailIndex,
                      processTo: processTo,
                      moveToPage: moveToPage,
                    ),
                  ),
                  ResidentProfilingPageView(
                    admin: admin,
                    isPortrait: isPortrait,
                    drawer: NavigationSide(
                      admin: admin,
                      firstNavigationRailIndex: firstNavigationRailIndex,
                      processTo: processTo,
                      moveToPage: moveToPage,
                    ),
                  ),
                  AnnouncementPageView(
                    admin: admin,
                    isPortrait: isPortrait,
                    drawer: NavigationSide(
                      admin: admin,
                      firstNavigationRailIndex: firstNavigationRailIndex,
                      processTo: processTo,
                      moveToPage: moveToPage,
                    ),
                  ),
                  BarangayOfficialsPageView(
                    admin: admin,
                    isPortrait: isPortrait,
                    drawer: NavigationSide(
                      admin: admin,
                      firstNavigationRailIndex: firstNavigationRailIndex,
                      processTo: processTo,
                      moveToPage: moveToPage,
                    ),
                  ),
                  if (admin.isSuper)
                    AdminLogsPageView(
                      isPortrait: isPortrait,
                      drawer: NavigationSide(
                        admin: admin,
                        firstNavigationRailIndex: firstNavigationRailIndex,
                        processTo: processTo,
                        moveToPage: moveToPage,
                      ),
                    ),
                  // const ReportsPageView(),
                  AccountSettingPageView(
                    isPortrait: isPortrait,
                    drawer: NavigationSide(
                      admin: admin,
                      firstNavigationRailIndex: firstNavigationRailIndex,
                      processTo: processTo,
                      moveToPage: moveToPage,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }
}

class NavigationSide extends StatelessWidget {
  const NavigationSide({
    super.key,
    required this.admin,
    required this.firstNavigationRailIndex,
    this.moveToPage,
    this.processTo,
  });

  final AdminAccount admin;
  final ValueNotifier<int?> firstNavigationRailIndex;
  final void Function(int)? moveToPage;
  final void Function(BuildContext context, int value)? processTo;

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
          leading: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox.square(dimension: 100, child: Image.asset('images/logo.png')),
              const SizedBox(height: 16),
              Text(admin.fullName),
              Text(
                admin.email,
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
          destinations: [
            const NavigationRailDestination(icon: Icon(TablerIcons.dashboard), label: Text('Dashboard')),
            // NavigationRailDestination(icon: Icon(TablerIcons.users), label: Text('Account')),
            if (admin.isSuper) const NavigationRailDestination(icon: Icon(TablerIcons.users), label: Text('Accounts')),
            NavigationRailDestination(
              icon: const Icon(TablerIcons.notes),
              label: StreamBuilder(
                stream: requestsCollection.where('status', isEqualTo: 'Pending').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    if (snapshot.data!.docs.isNotEmpty) {
                      return const Badge(
                        child: Padding(
                          padding: EdgeInsets.only(right: 16),
                          child: Text('Request Forms'),
                        ),
                      );
                    }
                  }
                  return const Text('Request Forms');
                },
              ),
            ),
            const NavigationRailDestination(icon: Icon(TablerIcons.gavel), label: Text('Peace and Order')),
            NavigationRailDestination(
              icon: const Icon(TablerIcons.users),
              label: StreamBuilder(
                stream: residentsCollection.where('status', isEqualTo: 'Pending').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    if (snapshot.data!.docs.isNotEmpty) {
                      return const Badge(
                        child: Padding(
                          padding: EdgeInsets.only(right: 16),
                          child: Text('Resident Profiling'),
                        ),
                      );
                    }
                  }
                  return const Text('Resident Profiling');
                },
              ),
            ),
            const NavigationRailDestination(icon: Icon(TablerIcons.speakerphone), label: Text('Announcement')),
            const NavigationRailDestination(icon: Icon(TablerIcons.discount_check), label: Text('Barangay Officials')),
            if (admin.isSuper) const NavigationRailDestination(icon: Icon(TablerIcons.logs), label: Text('Logs')),
            // NavigationRailDestination(icon: Icon(TablerIcons.report), label: Text('Reports')),
          ],
          trailing: Expanded(
            child: ValueListenableBuilder(
              valueListenable: darkMode,
              builder: (context, value, child) {
                return NavigationRail(
                  extended: true,
                  groupAlignment: 1,
                  selectedIndex: null,
                  onDestinationSelected: processTo == null ? null : (value) => processTo!(context, value),
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
