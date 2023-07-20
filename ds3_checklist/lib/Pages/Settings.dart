import 'package:dark_souls_checklist/CacheManager.dart';
import 'package:dark_souls_checklist/DatabaseManager.dart';
import 'package:dark_souls_checklist/Pages/Armor.dart';
import 'package:dark_souls_checklist/Pages/WeaponsAndShields.dart';
import 'package:dark_souls_checklist/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'Trades.dart';
import 'package:provider/provider.dart';

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
            )),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SettingsPage(loc),
      ),
    );
  }
}

class LangButton extends StatelessWidget {
  final String countryCode;
  final bool selected;
  final VoidCallback onTap;

  const LangButton({
    Key? key,
    required this.countryCode,
    required this.onTap,
    this.selected = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Text(
        _getFlagEmoji(countryCode),
        style: TextStyle(fontSize: selected ? 48 : 24),
      ),
    );
  }

  String _getFlagEmoji(String countryCode) =>
      countryCode.toUpperCase().replaceAllMapped(
          RegExp(r'[A-Z]'),
          (match) =>
              String.fromCharCode(match.group(0)!.codeUnitAt(0) + 127397));
}

class SettingsPage extends StatelessWidget {
  final AppLocalizations loc;
  SettingsPage(this.loc);

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: <Widget>[
        LanguageSelector(),
        SizedBox(
          height: 40,
        ),
        ResetRow(
          loc: loc,
          contentText: loc.settingsPlaythroughProgress,
          pressType: PressType.Normal,
          pressCallback: () {
            CacheManager.invalidate(CacheManager.PLAYTHROUGH_DB);
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
          ),
        ),
        Divider(),
        ResetRow(
          loc: loc,
          contentText: loc.settingsAchievementsProgress,
          pressType: PressType.Long,
          pressCallback: () {
            CacheManager.invalidate(CacheManager.ACH_DB);
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

class LanguageSelector extends StatefulWidget {
  const LanguageSelector({
    Key? key,
  }) : super(key: key);

  @override
  _LanguageSelectorState createState() => _LanguageSelectorState();
}

class _LanguageSelectorState extends State<LanguageSelector> {
  @override
  Widget build(BuildContext context) {
    final value = Provider.of<MyModel>(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        LangButton(
          selected: value.currentLocale?.languageCode.startsWith("en") ?? false,
          countryCode: "us",
          onTap: () => value.currentLocale = Locale('en', ''),
        ),
        LangButton(
          selected: value.currentLocale?.languageCode.startsWith("uk") ?? false,
          countryCode: "ua",
          onTap: () => value.currentLocale = Locale('uk', ''),
        ),
        LangButton(
          selected: value.currentLocale?.languageCode.startsWith("fr") ?? false,
          countryCode: "fr",
          onTap: () => value.currentLocale = Locale('fr', ''),
        ),
        LangButton(
          selected: value.currentLocale?.languageCode.startsWith("pl") ?? false,
          countryCode: "pl",
          onTap: () => value.currentLocale = Locale('pl', ''),
        ),
        LangButton(
          selected: value.currentLocale?.languageCode.startsWith("it") ?? false,
          countryCode: "it",
          onTap: () => value.currentLocale = Locale('it', ''),
        ),
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

  void _showConfirmationDialog(BuildContext context) async {
    bool result = false;
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: Text(loc.settingsConfirmationDialogText),
        title: Text(loc.settingsConfirmationDialogTitle
            .replaceFirst("\$contentText", contentText)),
        actions: <Widget>[
          TextButton(
            child: Text(loc.settingsConfirmationDialogAccept),
            onPressed: () {
              result = true;
              Navigator.pop(context);
            },
          ),
          Divider(),
          TextButton(
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
  }

  @override
  Widget build(BuildContext context) {
    VoidCallback _onPressed;
    VoidCallback _onLongPress;

    if (pressType == PressType.Long) {
      _onPressed = () {};
      _onLongPress = () => _showConfirmationDialog(context);
    } else {
      _onPressed = () => _showConfirmationDialog(context);
      _onLongPress = () {};
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Expanded(
          flex: 6,
          child: Text(
            contentText,
            style: TextStyle(fontSize: 16),
          ),
        ),
        Expanded(
          flex: 2,
          child: TextButton(
            onPressed: _onPressed,
            onLongPress: _onLongPress,
            style: TextButton.styleFrom(
              backgroundColor: Color.fromARGB(255, 188, 50, 50),
              foregroundColor: Colors.white,
              textStyle: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
            child: Text(
              loc.settingsResetButtonText,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ),
        )
      ],
    );
  }
}
