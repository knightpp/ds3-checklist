import 'package:dark_souls_checklist/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:simple_rich_md/simple_rich_md.dart';

class About extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final apploc = AppLocalizations.of(context)!;
    final link =
        "[Dark Souls 3 Cheat Sheet](https://github.com/ZKjellberg/dark-souls-3-cheat-sheet)";
    return Scaffold(
      appBar: AppBar(
        title: Text(apploc.aboutTitle),
        centerTitle: true,
      ),
      body: ListView(
        children: <Widget>[
          makeHeader(apploc.usedResources),
          ListTile(
            title: SimpleRichMd(
              onTap: openLink,
              text: apploc.aboutUsedResource.replaceFirst("\$link", link),
              textStyle: Theme.of(context).textTheme.bodyMedium,
              linkStyle: TextStyle(
                  color: Colors.blue, decoration: TextDecoration.underline),
            ),
            leading: Icon(Icons.recent_actors),
          ),
          makeHeader("Links"),
          ListTile(
            leading: Icon(Icons.translate),
            title: SimpleRichMd(
              text:
                  "[Help us translate!](https://crowdin.com/project/darksouls-3-checklist)",
              onTap: openLink,
              linkStyle: TextStyle(
                  color: Colors.blue, decoration: TextDecoration.underline),
            ),
          ),
          ListTile(
            leading: Icon(Icons.source),
            title: SimpleRichMd(
              text: "[Github link](https://github.com/knightpp/ds3-checklist)",
              onTap: openLink,
              linkStyle: TextStyle(
                  color: Colors.blue, decoration: TextDecoration.underline),
            ),
          ),
          makeHeader("Authors"),
          ListTile(
            leading: Icon(Icons.people),
            title: SimpleRichMd(
              text: "[@Lawliet18](https://github.com/Lawliet18)\n\n" +
                  "[@knightpp](https://github.com/knightpp)",
              onTap: openLink,
              linkStyle: TextStyle(
                  color: Colors.blue, decoration: TextDecoration.underline),
            ),
          ),
          makeHeader("MIT License"),
        ],
      ),
    );
  }

  ListTile buildCreators(String str) {
    return ListTile(
      title: Text(str),
      leading: Icon(Icons.work),
    );
  }

  ListTile makeHeader(String str) {
    return ListTile(
      title: Center(
          child: Text(
        str,
        style: TextStyle(fontSize: 24),
      )),
    );
  }
}
