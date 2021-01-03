import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../Models/SoulPricesModel.dart';

class SoulPrices extends StatelessWidget {
  static SoulPricesModel? model;

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
          future: DefaultAssetBundle.of(context)
              .loadString('assets/json/soul_prices.json'),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Text("Error");
            } else if (snapshot.hasData) {
              if (model == null) {
                model = SoulPricesModel.fromJson(
                    json.decode(snapshot.data.toString()));
              }
              return ListView.builder(
                  itemCount: model!.souls.length,
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
                  model!.souls[soulIdx].name,
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
              child: Text(model!.souls[soulIdx].price.toString(),
                  style: Theme.of(context).textTheme.bodyText2),
            )
          ],
        ),
      ),
    );
  }
}
