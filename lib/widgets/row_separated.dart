import 'package:flutter/material.dart';

class RowSeparated extends StatelessWidget {
  const RowSeparated({
    super.key,
    required this.spacing,
    required this.children,
    this.mainAxisSize = MainAxisSize.max,
  });

  final double spacing;
  final List<Widget> children;
  final MainAxisSize mainAxisSize;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: mainAxisSize,
      children: List.generate(
        (children.length * 2) - 1,
        (index) => index % 2 == 0 ? children[index ~/ 2] : SizedBox(width: spacing),
      ),
    );
  }
}
