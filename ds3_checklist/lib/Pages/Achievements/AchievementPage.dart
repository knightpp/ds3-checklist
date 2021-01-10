import 'package:dark_souls_checklist/DatabaseManager.dart';
import 'package:dark_souls_checklist/MyAppBar.dart';
import 'package:dark_souls_checklist/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../../ItemTile.dart';
import '../../Singletons.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:dark_souls_checklist/Generated/achievements_d_s3_c_generated.dart'
    as fb;

class AchievementPage extends StatefulWidget {
  final Widget appBarTitleWidget;
  final AssetImage image;
  final Object heroTag;
  final fb.Achievement ach;
  final int achId;
  final DatabaseManager db;
  const AchievementPage(
      {Key? key,
      required this.appBarTitleWidget,
      required this.image,
      required this.heroTag,
      required this.ach,
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
    super.initState();
    _hideCompleted = Prefs.inst.getBool("Achievements") ?? false;
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
        customPrefString: AppLocalizations.of(context)!.achievementsPageTitle,
        prefSize: Size.fromHeight(55),
        customTitleWidget: widget.appBarTitleWidget,
        onHideButton: (newVal) {
          setState(() {
            _hideCompleted = newVal;
          });
        },
      ),
      body: ListView.builder(
        itemCount: widget.ach.tasks.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            // SliverList gives error, so this is a workaround
            return Padding(
              padding: const EdgeInsets.all(24.0),
              child:
                  Hero(tag: widget.heroTag, child: Image(image: widget.image)),
            );
          }
          int taskIdx = index - 1;
          bool isChecked = widget.db.checked[widget.achId][taskIdx]!;
          final task = widget.ach.tasks[taskIdx];
          return ItemTile(
            isChecked: isChecked,
            isVisible: !(_hideCompleted && isChecked),
            onChanged: (newVal) {
              _updateChecked(widget.achId, taskIdx, newVal!);
            },
            title: MarkdownBody(
              onTapLink: openLink,
              data: task.text.split(":").first,
              styleSheet: MarkdownStyleSheet()
                  .copyWith(p: Theme.of(context).textTheme.headline2),
              // textStyle: Theme.of(context).textTheme.headline2
            ),
            content: MarkdownBody(
              onTapLink: openLink,
              data: task.text,
              // textStyle: Theme.of(context).textTheme.bodyText1,
            ),
          );
        },
      ),
    );
  }
}
