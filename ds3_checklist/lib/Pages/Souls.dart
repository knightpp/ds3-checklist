import 'package:dark_souls_checklist/CacheManager.dart';
import 'package:dark_souls_checklist/main.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:dark_souls_checklist/Generated/souls_d_s3_c_generated.dart'
    as fb;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

class Souls extends StatelessWidget {
  Future<List<fb.Soul>> setup(BuildContext context, MyModel value) async {
    return await CacheManager.getOrInit(CacheManager.SOULS_FLATBUFFER,
        () async {
      var data = await DefaultAssetBundle.of(context)
          .load('${value.flatbuffersPath}/souls.fb');
      return fb.SoulsRoot(data.buffer.asInt8List()).items;
    });
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final value = Provider.of<MyModel>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          loc.soulPrices,
        ),
      ),
      body: FutureBuilder(
          future: setup(context, value),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Text("Error: ${snapshot.error}");
            } else if (snapshot.hasData) {
              final souls = snapshot.data as List<fb.Soul>;
              return ListView.builder(
                  itemCount: souls.length,
                  itemBuilder: (context, soulIdx) {
                    return SoulCard(souls[soulIdx]);
                  });
            } else {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
          }),
    );
  }
}

class SoulCard extends StatelessWidget {
  final fb.Soul soul;

  const SoulCard(this.soul, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      // color: Theme.of(context),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Expanded(
                flex: 8,
                child: Text(
                  soul.name,
                  style: Theme.of(context).primaryTextTheme.bodyText2,
                )),
            Expanded(
              flex: 5,
              child: Icon(
                Icons.forward,
              ),
            ),
            Expanded(
              flex: 3,
              child: Text(soul.price.toString(),
                  style: Theme.of(context).primaryTextTheme.bodyText2),
            )
          ],
        ),
      ),
    );
  }
}
