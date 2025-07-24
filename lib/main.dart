
import 'package:finalyear/Providers/news_provider.dart';
import 'package:finalyear/nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';

import 'package:provider/provider.dart';

import 'Pages/globalpage.dart';
import 'Pages/podcastpage.dart';
import 'Pages/profilepage.dart';
import 'Providers/navigation_provider.dart';
import 'Pages/Home/homepage.dart';
import 'Theme/theme_data.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  var modes = await FlutterDisplayMode.preferred;
  // Set high refresh rate
  await FlutterDisplayMode.setPreferredMode(modes);


  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => NavigationProvider()),
        ChangeNotifierProvider(create: (_) => NewsProvider())
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: NewsAppTheme.darkTheme,
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
            Positioned.fill(child:  IndexedStack(
              index: selectedIndex,
              children: pages, // Use the list of pages
            ),),
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