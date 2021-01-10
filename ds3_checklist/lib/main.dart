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

class Constants {
  static const String Settings = "Settings";
  static const String About = "About";

  static const List<String> choices = <String>[Settings, About];
}

void openLink(String text, String href, String title) async {
  if (await canLaunch(href)) {
    await launch(href);
  } else {
    throw "could not launch $href";
  }
}

class MyHome extends StatefulWidget {
  @override
  _MyHomeState createState() => _MyHomeState();
}

class _MyHomeState extends State<MyHome> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          elevation: 5,
          title: Text('Dark Souls III Checklist ',
              overflow: TextOverflow.visible,
              style: Theme.of(context).textTheme.headline3),
          actions: <Widget>[
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: CustomPopupMenu(),
            )
          ],
        ),
        body: MainMenu());
  }
}

main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Prefs.init();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitDown, DeviceOrientation.portraitUp]);
    return MaterialApp(
      supportedLocales: AppLocalizations.supportedLocales, // Add this line
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      home: MyHome(),
      theme: ThemeData(
          fontFamily: "OptimusPrinceps",
          dividerTheme:
              DividerThemeData(color: Colors.black, indent: 10, endIndent: 10),
          scaffoldBackgroundColor: Colors.grey[200],
          primaryColor: Colors.blueGrey,
          appBarTheme: AppBarTheme(
              textTheme: TextTheme(
                  caption: TextStyle(
                      fontSize: 22,
                      fontStyle: FontStyle.normal,
                      fontWeight: FontWeight.bold,
                      color: Colors.white70,
                      wordSpacing: 1.2,
                      letterSpacing: 1.3),
                  subtitle1: TextStyle(
                      fontSize: 18,
                      fontStyle: FontStyle.normal,
                      fontWeight: FontWeight.w600,
                      wordSpacing: 1.1,
                      letterSpacing: 1.1))),
          accentColor: Colors.grey[800],
          cardTheme: CardTheme(
              color: Colors.blueGrey,
              elevation: 3,
              margin: EdgeInsets.only(top: 8, bottom: 8, right: 20, left: 20)),
          primaryIconTheme: IconThemeData(size: 25, color: Colors.white70),
          textTheme: TextTheme(
              headline2: TextStyle(
                fontSize: 20,
                fontStyle: FontStyle.normal,
                fontWeight: FontWeight.w600,
                color: Colors.black54,
              ),
              headline3: TextStyle(
                  fontSize: 20,
                  fontStyle: FontStyle.normal,
                  fontWeight: FontWeight.w600,
                  color: Colors.white70,
                  wordSpacing: 1.2,
                  letterSpacing: 1.2),
              headline4: TextStyle(
                  fontSize: 10,
                  fontStyle: FontStyle.normal,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  letterSpacing: 1.2,
                  wordSpacing: 1.2),
              bodyText1: TextStyle(
                fontFamily: "Montserrat",
                fontSize: 14,
                fontStyle: FontStyle.normal,
                //fontWeight: FontWeight.w600
              ),
              bodyText2: TextStyle(
                fontFamily: "Montserrat",
                fontSize: 16,
                fontStyle: FontStyle.normal,
                //fontWeight: FontWeight.w600,
                letterSpacing: 1,
              ))),
    );
  }
}

class CustomPopupMenu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    void _onSelected(String choice) {
      switch (choice) {
        case Constants.Settings:
          {
            Navigator.of(context)
                .push(MaterialPageRoute(builder: (context) => Settings()));
            break;
          }
        case Constants.About:
          {
            Navigator.of(context)
                .push(MaterialPageRoute(builder: (context) => About()));
            break;
          }
      }
    }

    return PopupMenuButton<String>(
        offset: Offset(0, 20),
        color: Colors.grey[200],
        tooltip: AppLocalizations.of(context)!.mainMenuSettingsPopUp,
        elevation: 3,
        initialValue: Constants.choices[0],
        onSelected: _onSelected,
        itemBuilder: (context) {
          return Constants.choices.map((String choice) {
            return PopupMenuItem(
              child: Text(choice),
              value: choice,
            );
          }).toList();
        });
  }
}
