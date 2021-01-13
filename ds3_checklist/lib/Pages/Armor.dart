import 'dart:convert';
import 'package:dark_souls_checklist/AllPageFutureBuilder.dart';
import 'package:dark_souls_checklist/CacheManager.dart';
import 'package:dark_souls_checklist/ItemTile.dart';
import 'package:dark_souls_checklist/main.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:dark_souls_checklist/DatabaseManager.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:provider/provider.dart';
import '../MyAppBar.dart';
import '../Singletons.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:dark_souls_checklist/Generated/armor_d_s3_c_generated.dart'
    as fb;

const String ARMORS_KEY = "Cached.Flatbuffer.Armor";

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
    // _ArmorState.db.reset();
  }

  @override
  _ArmorState createState() => _ArmorState();
}

class _ArmorState extends State<Armor> {
  static DatabaseManager db =
      DatabaseManager(expensiveComputation, DbFor.Armor);
  int selectedCatIdx = 0;
  late List<fb.ArmorCategory> armors;

  @override
  void initState() {
    super.initState();
    _hideCompleted = Prefs.inst.getBool("Armor") ?? false;
  }

  void _updateChecked(int catId, int taskId, bool newVal) async {
    setState(() {
      db.checked[catId][taskId] = newVal;
    });
    db.updateRecord([newVal, taskId, catId]);
  }

  Future setup(MyModel value) async {
    await db.openDbAndParse();
    armors = await CacheManager.getOrInit(ARMORS_KEY, () async {
      var data = await DefaultAssetBundle.of(context)
          .load('${value.flatbuffersPath}/armor.fb');

      return fb.ArmorRoot(data.buffer.asInt8List()).items!;
    });
    return 1;
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Consumer<MyModel>(
      builder: (context, value, child) => AllPageFutureBuilder(
          future: setup(value),
          buildOnLoad: (context, snapshot) {
            return DefaultTabController(
              length: armors.length,
              child: Scaffold(
                appBar: MyAppBar(
                  prefSize: Size.fromHeight(80),
                  onHideButton: (newVal) {
                    setState(() {
                      _hideCompleted = newVal;
                    });
                  },
                  title: loc.armorPageTitle,
                  bottom: TabsForAppBar(
                    tabs: armors
                        .map((cat) => Text(
                              cat.category,
                            ))
                        .toList(),
                    onChangeTab: (int newTabIdx) {
                      selectedCatIdx = newTabIdx;
                    },
                  ),
                ),
                body: MyTabBarView(
                  categoriesLength: armors.length,
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
                            onTapLink: openLink,
                            data: armors[catIndex].gears[taskIdx].name,
                            styleSheet: MarkdownStyleSheet(
                                a: getLinkTextStyle().copyWith(fontSize: 18)),
                          ),
                        );
                      },
                      itemCount: armors[catIndex].gears.length,
                    );
                  },
                ),
              ),
            );
          }),
    );
  }
}
