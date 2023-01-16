import 'package:flutter/material.dart';
import 'package:hala_soccer/widgets/customwidgets.dart';
import 'package:hala_soccer/pages/leaguematches.dart';
import 'package:hala_soccer/pages/standings.dart';
import 'package:hala_soccer/pages/leaguescorers.dart';

class LeagueScreen extends StatelessWidget {
  final league;
  const LeagueScreen({super.key,this.league});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: CustomAppBar(context: context,league: league),
        body: TabBarView(children: [
          StandingsTable(id: league["id"]),
          LeagueMatches(id:league["id"]),
          LeagueScorers(id: league["id"])
        ]),
      ),
    );
  }
}
