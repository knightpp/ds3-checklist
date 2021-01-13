import 'dart:ui';
import 'package:dark_souls_checklist/Pages/About.dart';
import 'package:dark_souls_checklist/Pages/MainMenu.dart';
import 'package:dark_souls_checklist/Pages/Settings.dart';
import 'package:dark_souls_checklist/Singletons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

void openLink(String text, String href, String title) async {
  if (await canLaunch(href)) {
    await launch(href);
  } else {
    throw "could not launch $href";
  }
}

class MyHome extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Scaffold(
        appBar: AppBar(
          elevation: 5,
          title: Text(loc.mainMenuTitle,
              overflow: TextOverflow.visible,
              style: Theme.of(context).appBarTheme.textTheme?.headline6),
          actions: <Widget>[
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: CustomPopupMenu(loc),
            )
          ],
        ),
        body: MainMenu());
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Prefs.init();

  runApp(ChangeNotifierProvider<MyModel>(
    create: (context) => MyModel(),
    child: MyApp(),
  ));
}

class MyModel with ChangeNotifier {
  Locale? _currentLocale;
  Locale? get currentLocale => _currentLocale;
  set currentLocale(Locale? l) {
    _currentLocale = l;
    notifyListeners();
  }
}

TextStyle getLinkTextStyle() {
  return const TextStyle(
      fontFamily: "OptimusPrinceps",
      decoration: TextDecoration.underline,
      color: Colors.black);
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitDown, DeviceOrientation.portraitUp]);
    return Consumer<MyModel>(
        builder: (context, value, child) => MaterialApp(
              locale: value.currentLocale,
              supportedLocales: AppLocalizations.supportedLocales,
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              home: MyHome(),
              theme: getLightThemeData(),
            ));
  }

  ThemeData getLightThemeData() {
    const montserrat = const TextStyle(fontFamily: "Montserrat");
    const optimus = const TextStyle(
        fontFamily: "OptimusPrinceps",
        fontFamilyFallback: ["PlayfairDisplaySC", "AmaticSC", "Montserrat"],
        letterSpacing: 1);
    final textTheme = Typography.blackHelsinki.copyWith(
        button: optimus.copyWith(fontSize: 20, color: Colors.white),
        headline5: optimus,
        subtitle1: optimus,
        bodyText2: montserrat,
        bodyText1: montserrat);
    final primaryTextTheme = Typography.blackHelsinki.copyWith(
        bodyText2: optimus.copyWith(color: Colors.white.withOpacity(0.9)));

    return ThemeData(
      dividerTheme: const DividerThemeData(
          color: Colors.black, indent: 10, endIndent: 10),
      scaffoldBackgroundColor: Colors.grey[200],
      primaryColor: Colors.blueGrey,
      appBarTheme: AppBarTheme(
        textTheme:
            textTheme.copyWith(headline6: optimus.copyWith(fontSize: 18)),
      ),
      tabBarTheme: TabBarTheme(
          indicator: ShapeDecoration(
              shape: Border(
                  bottom: BorderSide(width: 3, color: Colors.blueGrey[50]!))),
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white.withOpacity(0.3),
          labelStyle: optimus,
          unselectedLabelStyle: optimus),
      accentColor: Colors.grey[800],
      cardTheme: const CardTheme(
          color: Colors.blueGrey,
          elevation: 3,
          margin:
              const EdgeInsets.only(top: 8, bottom: 8, right: 20, left: 20)),
      primaryIconTheme: const IconThemeData(size: 25, color: Colors.white70),
      textTheme: textTheme,
      primaryTextTheme: primaryTextTheme,
    );
  }
}

class CustomPopupMenu extends StatelessWidget {
  final AppLocalizations loc;

  const CustomPopupMenu(this.loc, {Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
        offset: Offset(0, 20),
        color: Colors.grey[200],
        tooltip: loc.mainMenuSettingsPopUp,
        elevation: 3,
        onSelected: (choice) {
          if (choice == "settings") {
            Navigator.of(context)
                .push(MaterialPageRoute(builder: (context) => Settings()));
          } else if (choice == "about") {
            Navigator.of(context)
                .push(MaterialPageRoute(builder: (context) => About()));
          } else {
            throw "Warn: not settings nor about = $choice";
          }
        },
        itemBuilder: (context) {
          return [
            PopupMenuItem(
              child: Text(loc.mainMenuItemSettings),
              value: "settings",
            ),
            PopupMenuItem(
              child: Text(loc.mainMenuItemAbout),
              value: "about",
            ),
          ];
        });
  }
}
