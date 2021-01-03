import 'dart:collection';
import 'package:dark_souls_checklist/AllPageFutureBuilder.dart';
import 'package:dark_souls_checklist/DatabaseManager.dart';
import 'package:dark_souls_checklist/ItemTile.dart';
import 'package:dark_souls_checklist/MyAppBar.dart';
import 'package:flutter/material.dart';
import '../Singletons.dart';
import 'package:dark_souls_checklist/Generated/playthrough.dart' as fb;
import '../CacheManager.dart';

const String TITLE = "Playthrough";

enum Cached {
  Tabs,
  Flatbuffer,
  Database,
}

class Playthrough extends StatefulWidget {
  @override
  _PlaythroughState createState() => _PlaythroughState();
}

class _PlaythroughState extends State<Playthrough> {
  late DatabaseManager _dbR;
  late List<fb.Playthrough> _flat;
  late List<Widget> _tabs;
  int _initialIndex = 0;

  bool _hideCompleted = false;
  @override
  void initState() {
    super.initState();
    _hideCompleted = Prefs.inst.getBool(TITLE) ?? _hideCompleted;
    _initialIndex = Prefs.inst.getInt("PLAYTHROUGH-LAST-TAB") ?? _initialIndex;
  }

  // DbDry get

  static List<HashMap<int, bool>> expensiveComputation(List dbResp) {
    print("(expensive) Running computation");
    int maxIndexOfLocation = dbResp.last["location_id"] + 1;
    List<HashMap<int, bool>> checked =
        List.generate(maxIndexOfLocation, (i) => HashMap());

    for (var line in dbResp) {
      checked[(line["location_id"] as int)][(line["task_id"] as int)] =
          (line["is_checked"] as int) != 0;
    }
    return checked;
  }

  void _updateChecked(int locationId, int taskId, bool newVal) {
    setState(() {
      _dbR.checked[locationId][taskId] = newVal;
    });
    _dbR.updateRecord([newVal, taskId, locationId]);
  }

  Future setUp(BuildContext context) async {
    _dbR = await CacheManager.getOrInit(Cached.Database, () async {
      final db = DatabaseManager(expensiveComputation, DbFor.Playthrough);
      await db.openDbAndParse();
      return db;
    });

    _flat = await CacheManager.getOrInit(Cached.Flatbuffer, () async {
      final data =
          await DefaultAssetBundle.of(context).load("assets/playthrough.fb");
      return fb.PlaythroughRoot(data.buffer.asInt8List()).items;
    });

    _tabs = await CacheManager.getOrInit(Cached.Tabs, () async {
      return _flat.map((loc) {
        var note = loc.location.note;

        if (note == null) {
          return Text(
            "${loc.location.name}",
            style: Theme.of(context).appBarTheme.textTheme?.subtitle1,
          );
        } else {
          return Text(
            "${loc.location.name} ${loc.location.note}",
            style: Theme.of(context).appBarTheme.textTheme?.subtitle1,
          );
        }
      }).toList();
    });

    return true;
  }

  @override
  Widget build(BuildContext context) {
    return AllPageFutureBuilder(
      future: setUp(context),
      buildOnLoad: (context, snapshot) {
        return DefaultTabController(
          initialIndex: _initialIndex,
          length: _flat.length,
          child: Scaffold(
            appBar: MyAppBar(
              prefSize: Size.fromHeight(90),
              bottom: TabsForAppBar(
                tabs: _tabs,
                onChangeTab: (p) async {
                  await Prefs.inst.setInt("PLAYTHROUGH-LAST-TAB", p);
                },
              ),
              title: TITLE,
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
                    bool isChecked = _dbR.checked[locationId][taskIdx];
                    String taskText = _flat[locationId].tasks[taskIdx].text;
                    return ItemTile(
                      isVisible: !(_hideCompleted && isChecked),
                      isChecked: isChecked,
                      title: Text(
                        taskText,
                        style: Theme.of(context).textTheme.bodyText1,
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
