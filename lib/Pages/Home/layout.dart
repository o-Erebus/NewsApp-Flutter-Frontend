import 'package:flutter/material.dart';

class ScrollScaffold extends StatelessWidget {
  final Widget sliverTitle;
  final List<Widget> children;
  final bool floating;
  final bool snap;

  const ScrollScaffold({
    super.key,
    required this.sliverTitle,
    required this.children,
    this.floating = false,
    this.snap = false,
  });

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          floating: floating,
          snap: snap,
          toolbarHeight: 75,
          title: sliverTitle,
          forceMaterialTransparency: true,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          elevation: 0,
        ),
        SliverList(
          delegate: SliverChildListDelegate(children),
        ),
      ],
    );
  }
}
