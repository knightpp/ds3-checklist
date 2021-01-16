import 'package:dark_souls_checklist/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
// import 'package:flutter_markdown/flutter_markdown.dart';
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
          buildListTile(apploc.createdBy),
          buildCreators("@Lawliet18"),
          Divider(),
          buildCreators("@knightpp"),
          Divider(),
          buildListTile(apploc.usedResources),
          ListTile(
            title: SimpleRichMd(
              onTap: openLink,
              text: apploc.aboutUsedResource.replaceFirst("\$link", link),
              textStyle: Theme.of(context).textTheme.bodyText2,
              linkStyle: TextStyle(
                  color: Colors.blue, decoration: TextDecoration.underline),
            ),
            // MarkdownBody(
            //   onTapLink: openLink,
            //   data: apploc.aboutUsedResource.replaceFirst("\$link", link),
            // ),
            leading: Icon(Icons.recent_actors),
          ),
          // ListTile(
          // title: Text("Optimus Princeps"),
          // leading: Icon(Icons.font_download),
          // )
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
