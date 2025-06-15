import 'dart:ui';

import 'package:brgy_bagbag/admin/home.dart';
import 'package:brgy_bagbag/admin/login.dart';
import 'package:brgy_bagbag/firebase_options.dart';
import 'package:brgy_bagbag/globals.dart';
import 'package:brgy_bagbag/resident/home.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await GoogleFonts.pendingFonts([
    GoogleFonts.notoSans()
  ]);

  // await FirebaseAuth.instance.useAuthEmulator('localhost', 9099);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: darkMode,
      builder: (context, darkModeValue, child) {
        return MaterialApp(
          scrollBehavior: AppScrollBehavior(),
          theme: ThemeData(
            fontFamily: GoogleFonts.notoSans().fontFamily,
            colorScheme: ColorScheme.fromSeed(
              seedColor: primaryColor,
              dynamicSchemeVariant: DynamicSchemeVariant.rainbow,
              brightness: darkModeValue ? Brightness.dark : Brightness.light,
            ),
          ),
          routes: {
            '/': (context) => const ResidentHomePage(),
            '/admin': (context) => ValueListenableBuilder(
                  valueListenable: isAdminLogin,
                  builder: (context, value, child) {
                    // if (value) return AdminHomePage();
                    return AdminLoginPage();
                  },
                ),
          },
        );
      },
    );
  }
}

class AppScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.trackpad,
      };
}
