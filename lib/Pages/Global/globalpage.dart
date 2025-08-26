// lib/Pages/Global/globalpage.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../Providers/news_provider.dart';
import 'widgets/magazine_layout_widget.dart';

class GlobalPage extends StatefulWidget {
  const GlobalPage({super.key});

  @override
  State<GlobalPage> createState() => _GlobalPageState();
}

class _GlobalPageState extends State<GlobalPage> {
  @override
  Widget build(BuildContext context) {
    final newsProvider = context.watch<NewsProvider>();

    return Scaffold(body: MagazineLayoutWidget(newsProvider: newsProvider));
  }
}
