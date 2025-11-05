import 'package:Nexora/Pages/Podcast/podcastpage.dart';
import 'package:Nexora/Providers/news_provider.dart';
import 'package:Nexora/Providers/podcast_provider.dart';
import 'package:Nexora/nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:Nexora/Pages/Global/globalpage.dart';
import 'Pages/Profile/profilepage.dart';
import 'Providers/navigation_provider.dart';
import 'Providers/auth_provider.dart';
import 'Providers/tts_provider.dart';
import 'Providers/history_provider.dart';
import 'Providers/ai_provider.dart';
import 'Pages/Home/homepage.dart';
import 'Themes/theme_light.dart' as light_theme;
import 'Themes/theme_dark.dart' as dark_theme;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  var modes = await FlutterDisplayMode.preferred;
  // Set high refresh rate
  await FlutterDisplayMode.setPreferredMode(modes);

  // Create MaterialTheme instances for light and dark themes
  final lightTheme = light_theme.MaterialTheme(ThemeData.light().textTheme);
  final darkTheme = dark_theme.MaterialTheme(
    ThemeData.light().textTheme,
  ); // Using light text theme for consistency

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => NavigationProvider()),
        ChangeNotifierProvider(create: (_) => NewsProvider()),
        ChangeNotifierProvider(create: (_) => TTSProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => HistoryProvider()),
        ChangeNotifierProvider(create: (_) => AiProvider()),
        ChangeNotifierProvider(create: (_) => PodcastProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: lightTheme.light(),
        darkTheme: darkTheme.dark(),
        themeMode:
            ThemeMode.system, // Automatically switch based on system settings
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
            Positioned.fill(
              child: IndexedStack(
                index: selectedIndex,
                children: pages, // Use the list of pages
              ),
            ),
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
