import 'dart:convert';
import 'package:dark_souls_checklist/DatabaseManager.dart';
import 'package:dark_souls_checklist/MyAppBar.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import '../ItemTile.dart';
import '../Models/WeaponsAndShieldsModel.dart' as My;
import '../Singletons.dart';

const String TITLE = "Weapons and Shields";

class WeaponsAndShield extends StatefulWidget {
  static void resetStatics() {
    _WeaponsAndShieldState.db.reset();
    _WeaponsAndShieldState.model = null;
  }

  @override
  _WeaponsAndShieldState createState() => _WeaponsAndShieldState();
}

List<Map<int, bool>> expensiveComputation(List dbResp) {
  print("(expensive) Running computation");
  final int maxIdx = dbResp.last["cat_id"] + 1;
  List<Map<int, bool>> checked = List.generate(maxIdx, (index) => Map());
  for (var line in dbResp) {
    checked[(line["cat_id"] as int)][(line["task_id"] as int)] =
        (line["is_checked"] as int) != 0;
  }
  return checked;
}

bool _hideCompleted = false;

class _WeaponsAndShieldState extends State<WeaponsAndShield> {
  static My.WaSModel? model;
  static DatabaseManager db =
      DatabaseManager(expensiveComputation, DbFor.WeapsShields);

  @override
  void initState() {
    super.initState();
    _hideCompleted = Prefs.inst.getBool(TITLE) ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60),
        child: MyAppBar(
          title: TITLE,
          onHideButton: (newVal) {
            setState(() {
              _hideCompleted = newVal;
            });
          },
        ),
      ),
      body: Container(
        child: FutureBuilder(
            future: Future.wait([
              db.openDbAndParse(),
              () async {
                if (model == null) {
                  var js = await DefaultAssetBundle.of(context)
                      .loadString('assets/json/weapons_and_shields.json');
                  model = My.WaSModel.fromJson(json.decode(js));
                }
              }()
            ]),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Text("Error");
              } else if (snapshot.hasData) {
                return ListView.builder(
                    shrinkWrap: true,
                    itemCount: model?.categories.length,
                    itemBuilder: (context, index) {
                      return ExpandableTile(
                          model: model!, index: index, db: db);
                    });
              } else {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }
            }),
      ),
    );
  }
}

class ExpandableTile extends StatefulWidget {
  final My.WaSModel model;
  final int index;
  final DatabaseManager db;

  const ExpandableTile({
    Key? key,
    required this.model,
    required this.index,
    required this.db,
  }) : super(key: key);
  @override
  _ExpandableTileState createState() => _ExpandableTileState();
}

class _ExpandableTileState extends State<ExpandableTile> {
  int catIdx = 0;

  void _updateChecked(int catId, int taskId, bool newVal) async {
    setState(() {
      widget.db.checked[catId][taskId] = newVal;
    });
    widget.db.updateRecord([newVal, taskId, catId]);
  }

  @override
  void initState() {
    catIdx = widget.index;
    super.initState();
  }

  List<Widget> _buildExpandableContent(My.Category cat, int catIdx) {
    List<Widget> widgets = [];
    for (int taskId = 0; taskId < cat.items.length; ++taskId) {
      bool isChecked = widget.db.checked[catIdx][taskId];
      widgets.add(ItemTile(
        isVisible: !(_hideCompleted && isChecked),
        onChanged: (newVal) {
          _updateChecked(catIdx, taskId, newVal!);
        },
        isChecked: isChecked,
        content: HtmlWidget(
          cat.items[taskId].name,
          textStyle: Theme.of(context).textTheme.bodyText2,
        ),
      ));
    }
    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      title: HtmlWidget(
        widget.model.categories[catIdx].name,
        textStyle: Theme.of(context).textTheme.headline2,
      ),
      children: <Widget>[
        Column(
          children:
              _buildExpandableContent(widget.model.categories[catIdx], catIdx),
        )
      ],
    );
  }
}
