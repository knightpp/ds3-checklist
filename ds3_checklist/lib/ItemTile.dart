import 'package:flutter/material.dart';

class ItemTile extends StatelessWidget {
  ItemTile({
    Key? key,
    this.content,
    this.title,
    required this.isChecked,
    required this.onChanged,
    this.isVisible = true,
    this.isLast = false,
  }) : super(key: key);
  final Widget? content;
  final Widget? title;
  final bool isChecked;
  final void Function(bool? newVal)? onChanged;
  final bool isVisible;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: isVisible,
      child: Column(
        children: [
          CheckboxListTile(
            title: title,
            subtitle: content,
            onChanged: onChanged,
            value: isChecked,
          ),
          if (!isLast)
            Divider(
              endIndent: 10,
              indent: 10,
              color: Colors.grey,
            )
        ],
      ),
    );
  }
}
