import 'dart:collection';
import 'package:dark_souls_checklist/AllPageFutureBuilder.dart';
import 'package:dark_souls_checklist/DatabaseManager.dart';
import 'package:dark_souls_checklist/ItemTile.dart';
import 'package:dark_souls_checklist/MyAppBar.dart';
import 'package:dark_souls_checklist/main.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:provider/provider.dart';
import 'package:simple_rich_md/simple_rich_md.dart';
import '../Singletons.dart';
import 'package:dark_souls_checklist/Generated/playthrough_d_s3_c_generated.dart'
    as fb;
import '../CacheManager.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class Playthrough extends StatefulWidget {
  @override
  _PlaythroughState createState() => _PlaythroughState();
}

class _PlaythroughState extends State<Playthrough> {
  late DatabaseManager<List<HashMap<int, bool>>> _db;
  late List<fb.Playthrough> _flat;
  int _initialIndex = Prefs.inst.getInt("PLAYTHROUGH-LAST-TAB") ?? 0;

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

  Future<int> setup(BuildContext context, MyModel value) async {
    _db = await CacheManager.getOrInit(CacheManager.PLAYTHROUGH_DB, () async {
      final db = DatabaseManager(expensiveComputation, DbFor.Playthrough);
      await db.openDbAndParse();
      return db;
    });

    _flat = await CacheManager.getOrInit(CacheManager.PLAYTHROUGH_FLATBUFFER,
        () async {
      final data = await DefaultAssetBundle.of(context)
          .load("${value.flatbuffersPath!}/playthrough.fb");
      return fb.PlaythroughRoot(data.buffer.asInt8List()).items;
    });
    return 1;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MyModel>(builder: (context, value, child) {
      return AllPageFutureBuilder<int>(
        future: setup(context, value),
        buildOnLoad: (context, snapshot) {
          return DefaultTabController(
            initialIndex: _initialIndex,
            length: _flat.length,
            child: PtScaffold(
              db: _db,
              flat: _flat,
            ),
          );
        },
      );
    });
  }
}

class PtScaffold extends StatefulWidget {
  final DatabaseManager<List<HashMap<int, bool>>> db;
  final List<fb.Playthrough> flat;

  const PtScaffold({Key? key, required this.db, required this.flat})
      : super(key: key);

  @override
  _PtScaffoldState createState() => _PtScaffoldState();
}

class _PtScaffoldState extends State<PtScaffold> {
  bool _hideCompleted = false;

  @override
  void initState() {
    super.initState();
    _hideCompleted = Prefs.inst.getBool("Playthrough") ?? _hideCompleted;
  }

  void _updateChecked(int locationId, int taskId, bool newVal) async {
    setState(() {
      widget.db.checked![locationId][taskId] = newVal;
    });
    await widget.db.updateRecord([newVal, taskId, locationId]);
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: MyAppBar(
        prefSize: Size.fromHeight(80),
        bottom: TabsForAppBar(
          tabs: widget.flat.map((loc) {
            String text = loc.location.name!;
            if (loc.location.note != null) {
              text = "$text ${loc.location.note}";
            }
            return Text(
              text,
            );
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
        categoriesLength: widget.flat.length,
        categoryBuilder: (context, locationId) {
          return ListView.builder(
            itemCount: widget.flat[locationId].tasks.length,
            itemBuilder: (context, taskIdx) {
              final bool isChecked = widget.db.checked![locationId][taskIdx]!;
              final String taskText =
                  widget.flat[locationId].tasks[taskIdx].text;
              return PtTile(
                isChecked: isChecked,
                isVisible: !(_hideCompleted && isChecked),
                text: taskText,
                onChanged: (newVal) {
                  _updateChecked(locationId, taskIdx, newVal!);
                },
              );
            },
          );
        },
      ),
    );
  }
}

class PtTile extends StatelessWidget {
  final void Function(bool?)? onChanged;
  final bool isVisible;
  final bool isChecked;
  final String text;
  const PtTile(
      {Key? key,
      required this.onChanged,
      required this.isChecked,
      required this.isVisible,
      required this.text})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ItemTile(
      isVisible: isVisible,
      isChecked: isChecked,
      title: SimpleRichMd(
        text: text,
        onTap: openLink,
        linkStyle: getLinkTextStyle(),
        textStyle: Theme.of(context).textTheme.bodyText2,
      ),
      // MarkdownBody(
      //   data: text,
      //   onTapLink: openLink,
      //   styleSheet: MarkdownStyleSheet(
      //       a: getLinkTextStyle(), p: Theme.of(context).textTheme.bodyText2),
      // ),
      onChanged: onChanged,
    );
  }
}
