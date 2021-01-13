import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'Singletons.dart';

class MyAppBar extends StatefulWidget implements PreferredSizeWidget {
  final String? title;
  final void Function(bool newVal) onHideButton;
  final PreferredSizeWidget? bottom;
  final Size prefSize;
  final Widget? customTitleWidget;
  final String? customPrefString;

  /// Either [title] or [customTitleWidget] must be specified!
  const MyAppBar({
    this.title,
    required this.onHideButton,
    this.bottom,
    this.prefSize = const Size.fromHeight(100),
    this.customTitleWidget,
    this.customPrefString,
  });
  @override
  _MyAppBarState createState() => _MyAppBarState();

  @override
  Size get preferredSize => prefSize;
}

class _MyAppBarState extends State<MyAppBar> {
  bool _isVisible = false;

  @override
  void initState() {
    super.initState();

    final prefStr = widget.customPrefString;
    final title = widget.title;
    if (prefStr != null) {
      _isVisible = Prefs.inst.getBool(prefStr) ?? _isVisible;
    } else if (title != null) {
      _isVisible = Prefs.inst.getBool(title) ?? _isVisible;
    } else {
      throw "customPrefString or title must be specified";
    }
  }

  @override
  Widget build(BuildContext context) {
    final Widget title;
    if (widget.customTitleWidget != null) {
      title = FittedBox(fit: BoxFit.fitWidth, child: widget.customTitleWidget);
    } else {
      title = FittedBox(
          fit: BoxFit.fitWidth,
          child: Text(
            widget.title!,
            style: Theme.of(context).appBarTheme.textTheme?.headline6,
          ));
    }
    return AppBar(
      title: title,
      actions: <Widget>[
        IconButton(
          icon: Icon(_isVisible ? Icons.visibility : Icons.visibility_off),
          onPressed: () {
            _isVisible = !_isVisible;
            if (widget.customPrefString != null) {
              Prefs.inst.setBool(widget.customPrefString!, _isVisible);
            } else {
              Prefs.inst.setBool(widget.title!, _isVisible);
            }
            widget.onHideButton(_isVisible);
          },
        )
      ],
      bottom: widget.bottom,
    );
  }
}

class TabsForAppBar extends StatelessWidget implements PreferredSizeWidget {
  const TabsForAppBar({
    Key? key,
    required this.onChangeTab,
    required this.tabs,
    this.controller,
  }) : super(key: key);

  final TabController? controller;
  final void Function(int p1) onChangeTab;
  final List<Widget> tabs;

  @override
  Widget build(BuildContext context) {
    return TabBar(
      controller: controller ?? DefaultTabController.of(context),
      labelPadding: EdgeInsets.only(bottom: 5, right: 10, left: 10),
      isScrollable: true,
      tabs: tabs,
      onTap: onChangeTab,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(100);
}

class MyTabBarView extends StatelessWidget {
  const MyTabBarView(
      {Key? key, required this.categoriesLength, required this.categoryBuilder})
      : super(key: key);

  final int categoriesLength;
  final ListView Function(BuildContext context, int catIndex) categoryBuilder;

  @override
  Widget build(BuildContext context) {
    return TabBarView(
        physics: PageScrollPhysics(), children: _makeChildren(context));
  }

  List<Widget> _makeChildren(BuildContext context) {
    List<Widget> list =
        List.generate(categoriesLength, (i) => categoryBuilder(context, i));
    return list;
  }
}
