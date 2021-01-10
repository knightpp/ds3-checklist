import 'package:dark_souls_checklist/CacheManager.dart';
import 'package:dark_souls_checklist/DatabaseManager.dart';
import 'package:dark_souls_checklist/MyAppBar.dart';
import 'package:dark_souls_checklist/main.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../ItemTile.dart';
import '../Singletons.dart';
import 'package:dark_souls_checklist/Generated/weapons_and_shields_d_s3_c_generated.dart'
    as fb;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

const String WS_FB_KEY = "Cached.Flatbuffer.WS";

class WeaponsAndShield extends StatefulWidget {
  static void resetStatics() {
    _WeaponsAndShieldState.db.reset();
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
  late List<fb.WSCategory> weapsShields;
  static DatabaseManager db =
      DatabaseManager(expensiveComputation, DbFor.WeapsShields);

  @override
  void initState() {
    super.initState();
    _hideCompleted = Prefs.inst.getBool("Weapons and Shields") ?? false;
  }

  Future setup() async {
    await db.openDbAndParse();

    this.weapsShields = await CacheManager.getOrInit(WS_FB_KEY, () async {
      final data = await DefaultAssetBundle.of(context)
          .load('assets/flatbuffers/weapons_and_shields.fb');
      return fb.WeaponsAndShieldsRoot(data.buffer.asInt8List()).items;
    });
    return 1;
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60),
        child: MyAppBar(
          title: loc.weaponsShieldsPageTitle,
          onHideButton: (newVal) {
            setState(() {
              _hideCompleted = newVal;
            });
          },
        ),
      ),
      body: Container(
        child: FutureBuilder(
            future: setup(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Text("Error:\n${snapshot.error}");
              } else if (snapshot.hasData) {
                return ListView.builder(
                    shrinkWrap: true,
                    itemCount: weapsShields.length,
                    itemBuilder: (context, index) {
                      return ExpandableTile(
                          cat: weapsShields[index], index: index, db: db);
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
  final fb.WSCategory cat;
  final int index;
  final DatabaseManager db;

  const ExpandableTile({
    Key? key,
    required this.index,
    required this.db,
    required this.cat,
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

  List<Widget> _buildExpandableContent(fb.WSCategory cat, int catIdx) {
    List<Widget> widgets = [];
    for (int taskId = 0; taskId < cat.items.length; ++taskId) {
      bool isChecked = widget.db.checked[catIdx][taskId];
      widgets.add(ItemTile(
        isVisible: !(_hideCompleted && isChecked),
        onChanged: (newVal) {
          _updateChecked(catIdx, taskId, newVal!);
        },
        isChecked: isChecked,
        content: MarkdownBody(
          onTapLink: openLink,
          data: cat.items[taskId].name,
          // textStyle: Theme.of(context).textTheme.bodyText2,
        ),
      ));
    }
    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      title: MarkdownBody(
        onTapLink: openLink,
        data: widget.cat.name,
        // textStyle: Theme.of(context).textTheme.headline2,
      ),
      children: <Widget>[
        Column(
          children: _buildExpandableContent(widget.cat, catIdx),
        )
      ],
    );
  }
}
