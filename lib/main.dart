import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const UniGradeApp());
}

class UniGradeApp extends StatelessWidget {
  const UniGradeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'UniGrade',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.blue,
      ),
      home: const HomeScreen(),
    );
  }
}