import 'dart:collection';
import 'dart:convert';
import 'package:dark_souls_checklist/Pages/Achievements/AchievementPage.dart';
import 'package:dark_souls_checklist/Models/AchievementsModel.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:dark_souls_checklist/DatabaseManager.dart';

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
  AssetImage('assets/images/dlcs.webp'),
  AssetImage('assets/images/dlcs.webp'),
];

const String TITLE = "Achievements";

List<HashMap<int, bool>> expensiveComputation(
    List<Map<String, dynamic>> dbResp) {
  print("(expensive) Running computation");
  final int maxIdx = dbResp.last["ach_id"] + 1;
  List<HashMap<int, bool>> checked = List.generate(maxIdx, (i) => HashMap());

  for (var line in dbResp) {
    checked[(line["ach_id"] as int)][(line["task_id"] as int)] =
        (line["is_checked"] as int) != 0;
  }
  return checked;
}

class Achievements extends StatefulWidget {
  static void resetStatics() {
    _AchievementsState.db.reset();
    _AchievementsState.achs = null;
  }

  @override
  _AchievementsState createState() => _AchievementsState();
}

class _AchievementsState extends State<Achievements> {
  static DatabaseManager db =
      DatabaseManager(expensiveComputation, DbFor.Achievements);

  static List<Achievement>? achs;

  int titleIndex = 0;

  @override
  void initState() {
    print("called InitState");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          TITLE,
          style: Theme.of(context).appBarTheme.textTheme?.caption,
        ),
      ),
      body: FutureBuilder(
        future: Future.wait([
          db.openDbAndParse(),
          () async {
            if (achs == null) {
              var js = await DefaultAssetBundle.of(context)
                  .loadString('assets/json/achievements.json');
              achs = AchsModel.fromJson(json.decode(js));
            }
          }()
        ]),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text("Error");
          } else if (snapshot.hasData) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Spacer(),
                GridView.builder(
                  shrinkWrap: true,
                  itemCount: achs!.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3),
                  itemBuilder: (context, achIdx) {
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (bc) => AchievementPage(
                                  db: db,
                                  achId: achIdx,
                                  achs: achs!,
                                  appBarTitleWidget: Hero(
                                      tag: achIdx + 100,
                                      child: FittedBox(
                                        fit: BoxFit.cover,
                                        child: Text(
                                          achs![achIdx].name,
                                          style: Theme.of(context)
                                              .textTheme
                                              .headline3,
                                        ),
                                      )),
                                  heroTag: achIdx,
                                  image: IMAGES[achIdx]),
                            ));
                      },
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
                                    tag: achIdx,
                                    child: Image.asset(IMAGES[achIdx].assetName,
                                        fit: BoxFit.fitWidth)),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      bottom: 10.0, right: 5, left: 5),
                                  child: Align(
                                    alignment: Alignment.bottomCenter,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        //color: Color.fromARGB(64, 0, 0, 0),
                                      ),
                                      child: Hero(
                                        tag: achIdx + 100,
                                        child: Text(
                                          achs![achIdx].name,
                                          textAlign: TextAlign.center,
                                          style: Theme.of(context)
                                              .textTheme
                                              .headline4,
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
    );
  }
}
