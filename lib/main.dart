// @dart=2.9

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

import 'package:csci4100_major_project/helpers/provider_helper.dart';
import 'package:csci4100_major_project/pages/initial_page.dart';
import "package:firebase_core/firebase_core.dart";
import 'package:csci4100_major_project/widgets/app_scaffold.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:csci4100_major_project/pages/loader.dart';
import 'package:geolocator/geolocator.dart';
import 'l10n/l10n.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  Geolocator.requestPermission();
  tz.initializeTimeZones();
  var locations = tz.timeZoneDatabase.locations;

  runApp(MultiProvider(
    providers: [ChangeNotifierProvider(create: (_) => ProviderHelper())],
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Find My SuN",
      supportedLocales: L10n.all,
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate
      ],
      initialRoute: "/",
      theme: ThemeData(
        primaryColor: Color(0xffF2AE5D),
        primarySwatch: Colors.orange,
      ),
      routes: {
        // "/": (context) => context.watch<ProviderHelper>().isLoggedIn
        //     ? Home()
        //     : InitialPage(),
        "/": (context) => InitialPage(),
        "/home": (context) => Loader(),
      },
    ),
  ));
}
