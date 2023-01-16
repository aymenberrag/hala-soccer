import 'package:flutter/material.dart';
import 'package:hala_soccer/widgets/customwidgets.dart';
import 'package:hala_soccer/pages/home.dart';
import 'package:hala_soccer/pages/matches.dart';
import 'package:hala_soccer/pages/leagues.dart';
import 'package:hala_soccer/pages/linesup.dart';
import 'package:hala_soccer/pages/account.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _pageIndex = 0;
  final List _pages = [const Home(),const Matches(),const Leagues(),const Linesup(),const Account()];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_pageIndex],
      bottomNavigationBar: CustomBottomNavigationBar(
        onSelect: (index) {
          setState(() {
            _pageIndex = index;
          });
        },
      ),
    );
  }
}
