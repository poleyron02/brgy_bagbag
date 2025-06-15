import 'package:flutter/material.dart';

class ColumnSeparated extends StatelessWidget {
  const ColumnSeparated({
    super.key,
    required this.spacing,
    required this.children,
    this.mainAxisSize = MainAxisSize.max,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.center,
  });

  final double spacing;
  final List<Widget> children;
  final MainAxisSize mainAxisSize;
  final CrossAxisAlignment crossAxisAlignment;
  final MainAxisAlignment mainAxisAlignment;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: mainAxisSize,
      mainAxisAlignment: mainAxisAlignment,
      crossAxisAlignment: crossAxisAlignment,
      children: List.generate(
        (children.length * 2) - 1,
        (index) => index % 2 == 0 ? children[index ~/ 2] : SizedBox(height: spacing),
      ),
    );
  }
}
