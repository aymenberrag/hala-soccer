import 'package:flutter/material.dart';
import 'package:hala_soccer/widgets/halasoccerwidgets.dart';
import 'package:hala_soccer/services/data.dart';

class Leagues extends StatelessWidget {
  const Leagues({super.key});
  final _leagues=leaguesList;
  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      child: ListView(children: [for(var e in _leagues)LeagueTile(league: e)],),
      onRefresh: () async {},
    );
  }
}
