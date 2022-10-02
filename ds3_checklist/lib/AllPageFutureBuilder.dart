import 'package:flutter/material.dart';

/// Use this at root of your widget tree.
/// Returns Scaffold with error message if any,
/// org Widget's built from closure.
class AllPageFutureBuilder<T> extends StatelessWidget {
  AllPageFutureBuilder(
      {Key? key, required this.future, required this.buildOnLoad})
      : super(key: key);
  final Future<T> future;
  final Widget Function(BuildContext, AsyncSnapshot) buildOnLoad;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          print("Error was: \n${snapshot.error}");
          return Scaffold(
              body: Text(
            "Error\n${snapshot.error}",
            style: TextStyle(color: Colors.red),
          ));
        } else if (snapshot.hasData) {
          return buildOnLoad(context, snapshot);
        } else {
          return Scaffold(body: Center(child: CircularProgressIndicator()));
        }
      },
    );
  }
}
