import 'package:flutter/material.dart';
import 'package:geofencingpoc/screens/home_screen.dart';
import 'package:geofencingpoc/theme/theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Unimac',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme(),
      // darkTheme: AppTheme.darkTheme(),
      themeMode: ThemeMode.system,
      home: const HomeScreen(),
    );
  }
}
