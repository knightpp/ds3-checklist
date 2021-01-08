import 'package:dark_souls_checklist/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class About extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("About"),
        centerTitle: true,
      ),
      body: ListView(
        children: <Widget>[
          buildListTile("Created by"),
          buildCreators("@Lawliet18"),
          Divider(),
          buildCreators("@knightpp"),
          Divider(),
          buildListTile("Used resources"),
          ListTile(
            title: MarkdownBody(
                onTapLink: openLink,
                data:
                    "Checkout [Dark Souls 3 Cheat Sheet](https://github.com/ZKjellberg/dark-souls-3-cheat-sheet) by Zachary Kjellberg"),
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
