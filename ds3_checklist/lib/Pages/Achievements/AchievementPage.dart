import 'package:dark_souls_checklist/DatabaseManager.dart';
import 'package:dark_souls_checklist/MyAppBar.dart';
import 'package:dark_souls_checklist/main.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:simple_rich_md/simple_rich_md.dart';
import '../../ItemTile.dart';
import '../../Singletons.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:dark_souls_checklist/Generated/achievements_ds3_c_generated.dart'
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
        itemCount: widget.ach.tasks!.length + 1,
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
          final task = widget.ach.tasks![taskIdx];
          return ItemTile(
              isChecked: isChecked,
              isVisible: !(_hideCompleted && isChecked),
              onChanged: (newVal) {
                _updateChecked(widget.achId, taskIdx, newVal!);
              },
              title: TaskTitle(task),
              content: SimpleRichMd(
                  text: task.description!,
                  onTap: openLink,
                  linkStyle: getLinkTextStyle(),
                  textStyle: Theme.of(context).textTheme.bodyMedium)
              // MarkdownBody(
              //   onTapLink: openLink,
              //   data: task.description,
              //   styleSheet: MarkdownStyleSheet(
              //       a: getLinkTextStyle(),
              //       p: Theme.of(context).textTheme.bodyText2),
              // ),
              );
        },
      ),
    );
  }
}

class TaskTitle extends StatelessWidget {
  final fb.Task task;

  const TaskTitle(this.task, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final title = SimpleRichMd(
      onTap: openLink,
      text: task.name!,
      textStyle: Theme.of(context).textTheme.headlineSmall?.copyWith(fontSize: 18),
      linkStyle: getLinkTextStyle().copyWith(fontSize: 18),
      boldStyle: Theme.of(context)
          .textTheme
          .headlineSmall
          ?.copyWith(fontSize: 18, fontWeight: FontWeight.bold),
    );
    // final title = MarkdownBody(
    //     onTapLink: openLink,
    //     data: task.name,
    //     styleSheet: MarkdownStyleSheet(
    //         p: Theme.of(context).textTheme.headline5?.copyWith(fontSize: 18)));
    if (task.play != 1) {
      return Row(
        children: [
          Icon(
            getPlayIconData(task),
          ),
          title
        ],
      );
    } else {
      return title;
    }
  }

  IconData getPlayIconData(fb.Task task) {
    switch (task.play) {
      case 1:
        return Icons.looks_one;
      case 2:
        return Icons.looks_two;
      case 3:
        return Icons.looks_3;
      default:
        throw "unreachable";
    }
  }
}
