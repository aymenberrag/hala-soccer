import 'package:flutter/material.dart';
import 'package:hala_soccer/screens/homeScreen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async{
  await dotenv.load(fileName: ".env");
  runApp(const HalaSoccerApp());
}

class HalaSoccerApp extends StatelessWidget {
  const HalaSoccerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: "hala soccer",
      home: HomeScreen(),
    );
  }
}

