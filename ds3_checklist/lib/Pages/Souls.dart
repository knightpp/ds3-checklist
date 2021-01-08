import 'package:dark_souls_checklist/CacheManager.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:dark_souls_checklist/Generated/souls_d_s3_c_generated.dart'
    as fb;

const String SOULS_FB = "Cached.Flatbuffer.Souls";

class Souls extends StatefulWidget {
  @override
  _SoulsState createState() => _SoulsState();
}

class _SoulsState extends State<Souls> {
  late List<fb.Soul> souls;

  Future setup() async {
    souls = await CacheManager.getOrInit(SOULS_FB, () async {
      var data = await DefaultAssetBundle.of(context)
          .load('assets/flatbuffers/souls.fb');
      return fb.SoulsRoot(data.buffer.asInt8List()).items;
    });

    return 1;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Soul Prices",
          style: Theme.of(context).appBarTheme.textTheme?.caption,
        ),
      ),
      body: FutureBuilder(
          future: setup(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Text("Error");
            } else if (snapshot.hasData) {
              return ListView.builder(
                  itemCount: souls.length,
                  itemBuilder: (context, soulIdx) {
                    return buildCardSoulPrices(soulIdx, context);
                  });
            } else {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
          }),
    );
  }

  Card buildCardSoulPrices(int soulIdx, BuildContext context) {
    return Card(
      color: Colors.blueGrey[300],
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Expanded(
                flex: 8,
                child: Text(
                  souls[soulIdx].name,
                  style: Theme.of(context).textTheme.bodyText2,
                )),
            Expanded(
              flex: 5,
              child: Icon(
                Icons.forward,
              ),
            ),
            Expanded(
              flex: 3,
              child: Text(souls[soulIdx].souls.toString(),
                  style: Theme.of(context).textTheme.bodyText2),
            )
          ],
        ),
      ),
    );
  }
}
