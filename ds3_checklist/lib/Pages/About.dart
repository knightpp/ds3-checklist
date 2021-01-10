import 'package:dark_souls_checklist/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
          buildListTile(apploc.createdBy),
          buildCreators("@Lawliet18"),
          Divider(),
          buildCreators("@knightpp"),
          Divider(),
          buildListTile(apploc.usedResources),
          ListTile(
            title: MarkdownBody(
              onTapLink: openLink,
              data: apploc.aboutUsedResource.replaceFirst("\$link", link),
            ),
            leading: Icon(Icons.recent_actors),
          ),
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

  ListTile buildListTile(String str) {
    return ListTile(
      title: Center(
          child: Text(
        str,
        style: TextStyle(fontSize: 24),
      )),
    );
  }
}
