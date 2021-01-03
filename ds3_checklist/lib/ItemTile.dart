import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class ItemTile extends StatelessWidget {
  ItemTile({
    Key? key,
    this.content,
    this.title,
    required this.isChecked,
    required this.onChanged,
    this.isVisible = true,
  }) : super(key: key);
  final Widget? content;
  final Widget? title;
  final bool isChecked;
  final void Function(bool? newVal)? onChanged;
  final bool isVisible;

  @override
  Widget build(BuildContext context) {
    Widget widget;

    widget = Visibility(
      visible: isVisible,
      child: Column(
        children: [
          CheckboxListTile(
            title: title,
            subtitle: content,
            onChanged: onChanged,
            value: isChecked,
          ),
          Divider(
            endIndent: 10,
            indent: 10,
            color: Colors.grey,
          )
        ],
      ),
    );

    return widget;
  }
}
