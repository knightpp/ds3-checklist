import 'package:dark_souls_checklist/CacheManager.dart';
import 'package:dark_souls_checklist/MyAppBar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dark_souls_checklist/DatabaseManager.dart';
// import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:provider/provider.dart';
import 'package:simple_rich_md/simple_rich_md.dart';
import '../Singletons.dart';
import 'package:dark_souls_checklist/Generated/trades_d_s3_c_generated.dart'
    as fb;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../main.dart';

Map<int, bool> expensiveComputation(List dbResp) {
  print("(expensive) Running computation");

  Map<int, bool> checked = Map();
  for (var line in dbResp) {
    checked[(line["trade_id"] as int)] = (line["is_checked"] as int) != 0;
  }
  return checked;
}

bool _hideCompleted = false;

class Trades extends StatefulWidget {
  static void resetStatics() {
    _TradesState.db.reset();
  }

  @override
  _TradesState createState() => _TradesState();
}

class _TradesState extends State<Trades> {
  late List<fb.Trade> trades;
  static DatabaseManager db =
      DatabaseManager(expensiveComputation, DbFor.Trades);

  @override
  void initState() {
    super.initState();
    _hideCompleted = Prefs.inst.getBool("Trades") ?? false;
  }

  void _updateChecked(int tradeId, bool newVal) async {
    setState(() {
      db.checked[tradeId] = newVal;
    });
    db.updateRecord([newVal, tradeId]);
  }

  Future setup(MyModel value) async {
    await db.openDbAndParse();
    trades =
        await CacheManager.getOrInit(CacheManager.TRADES_FLATBUFFER, () async {
      var data = await rootBundle.load('${value.flatbuffersPath}/trades.fb');
      return fb.TradesRoot(data.buffer.asInt8List()).items!;
    });
    return 1;
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final value = Provider.of<MyModel>(context);

    return Scaffold(
      appBar: MyAppBar(
        title: loc.tradesPageTitle,
        prefSize: Size.fromHeight(60),
        onHideButton: (newVal) {
          setState(() {
            _hideCompleted = newVal;
          });
        },
      ),
      body: FutureBuilder(
          future: setup(value),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Text("Error");
            } else if (snapshot.hasData) {
              return ListView.builder(
                itemCount: trades.length,
                itemBuilder: (context, tradeIdx) {
                  bool isChecked = db.checked[tradeIdx];
                  return Visibility(
                    visible: !(_hideCompleted && isChecked),
                    child: Column(
                      children: <Widget>[
                        buildCheckboxListTile(tradeIdx, context, isChecked),
                        Divider()
                      ],
                    ),
                  );
                },
              );
            } else {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
          }),
    );
  }

  CheckboxListTile buildCheckboxListTile(
      int tradeIdx, BuildContext context, bool isChecked) {
    return CheckboxListTile(
      title: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(children: <Widget>[
            buildTextTradesWhat(tradeIdx, context),
            Expanded(flex: 2, child: Icon(Icons.forward)),
            buildTextTradesTo(tradeIdx, context),
          ])),
      value: isChecked,
      onChanged: (value) {
        _updateChecked(tradeIdx, value!);
      },
    );
  }

  Expanded buildTextTradesTo(int tradeIdx, BuildContext context) {
    return Expanded(
      flex: 3,
      child: SimpleRichMd(
        text: trades[tradeIdx].for_,
        onTap: openLink,
        linkStyle: getLinkTextStyle(),
        textStyle: Theme.of(context).textTheme.bodyText2,
      ),
      // MarkdownBody(
      //   onTapLink: openLink,
      //   data: trades[tradeIdx].for_,
      //   styleSheet: MarkdownStyleSheet(
      //       a: getLinkTextStyle(), p: Theme.of(context).textTheme.bodyText2),
      // ),
    );
  }

  Expanded buildTextTradesWhat(int tradeIdx, BuildContext context) {
    return Expanded(
      flex: 4,
      child: SimpleRichMd(
        text: trades[tradeIdx].what,
        linkStyle: getLinkTextStyle(),
        textStyle: Theme.of(context).textTheme.bodyText2,
        onTap: openLink,
      ),
      // MarkdownBody(
      //   onTapLink: openLink,
      //   data: trades[tradeIdx].what,
      //   styleSheet: MarkdownStyleSheet(a: getLinkTextStyle()),
      // ),
    );
  }
}
