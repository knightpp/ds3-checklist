import 'package:dark_souls_checklist/CacheManager.dart';
import 'package:dark_souls_checklist/DatabaseManager.dart';
import 'package:dark_souls_checklist/Pages/Armor.dart';
import 'package:dark_souls_checklist/Pages/WeaponsAndShields.dart';
import 'package:dark_souls_checklist/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
  final String asset;
  final String? semanticLabel;
  final bool selected;
  final void Function() onTap;

  const LangButton(
      {Key? key,
      required this.asset,
      this.semanticLabel,
      required this.onTap,
      this.selected = false})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        child: Container(
          decoration: BoxDecoration(
              boxShadow: selected
                  ? [BoxShadow(offset: Offset(0, 0), blurRadius: 2.0)]
                  : null),
          child: SvgPicture.asset(
            asset,
            height: 64,
            semanticsLabel: semanticLabel,
            color: selected ? null : Color.fromARGB(255, 64, 64, 64),
            colorBlendMode: selected ? BlendMode.srcIn : BlendMode.modulate,
          ),
        ),
        onTap: onTap);
  }
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
          selected: value.currentLocale?.languageCode.startsWith("ru") ?? false,
          asset: "assets/icons/ru.svg",
          onTap: () {
            value.currentLocale = Locale('ru', '');
          },
        ),
        LangButton(
          selected: value.currentLocale?.languageCode.startsWith("en") ?? false,
          asset: "assets/icons/gb.svg",
          onTap: () async {
            value.currentLocale = Locale('en', '');
            // final apploc = await AppLocalizations.delegate.load(Locale("en"));
            // Intl.defaultLocale = "en";
          },
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
            // style: ButtonStyle(color),
            // color: Color.fromARGB(255, 188, 50, 50),
            child: Text(
              loc.settingsResetButtonText,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        )
      ],
    );
  }
}
