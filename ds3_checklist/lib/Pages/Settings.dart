import 'package:dark_souls_checklist/CacheManager.dart';
import 'package:dark_souls_checklist/DatabaseManager.dart';
import 'package:dark_souls_checklist/Pages/Achievements/Achievements.dart';
import 'package:dark_souls_checklist/Pages/Armor.dart';
import 'package:dark_souls_checklist/Pages/Playthrought.dart' as pt;
import 'package:dark_souls_checklist/Pages/WeaponsAndShields.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'Trades.dart';

class Settings extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: FittedBox(
            fit: BoxFit.fitWidth,
            child: Text(
              loc.settingsTitle,
              style: Theme.of(context).appBarTheme.textTheme?.caption,
            )),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SettingsPage(loc),
      ),
    );
  }
}

class SettingsPage extends StatelessWidget {
  final AppLocalizations loc;
  SettingsPage(this.loc);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        ResetRow(
          loc: loc,
          contentText: loc.settingsPlaythroughProgress,
          pressType: PressType.Normal,
          pressCallback: () {
            CacheManager.invalidate(pt.Cached.Database.uniqueStr());
            DatabaseManager.resetDb(0xB16B00B5, DbFor.Playthrough);
          },
        ),
        Divider(),
        ResetRow(
          loc: loc,
          contentText: loc.settingsTradesProgress,
          pressType: PressType.Normal,
          pressCallback: () {
            Trades.resetStatics();
            DatabaseManager.resetDb(0xB16B00B5, DbFor.Trades);
          },
        ),
        Divider(),
        SizedBox(
          height: 40,
        ),
        Text(
          loc.settingsCautionText,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            wordSpacing: 1,
          ),
          maxLines: 1,
        ),
        Divider(),
        ResetRow(
          loc: loc,
          contentText: loc.settingsAchievementsProgress,
          pressType: PressType.Long,
          pressCallback: () {
            Achievements.resetStatics();
            DatabaseManager.resetDb(0xB16B00B5, DbFor.Achievements);
          },
        ),
        Divider(),
        ResetRow(
          loc: loc,
          contentText: loc.settingsWeapsShieldsProgress,
          pressType: PressType.Long,
          pressCallback: () {
            WeaponsAndShield.resetStatics();
            DatabaseManager.resetDb(0xB16B00B5, DbFor.WeapsShields);
          },
        ),
        Divider(),
        ResetRow(
          loc: loc,
          contentText: loc.settingsArmorProgress,
          pressType: PressType.Long,
          pressCallback: () {
            Armor.resetStatics();
            DatabaseManager.resetDb(0xB16B00B5, DbFor.Armor);
          },
        ),
        Divider(),
      ],
    );
  }
}

enum PressType {
  Long,
  Normal,
}

class ResetRow extends StatelessWidget {
  final AppLocalizations loc;
  final String contentText;
  final PressType pressType;
  final VoidCallback pressCallback;
  final SnackBar snackBar;

  ResetRow(
      {Key? key,
      required this.contentText,
      required this.pressType,
      required this.pressCallback,
      required this.loc})
      : snackBar = SnackBar(
          content: Text(loc.settingsResetSuccessful
              .replaceFirst("\$contentText", contentText)),
        ),
        super(key: key);
  @override
  Widget build(BuildContext context) {
    VoidCallback _onPressed;
    VoidCallback _onLongPress;
    VoidCallback logic = () async {
      bool result = false;
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          content: Text(loc.settingsConfirmationDialogText),
          title: Text(loc.settingsConfirmationDialogTitle
              .replaceFirst("\$contentText", contentText)),
          actions: <Widget>[
            FlatButton(
              child: Text(loc.settingsConfirmationDialogAccept),
              onPressed: () {
                result = true;
                Navigator.pop(context);
              },
            ),
            Divider(),
            FlatButton(
              child: Text(loc.settingsConfirmationDialogCancel),
              onPressed: () {
                result = false;
                Navigator.pop(context);
              },
            )
          ],
        ),
      );
      if (result) {
        // update rows in the DB
        pressCallback();
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    };
    if (pressType == PressType.Long) {
      _onPressed = () {};
      _onLongPress = logic;
    } else {
      _onPressed = logic;
      _onLongPress = () {};
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Expanded(
          flex: 7,
          child: Text(
            contentText,
            style: TextStyle(fontSize: 16, letterSpacing: 1.2, wordSpacing: 1),
          ),
        ),
        Expanded(
          flex: 2,
          child: FlatButton(
            onPressed: _onPressed,
            onLongPress: _onLongPress,
            color: Color.fromARGB(255, 188, 50, 50),
            child: Text(
              loc.settingsResetButtonText,
              style: TextStyle(
                color: Colors.black87,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
              maxLines: 1,
              overflow: TextOverflow.visible,
            ),
          ),
        )
      ],
    );
  }
}

// class SwipeDelete extends StatelessWidget {
//   final String text;

//   const SwipeDelete({Key? key, required this.text}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Dismissible(
//       key: UniqueKey(),
//       child: Card(
//         child: Padding(
//           child: Text(text),
//           padding: EdgeInsets.all(15),
//         ),
//       ),
//       confirmDismiss: (direction) {
//         bool result = false;

//         return showDialog(
//           context: context,
//           builder: (context) => AlertDialog(
//             content: Text("Are you sure?"),
//             title: Text("Reset $text"),
//             actions: <Widget>[
//               FlatButton(
//                 child: Text("Yes"),
//                 onPressed: () {
//                   result = true;
//                   Navigator.pop(context);
//                 },
//               ),
//               Divider(),
//               FlatButton(
//                 child: Text("No"),
//                 onPressed: () {
//                   result = false;
//                   Navigator.pop(context);
//                 },
//               )
//             ],
//           ),
//         ).then((value) => result);
//       },
//     );
//   }
// }
