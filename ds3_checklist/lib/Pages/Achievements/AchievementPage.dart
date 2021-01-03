import 'package:dark_souls_checklist/DatabaseManager.dart';
import 'package:dark_souls_checklist/Models/AchievementsModel.dart';
import 'package:dark_souls_checklist/MyAppBar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import '../../ItemTile.dart';
import '../../Singletons.dart';

const String TITLE = "Achievements";

class AchievementPage extends StatefulWidget {
  final Widget appBarTitleWidget;
  final AssetImage image;
  final Object heroTag;
  final List<Achievement> achs;
  final int achId;
  final DatabaseManager db;
  const AchievementPage(
      {Key? key,
      required this.appBarTitleWidget,
      required this.image,
      required this.heroTag,
      required this.achs,
      required this.achId,
      required this.db})
      : super(key: key);

  @override
  _AchievementPageState createState() => _AchievementPageState();
}

class _AchievementPageState extends State<AchievementPage> {
  bool _hideCompleted = false;

  @override
  void initState() {
    _hideCompleted = Prefs.inst.getBool(TITLE) ?? false;
    super.initState();
  }

  void _updateChecked(int achId, int taskId, bool newVal) async {
    setState(() {
      widget.db.checked[achId][taskId] = newVal;
    });
    widget.db.updateRecord([newVal, taskId, achId]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(
        customPrefString: TITLE,
        prefSize: Size.fromHeight(55),
        customTitleWidget: widget.appBarTitleWidget,
        onHideButton: (newVal) {
          setState(() {
            _hideCompleted = newVal;
          });
        },
      ),
      body: ListView.builder(
        itemCount: widget.achs[widget.achId].tasks.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            // SliverList gives error, so this is a workaround
            return Hero(tag: widget.heroTag, child: Image(image: widget.image));
          }
          int taskIdx = index - 1;
          bool isChecked = widget.db.checked[widget.achId][taskIdx];
          return ItemTile(
            isChecked: isChecked,
            isVisible: !(_hideCompleted && isChecked),
            onChanged: (newVal) {
              _updateChecked(widget.achId, taskIdx, newVal!);
            },
            title: HtmlWidget(widget.achs[widget.achId].tasks[taskIdx].itemName,
                textStyle: Theme.of(context).textTheme.headline2),
            content: HtmlWidget(
              widget.achs[widget.achId].tasks[taskIdx].description,
              textStyle: Theme.of(context).textTheme.bodyText1,
            ),
          );
        },
      ),
    );
  }
}
