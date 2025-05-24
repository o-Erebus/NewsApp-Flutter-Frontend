// lib/widgets/heading_widget.dart
import 'package:flutter/material.dart';

class HeadingWidget extends StatelessWidget {
  final String title;
  final EdgeInsetsGeometry padding;

  const HeadingWidget({
    super.key,
    required this.title,
    this.padding = const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
  });

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: padding,
        child: Text(
          title,
          style: TextStyle(
            fontSize: 22, // Prominent heading size
            fontWeight: FontWeight.bold,
            color: Theme.of(context).textTheme.titleLarge?.color ?? Colors.black87,
          ),
        ),
      ),
    );
  }
}