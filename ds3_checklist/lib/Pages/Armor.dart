import 'dart:convert';
import 'package:dark_souls_checklist/AllPageFutureBuilder.dart';
import 'package:dark_souls_checklist/ItemTile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:dark_souls_checklist/DatabaseManager.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../MyAppBar.dart';
import '../Models/ArmorModel.dart';
import '../Singletons.dart';

const String TITLE = "Armor";

List<Map<int, bool>> expensiveComputation(List dbResp) {
  print("(expensive) Running computation");
  final int maxIdx = dbResp.last["cat_id"] + 1;
  List<Map<int, bool>> checked = List.generate(maxIdx, (i) => Map());
  for (var line in dbResp) {
    checked[(line["cat_id"] as int)][(line["task_id"] as int)] =
        (line["is_checked"] as int) != 0;
  }
  return checked;
}

bool _hideCompleted = false;

class Armor extends StatefulWidget {
  static void resetStatics() {
    _ArmorState.db.reset();
    _ArmorState.model = null;
  }

  @override
  _ArmorState createState() => _ArmorState();
}

class _ArmorState extends State<Armor> {
  static DatabaseManager db =
      DatabaseManager(expensiveComputation, DbFor.Armor);
  int selectedCatIdx = 0;
  static ArmorModel? model;

  @override
  void initState() {
    super.initState();
    _hideCompleted = Prefs.inst.getBool(TITLE) ?? false;
  }

  void _updateChecked(int catId, int taskId, bool newVal) async {
    setState(() {
      db.checked[catId][taskId] = newVal;
    });
    db.updateRecord([newVal, taskId, catId]);
  }

  @override
  Widget build(BuildContext context) {
    return AllPageFutureBuilder(
        future: Future.wait([
          db.openDbAndParse(),
          () async {
            if (model == null) {
              var js = await DefaultAssetBundle.of(context)
                  .loadString('assets/json/armor.json');
              model = ArmorModel.fromJson(json.decode(js));
            }
          }()
        ]),
        buildOnLoad: (context, snapshot) {
          return DefaultTabController(
            length: model!.categories.length,
            child: Scaffold(
              appBar: MyAppBar(
                onHideButton: (newVal) {
                  setState(() {
                    _hideCompleted = newVal;
                  });
                },
                title: TITLE,
                bottom: TabsForAppBar(
                  tabs: model!.categories.map((cat) => Text(cat.name)).toList(),
                  onChangeTab: (int newTabIdx) {
                    selectedCatIdx = newTabIdx;
                  },
                ),
              ),
              body: MyTabBarView(
                categoriesLength: model!.categories.length,
                categoryBuilder: (context, catIndex) {
                  return ListView.builder(
                    itemBuilder: (context, taskIdx) {
                      bool isChecked = db.checked[catIndex][taskIdx];
                      return ItemTile(
                        isVisible: !(_hideCompleted && isChecked),
                        onChanged: (newVal) {
                          _updateChecked(catIndex, taskIdx, newVal!);
                        },
                        isChecked: isChecked,
                        content: MarkdownBody(
                            data: model!
                                .categories[catIndex].items[taskIdx].name),
                      );
                    },
                    itemCount: model!.categories[catIndex].items.length,
                  );
                },
              ),
            ),
          );
        });
  }
}
