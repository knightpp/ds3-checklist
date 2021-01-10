import 'dart:collection';
import 'package:dark_souls_checklist/AllPageFutureBuilder.dart';
import 'package:dark_souls_checklist/DatabaseManager.dart';
import 'package:dark_souls_checklist/ItemTile.dart';
import 'package:dark_souls_checklist/MyAppBar.dart';
import 'package:dark_souls_checklist/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../Singletons.dart';
import 'package:dark_souls_checklist/Generated/playthrough_d_s3_c_generated.dart'
    as fb;
import '../CacheManager.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

enum Cached {
  Flatbuffer,
  Database,
}

extension Id on Cached {
  String uniqueStr() {
    switch (this) {
      case Cached.Flatbuffer:
        return "Cached.Flatbuffer.Playthrough";
      case Cached.Database:
        return "Cached.Database.Playthrough";
    }
  }
}

class Playthrough extends StatefulWidget {
  @override
  _PlaythroughState createState() => _PlaythroughState();
}

class _PlaythroughState extends State<Playthrough> {
  late DatabaseManager<List<HashMap<int, bool>>> _dbR;
  late List<fb.Playthrough> _flat;
  int _initialIndex = 0;

  bool _hideCompleted = false;
  @override
  void initState() {
    super.initState();
    _hideCompleted = Prefs.inst.getBool("Playthrough") ?? _hideCompleted;
    _initialIndex = Prefs.inst.getInt("PLAYTHROUGH-LAST-TAB") ?? _initialIndex;
  }

  // DbDry get

  static List<HashMap<int, bool>> expensiveComputation(List dbResp) {
    print("(expensive) Running computation");
    int maxIndexOfLocation = dbResp.last["location_id"]! + 1;
    List<HashMap<int, bool>> checked =
        List.generate(maxIndexOfLocation, (i) => HashMap());

    for (var line in dbResp) {
      checked[(line["location_id"]! as int)][(line["task_id"]! as int)] =
          (line["is_checked"]! as int) != 0;
    }
    return checked;
  }

  void _updateChecked(int locationId, int taskId, bool newVal) {
    setState(() {
      _dbR.checked![locationId][taskId] = newVal;
    });
    _dbR.updateRecord([newVal, taskId, locationId]);
  }

  setup(BuildContext context) async {
    _dbR = await CacheManager.getOrInit(Cached.Database.uniqueStr(), () async {
      final db = DatabaseManager(expensiveComputation, DbFor.Playthrough);
      await db.openDbAndParse();
      return db;
    });

    _flat =
        await CacheManager.getOrInit(Cached.Flatbuffer.uniqueStr(), () async {
      final data = await DefaultAssetBundle.of(context)
          .load("assets/flatbuffers/playthrough.fb");
      return fb.PlaythroughRoot(data.buffer.asInt8List()).items;
    });
    return 1;
  }

  @override
  Widget build(BuildContext context) {
    return AllPageFutureBuilder(
      future: setup(context),
      buildOnLoad: (context, snapshot) {
        final loc = AppLocalizations.of(context)!;
        return DefaultTabController(
          initialIndex: _initialIndex,
          length: _flat.length,
          child: Scaffold(
            appBar: MyAppBar(
              prefSize: Size.fromHeight(90),
              bottom: TabsForAppBar(
                tabs: _flat.map((loc) {
                  final name = loc.location.name;
                  String text =
                      name.substring(name.indexOf("[") + 1, name.indexOf("]"));
                  if (loc.location.note != null) {
                    text = "$text ${loc.location.note}";
                  }
                  return Text(
                    text,
                  );
                  // TODO: use links in tabs?
                  // return MarkdownBody(
                  //   styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context))
                  //       .copyWith(
                  //           a: TextStyle(color: Color.fromARGB(255, 0, 0, 0))),
                  //   data: data,
                  //   onTapLink: (text, href, title) {},
                  // );
                }).toList(),
                onChangeTab: (p) async {
                  await Prefs.inst.setInt("PLAYTHROUGH-LAST-TAB", p);
                },
              ),
              title: loc.playthroughPageTitle,
              onHideButton: (newVal) {
                setState(() {
                  _hideCompleted = newVal;
                });
              },
            ),
            body: MyTabBarView(
              categoriesLength: _flat.length,
              categoryBuilder: (context, locationId) {
                return ListView.builder(
                  itemCount: _flat[locationId].tasks.length,
                  itemBuilder: (context, taskIdx) {
                    bool isChecked = _dbR.checked![locationId][taskIdx]!;
                    String taskText = _flat[locationId].tasks[taskIdx].text;
                    return ItemTile(
                      isVisible: !(_hideCompleted && isChecked),
                      isChecked: isChecked,
                      title: MarkdownBody(
                        data: taskText,
                        onTapLink: openLink,
                        styleSheet:
                            MarkdownStyleSheet.fromTheme(Theme.of(context)),
                        // style: .textTheme.bodyText1,
                      ),
                      onChanged: (newVal) {
                        _updateChecked(locationId, taskIdx, newVal!);
                      },
                    );
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }
}
