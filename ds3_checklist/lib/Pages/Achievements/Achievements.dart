import 'dart:collection';
import 'package:dark_souls_checklist/CacheManager.dart';
import 'package:dark_souls_checklist/Pages/Achievements/AchievementPage.dart';
import 'package:dark_souls_checklist/main.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:dark_souls_checklist/DatabaseManager.dart';
import 'package:dark_souls_checklist/Generated/achievements_d_s3_c_generated.dart'
    as fb;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

const _DLCS = AssetImage('assets/images/dlcs.webp');
const IMAGES = [
  AssetImage('assets/images/master_of_expression.webp'),
  AssetImage('assets/images/master_of_sorceries.webp'),
  AssetImage('assets/images/master_of_pyromancies.webp'),
  AssetImage('assets/images/master_of_miracles.webp'),
  AssetImage('assets/images/master_of_infusion.webp'),
  AssetImage('assets/images/ending_achievements.webp'),
  AssetImage('assets/images/boss_achievements.webp'),
  AssetImage('assets/images/misc_achievements.webp'),
  AssetImage('assets/images/covenant_achievements.webp'),
  AssetImage('assets/images/master_of_rings.webp'),
  _DLCS,
  _DLCS,
];

List<HashMap<int, bool>> expensiveComputation(
    List<Map<String, dynamic>> dbResp) {
  print("(expensive) Running computation");
  final int maxIdx = dbResp.last["ach_id"]! + 1;
  List<HashMap<int, bool>> checked = List.generate(maxIdx, (i) => HashMap());

  for (var line in dbResp) {
    checked[(line["ach_id"]! as int)][(line["task_id"]! as int)] =
        (line["is_checked"]! as int) != 0;
  }
  return checked;
}

class Achievements extends StatefulWidget {
  static void resetStatics() {
    // TODO:
    // _AchievementsState.db.reset();
    // _AchievementsState.achs = null;
  }

  @override
  _AchievementsState createState() => _AchievementsState();
}

class _AchievementsState extends State<Achievements> {
  late DatabaseManager<List<HashMap<int, bool>>> db =
      DatabaseManager(expensiveComputation, DbFor.Achievements);
  late List<fb.Achievement> achs;
  // static List<Achievement>? achs;

  int titleIndex = 0;

  Future setup(MyModel value) async {
    db = await CacheManager.getOrInit(CacheManager.ACH_DB, () async {
      final db = DatabaseManager(expensiveComputation, DbFor.Achievements);
      await db.openDbAndParse();
      return db;
    });

    achs = await CacheManager.getOrInit(CacheManager.ACH_FLATBUFFER, () async {
      final data = await DefaultAssetBundle.of(context)
          .load("${value.flatbuffersPath}/achievements.fb");
      return fb.AchievementsRoot(data.buffer.asInt8List()).items!;
    });
    return 1;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.achievementsPageTitle,
          style: Theme.of(context).appBarTheme.textTheme?.headline6,
        ),
      ),
      body: Consumer<MyModel>(
        builder: (context, value, child) => FutureBuilder(
          future: setup(value),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Text("Error: ${snapshot.error}");
            } else if (snapshot.hasData) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Spacer(),
                  GridView.builder(
                    shrinkWrap: true,
                    itemCount: achs.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3),
                    itemBuilder: (context, achId) {
                      return AchButton(achs: achs, db: db, achId: achId);
                    },
                    physics: NeverScrollableScrollPhysics(),
                  ),
                  Spacer(),
                ],
              );
            } else {
              return Center(child: CircularProgressIndicator());
            }
          },
        ),
      ),
    );
  }
}

class AchButton extends StatelessWidget {
  const AchButton({
    Key? key,
    required this.achs,
    required this.db,
    required this.achId,
  }) : super(key: key);
  final int achId;
  final List<fb.Achievement> achs;
  final DatabaseManager<List<HashMap<int, bool>>> db;

  void onTap(BuildContext context) {
    final selAch = achs[achId];
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (bc) => AchievementPage(
              db: db,
              achId: achId,
              ach: selAch,
              appBarTitleWidget: Hero(
                  tag: achId + 100,
                  child: FittedBox(
                    fit: BoxFit.cover,
                    child: Text(
                      selAch.name,
                      // style: Theme.of(context).textTheme.headline3,
                    ),
                  )),
              heroTag: achId,
              image: IMAGES[achId]),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onTap(context),
      child: Card(
        elevation: 5,
        color: Colors.grey[400],
        margin: EdgeInsets.all(8),
        child: Padding(
          padding: const EdgeInsets.all(5.0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Hero(
                    tag: achId,
                    child: Image.asset(IMAGES[achId].assetName,
                        fit: BoxFit.fitWidth)),
                Padding(
                  padding:
                      const EdgeInsets.only(bottom: 10.0, right: 5, left: 5),
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Hero(
                        tag: achId + 100,
                        flightShuttleBuilder:
                            (context, anim, _, context1, context2) {
                          return DefaultTextStyle(
                            style: DefaultTextStyle.of(context2).style,
                            child: context2.widget,
                          );
                        },
                        child: Text(
                          achs[achId].name,
                          textAlign: TextAlign.center,
                          style: Theme.of(context)
                              .textTheme
                              .button
                              ?.copyWith(fontSize: 12),
                          maxLines: 2,
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
