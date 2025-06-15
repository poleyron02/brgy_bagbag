import 'dart:async';
import 'dart:ui';

import 'package:brgy_bagbag/db_helper.dart';
import 'package:brgy_bagbag/functions.dart';
import 'package:brgy_bagbag/models/announcement.dart';
import 'package:brgy_bagbag/models/barangay_official.dart';
import 'package:brgy_bagbag/resident/portal.dart';
import 'package:brgy_bagbag/resident/login.dart';
import 'package:brgy_bagbag/widgets/announcement_card.dart';
import 'package:brgy_bagbag/widgets/column_separated.dart';
import 'package:brgy_bagbag/widgets/row_separated.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:url_launcher/url_launcher.dart';

class ResidentHomePage extends StatefulWidget {
  const ResidentHomePage({super.key});

  @override
  State<ResidentHomePage> createState() => _ResidentHomePageState();
}

class _ResidentHomePageState extends State<ResidentHomePage> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseAuth.instance.userChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());

        if (!snapshot.hasData) return const ResidentTopPage();

        if (snapshot.data!.emailVerified) return ResidentPortalPage(id: snapshot.data!.uid);

        return ResidentVerifyEmailPage(user: snapshot.data!);
      },
    );
  }
}

class ResidentVerifyEmailPage extends StatefulWidget {
  const ResidentVerifyEmailPage({
    super.key,
    required this.user,
  });

  final User user;

  @override
  State<ResidentVerifyEmailPage> createState() => _ResidentVerifyEmailPageState();
}

class _ResidentVerifyEmailPageState extends State<ResidentVerifyEmailPage> {
  late Timer timer;

  @override
  void initState() {
    super.initState();
    timer = Timer(
      const Duration(seconds: 1),
      () async {
        print('getting token');
        await widget.user.reload();
        if (!widget.user.emailVerified) return;
        String? token = await FirebaseAuth.instance.currentUser?.getIdToken(true);
        print('token: $token');
      },
    );
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: SizedBox(
            width: 500,
            child: ColumnSeparated(
              spacing: 16,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(TablerIcons.mail_opened),
                Text('Email Verification Sent', style: Theme.of(context).textTheme.headlineLarge),
                const Text('Thank you! A verification link has been sent to your email account. Please verify your email to access the resident portal.'),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () {
                      sendEmailVerification(context, widget.user);
                    },
                    child: const Padding(
                      padding: EdgeInsets.all(8),
                      child: Text('RESEND'),
                    ),
                  ),
                ),
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () {
                      // Navigator.pop(context);
                      FirebaseAuth.instance.signOut();
                    },
                    child: const Padding(
                      padding: EdgeInsets.all(8),
                      child: Text('BACK TO HOMEPAGE'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ResidentTopPage extends StatefulWidget {
  const ResidentTopPage({
    super.key,
  });

  @override
  State<ResidentTopPage> createState() => _ResidentTopPageState();
}

class _ResidentTopPageState extends State<ResidentTopPage> {
  PageController? pageController;
  Timer? timer;

  final ScrollController scrollController = ScrollController();

  void runTimer(int length) {
    timer = Timer.periodic(
      const Duration(seconds: 3),
      (timer) {
        if ((pageController?.page?.toInt() ?? 0) == length) {
          pageController?.animateToPage(0, duration: const Duration(milliseconds: 200), curve: Curves.fastOutSlowIn);
        } else {
          pageController?.nextPage(duration: const Duration(milliseconds: 200), curve: Curves.fastOutSlowIn);
        }
      },
    );
  }

  @override
  void dispose() {
    timer?.cancel;
    pageController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        bool isPortrait = constraints.maxWidth < constraints.maxHeight;

        return Scaffold(
          body: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    image: DecorationImage(image: AssetImage('images/bg.png'), fit: BoxFit.cover),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox.square(dimension: 400, child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10), child: Image.asset('images/logo.png'))),
                      const Text(
                        'Barangay Bagbag',
                        style: TextStyle(
                          fontSize: 40,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 30),
                        child: SizedBox(
                          width: 1000,
                          child: Text(
                            'Welcome to the Barangay Bagbag Web App—a modern platform designed to streamline services and keep our community connected. Easily request documents, report incidents, and stay updated with the latest news and announcements. Our goal is to make your interactions with the barangay more efficient, accessible, and transparent.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              height: 1.5,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      FilledButton(
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => ResidentLoginPage()));
                        },
                        child: const Padding(
                          padding: EdgeInsets.all(20),
                          child: Text('SIGN IN'),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: isPortrait ? 16 : 100, vertical: 100),
                  child: ColumnSeparated(
                    spacing: 16,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Container(
                          // constraints: const BoxConstraints.expand(),
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Theme.of(context).colorScheme.secondaryContainer),
                          ),
                          child: const ColumnSeparated(
                            spacing: 16,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'HISTORICAL BACKGROUND OF BAGBAG',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'The term Bagbag originated from a large, mountainous place with hard adobe rocks, which when flattened to give way for early settlement produced a loud thudding sound bag – bag! Thence became Bagbag that has been existing since the Spanish era when the local head was the cabeza de barangay. The first of which was Vicente Bernardino. The term then has evolved into tiniente del barrio which later on became kapitan del barrio or barangay captain/barangay chairman, a position that was first handled by Reynaldo B. Llegado, Sr. during the Martial Law years. With the assumption to power of the late president Corazon Aquino, Dr. Beatriz Carreon was appointed OIC by the transition government. \n\nIn 1989, the first post – Martial Law elections was held, wherein Reynaldo B. Llegado won, serving from 1989 – 1994, followed by Renato R. Roque (1994 – 1997), then Constancia V. Ambita (1997 – 2001) and a short stint by Renato R. Roque.\n\nIn the barangay elections of 2002, Carlito R. Bernardino won, serving from 2002 – 2013. The barangay elections of 2013 brought a new leadership in the person of the incumbent Richard V. Ambita who has achieved a landslide approval of Bagbagueños in the 2018 barangay elections.',
                                textAlign: TextAlign.justify,
                                style: TextStyle(height: 2),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: IntrinsicHeight(
                          child: isPortrait
                              ? ColumnSeparated(
                                  spacing: 16,
                                  children: [
                                    Expanded(
                                      child: Container(
                                        constraints: const BoxConstraints.expand(),
                                        padding: const EdgeInsets.all(20),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(color: Theme.of(context).colorScheme.secondaryContainer),
                                        ),
                                        child: const ColumnSeparated(
                                          spacing: 16,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              'MITHIIN',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Text(
                                              'Ang pagpapanday ng ganap at makataong pamamahala at pagpapalago ng lokal na ekonomiya sa pamamagitan ng makatotohanang paglilingkod na may bukas na pamamahala, pananagutan at walang itinatago. Isang barangay na binibigyang-pagpapahalaga ang sariling kasarinlan, iba’t ibang paniniwala, socio- cultural, ekonomiya, kalikasan at tunay na makataong pagganap sa pamamagitan ng pakikipag-ugnayan sa mga samahang-masa at mga institusyong katuwang sa pagtugon sa pagpapaunlad ng ekonomiya.',
                                              textAlign: TextAlign.justify,
                                              style: TextStyle(height: 2),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Container(
                                        constraints: const BoxConstraints.expand(),
                                        padding: const EdgeInsets.all(20),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(color: Theme.of(context).colorScheme.secondaryContainer),
                                        ),
                                        child: const ColumnSeparated(
                                          spacing: 16,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              'PANGARAP',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Text(
                                              'Isang barangay na may matatag na katayuan at malusog na mamamayan; Mayroong mga aktibo at malakas na samahang-masa, na lumalahok sa pamamahala tungo sa kasarinlan; Na namumuhay sa mapayapa, progresibo, maka-Diyos at maka-kalikasang komunidad, tungo sa makataong pag-unlad.',
                                              textAlign: TextAlign.justify,
                                              style: TextStyle(height: 2),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              : RowSeparated(
                                  spacing: 16,
                                  children: [
                                    Expanded(
                                      child: Container(
                                        constraints: const BoxConstraints.expand(),
                                        padding: const EdgeInsets.all(20),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(color: Theme.of(context).colorScheme.secondaryContainer),
                                        ),
                                        child: const ColumnSeparated(
                                          spacing: 16,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              'MITHIIN',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Text(
                                              'Ang pagpapanday ng ganap at makataong pamamahala at pagpapalago ng lokal na ekonomiya sa pamamagitan ng makatotohanang paglilingkod na may bukas na pamamahala, pananagutan at walang itinatago. Isang barangay na binibigyang-pagpapahalaga ang sariling kasarinlan, iba’t ibang paniniwala, socio- cultural, ekonomiya, kalikasan at tunay na makataong pagganap sa pamamagitan ng pakikipag-ugnayan sa mga samahang-masa at mga institusyong katuwang sa pagtugon sa pagpapaunlad ng ekonomiya.',
                                              textAlign: TextAlign.justify,
                                              style: TextStyle(height: 2),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Container(
                                        constraints: const BoxConstraints.expand(),
                                        padding: const EdgeInsets.all(20),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(color: Theme.of(context).colorScheme.secondaryContainer),
                                        ),
                                        child: const ColumnSeparated(
                                          spacing: 16,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              'PANGARAP',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Text(
                                              'Isang barangay na may matatag na katayuan at malusog na mamamayan; Mayroong mga aktibo at malakas na samahang-masa, na lumalahok sa pamamahala tungo sa kasarinlan; Na namumuhay sa mapayapa, progresibo, maka-Diyos at maka-kalikasang komunidad, tungo sa makataong pag-unlad.',
                                              textAlign: TextAlign.justify,
                                              style: TextStyle(height: 2),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
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

                            pageController = PageController();

                            runTimer(announcements.length - 1);

                            return PageView.builder(
                              padEnds: false,
                              controller: pageController,
                              itemCount: announcements.length,
                              itemBuilder: (context, index) {
                                Announcement announcement = announcements[index];

                                return AnnouncementCard(announcement: announcement);
                              },
                            );
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Container(
                          // constraints: const BoxConstraints.expand(),
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Theme.of(context).colorScheme.secondaryContainer),
                          ),
                          child: ColumnSeparated(
                            spacing: 16,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                'BARANGAY BAGBAG MAP',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: Image.network(
                                  'https://barangaybagbag.com/wp-content/uploads/2022/12/new-map-bagbag-1536x922.png',
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
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

                            return Row(
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
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                // Footer
                Container(
                  color: Theme.of(context).colorScheme.secondaryContainer,
                  padding: EdgeInsets.all(isPortrait ? 16 : 50),
                  child: isPortrait
                      ? Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox.square(dimension: 100, child: Image.network('https://firebasestorage.googleapis.com/v0/b/brgy-bagbag.appspot.com/o/logo%2Fbagbaglogo.png?alt=media&token=9f8c82d1-88e0-4424-b9fe-68dd8033e1b5')),
                            SizedBox.square(dimension: 100, child: Image.network('https://firebasestorage.googleapis.com/v0/b/brgy-bagbag.appspot.com/o/logo%2Fqclogo.png?alt=media&token=7df3863f-d831-44eb-bdf7-3789a4f4a456')),
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text(
                                    'Quick Links',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                TextButton.icon(
                                  onPressed: () => launchUrl(Uri.parse('https://qceservices.quezoncity.gov.ph/')),
                                  icon: const Icon(TablerIcons.world),
                                  label: const Text(
                                    'Quezon City Website',
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                TextButton.icon(
                                  onPressed: () => launchUrl(Uri.parse('https://www.facebook.com/QCGov/')),
                                  icon: const Icon(TablerIcons.brand_facebook),
                                  label: const Text(
                                    'Quezon City Facebook',
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                TextButton.icon(
                                  onPressed: () => launchUrl(Uri.parse('https://www.facebook.com/barangaybagbagQCD5')),
                                  icon: const Icon(TablerIcons.brand_facebook),
                                  label: const Text(
                                    'Barangay Bagbag Facebook',
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                            ),
                            const Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text(
                                    'Contact Us',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Text(
                                  'barangaybagbag@gmail.com\nbagbagsecretariat@gmail.com\nHotline - 0998 3333 463\nDirect line - 89527011\nTrunk line - 87787783\n625 Pagkabuhay Road, Barangay Bagbag, Novaliches, Quezon City, Philippines',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 12),
                                ),
                              ],
                            )
                          ],
                        )
                      : Row(
                          children: [
                            SizedBox.square(dimension: 100, child: Image.network('https://firebasestorage.googleapis.com/v0/b/brgy-bagbag.appspot.com/o/logo%2Fbagbaglogo.png?alt=media&token=9f8c82d1-88e0-4424-b9fe-68dd8033e1b5')),
                            Expanded(
                              child: Center(
                                child: Row(
                                  children: [
                                    Expanded(
                                        child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Padding(
                                          padding: EdgeInsets.all(8.0),
                                          child: Text(
                                            'Quick Links',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        TextButton.icon(
                                          onPressed: () => launchUrl(Uri.parse('https://qceservices.quezoncity.gov.ph/')),
                                          icon: const Icon(TablerIcons.world),
                                          label: const Text(
                                            'Quezon City Website',
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                        TextButton.icon(
                                          onPressed: () => launchUrl(Uri.parse('https://www.facebook.com/QCGov/')),
                                          icon: const Icon(TablerIcons.brand_facebook),
                                          label: const Text(
                                            'Quezon City Facebook',
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                        TextButton.icon(
                                          onPressed: () => launchUrl(Uri.parse('https://www.facebook.com/barangaybagbagQCD5')),
                                          icon: const Icon(TablerIcons.brand_facebook),
                                          label: const Text(
                                            'Barangay Bagbag Facebook',
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ],
                                    )),
                                    const Expanded(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Padding(
                                            padding: EdgeInsets.all(8.0),
                                            child: Text(
                                              'Contact Us',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          Text(
                                            'barangaybagbag@gmail.com\nbagbagsecretariat@gmail.com\nHotline - 0998 3333 463\nDirect line - 89527011\nTrunk line - 87787783\n625 Pagkabuhay Road, Barangay Bagbag, Novaliches, Quezon City, Philippines',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(fontSize: 12),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox.square(dimension: 100, child: Image.network('https://firebasestorage.googleapis.com/v0/b/brgy-bagbag.appspot.com/o/logo%2Fqclogo.png?alt=media&token=7df3863f-d831-44eb-bdf7-3789a4f4a456')),
                          ],
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
