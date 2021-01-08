import 'package:dark_souls_checklist/Pages/Achievements/Achievements.dart';
import 'package:dark_souls_checklist/Pages/Armor.dart';
import 'package:dark_souls_checklist/Pages/Souls.dart';
import 'package:dark_souls_checklist/Pages/Trades.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:dark_souls_checklist/Pages/Playthrought.dart';
import 'package:dark_souls_checklist/Pages/WeaponsAndShields.dart';

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
              style: Theme.of(context)
                  .textTheme
                  .headline2
                  ?.copyWith(color: Colors.white70),
            ),
          ),
        ));
  }
}

List<Widget> makeMenuTiles(BuildContext context) {
  return [
    Image(
      image: AssetImage("assets/images/bonfire.gif"),
      fit: BoxFit.cover,
    ),
    SizedBox(
      height: 10,
    ),
    Expanded(child: MenuBlock(title: "Playthrough", navigate: Playthrough())),
    Expanded(child: MenuBlock(title: "Achievements", navigate: Achievements())),
    Expanded(
        child:
            MenuBlock(title: "Weapons/Shields", navigate: WeaponsAndShield())),
    Expanded(child: MenuBlock(title: "Armor", navigate: Armor())),
    Expanded(child: MenuBlock(title: "Trades", navigate: Trades())),
    Expanded(child: MenuBlock(title: "Soul Prices", navigate: Souls())),
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
