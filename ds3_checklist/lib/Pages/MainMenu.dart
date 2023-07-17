import 'package:dark_souls_checklist/Pages/Achievements/Achievements.dart';
import 'package:dark_souls_checklist/Pages/Armor.dart';
import 'package:dark_souls_checklist/Pages/Souls.dart';
import 'package:dark_souls_checklist/Pages/Trades.dart';
import 'package:flutter/material.dart';
import 'package:dark_souls_checklist/Pages/Playthrought.dart';
import 'package:dark_souls_checklist/Pages/WeaponsAndShields.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class MenuBlock extends StatelessWidget {
  final String title;
  final Widget navigate;
  MenuBlock({required this.title, required this.navigate});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => navigate,
        ),
      ),
      child: buildCardTiles(context),
    );
  }

  Card buildCardTiles(BuildContext context) {
    return Card(
        margin: EdgeInsets.only(top: 5, bottom: 5, right: 25, left: 25),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5),
          child: Center(
            child: Text(
              title,
              style: Theme.of(context).textTheme.labelLarge,
            ),
          ),
        ));
  }
}

List<Widget> makeMenuTiles(BuildContext context) {
  final loc = AppLocalizations.of(context)!;
  return [
    Image(
      image: AssetImage("assets/images/bonfire.gif"),
      fit: BoxFit.cover,
    ),
    SizedBox(
      height: 10,
    ),
    Expanded(
        child: MenuBlock(
            title: loc.playthroughPageTitle, navigate: Playthrough())),
    Expanded(
        child: MenuBlock(
            title: loc.achievementsPageTitle, navigate: Achievements())),
    Expanded(
        child: MenuBlock(
            title: loc.weaponsShieldsPageTitle, navigate: WeaponsAndShield())),
    Expanded(child: MenuBlock(title: loc.armorPageTitle, navigate: Armor())),
    Expanded(child: MenuBlock(title: loc.tradesPageTitle, navigate: Trades())),
    Expanded(child: MenuBlock(title: loc.soulPrices, navigate: Souls())),
    SizedBox(
      height: 10,
    )
  ];
}

class MainMenu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final tiles = makeMenuTiles(context);
    return SafeArea(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.max,
      children: tiles,
    ));
  }
}
