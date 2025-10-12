import 'package:flutter/material.dart';
import 'package:peoples_book/view/peoples_home.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: PeoplesHome(),
      theme: ThemeData(
        primaryColor: const Color(0xFF1877F2), // Main Blue
        scaffoldBackgroundColor: const Color(0xFFF0F2F5), // Background
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF1877F2),
          secondary: Color(0xFF42B72A),
        ),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: Color(0xFF1C1E21)), // Text color
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1877F2),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF1877F2),
          secondary: Color(0xFF42B72A),
        ),
        scaffoldBackgroundColor: const Color(0xFF121212),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF121212),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
      ),
      themeMode: ThemeMode.system, // switches automatically between light/dark
    );
  }
}
