import 'package:finalyear/Providers/news_provider.dart';
import 'package:finalyear/greetings.dart';
import 'package:finalyear/nav_bar.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'Pages/globalpage.dart';
import 'Pages/podcastpage.dart';
import 'Pages/profilepage.dart';
import 'Providers/navigation_provider.dart';
import 'Pages/Home/homepage.dart';


void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => NavigationProvider()),
        ChangeNotifierProvider(create: (_) => NewsProvider())
      ],
      child: MaterialApp(
        theme: ThemeData.dark(useMaterial3: true),
        home: MyApp(),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final pages = const [
      HomePage(),
      GlobalPage(),
      PodcastPage(),
      ProfilePage(),
    ];
    final selectedIndex = context.watch<NavigationProvider>().selectedIndex;
    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: [
            Positioned.fill(child: pages[selectedIndex]),
            Align(
              alignment: Alignment.bottomCenter,

              child: Padding(
                padding: EdgeInsets.only(bottom: 15),
                child: FloatingNavbar(pages: pages),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
