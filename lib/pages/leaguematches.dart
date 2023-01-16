import 'package:flutter/material.dart';
import 'package:hala_soccer/widgets/halasoccerwidgets.dart';
import 'package:hala_soccer/services/APIrequest.dart';
import 'package:hala_soccer/widgets/customwidgets.dart';

class LeagueMatches extends StatefulWidget {
  final id;
  const LeagueMatches({super.key, this.id});

  @override
  State<LeagueMatches> createState() => _LeagueMatchesState();
}

class _LeagueMatchesState extends State<LeagueMatches> {
  bool _isLoadingMatches = true, _isErrorMatches = false;
  var _matches;
  void getMatches({required id}) {
    setState(() {
      _isLoadingMatches = true;
    });
    APIRequest().getMatchesLeague(leagueId: id).then((res) {
      setState(() {
        _isLoadingMatches = false;
        _matches = res;
      });
    }).catchError((e) {
      setState(() {
        _isLoadingMatches = false;
        _isErrorMatches = true;
      });
    });
  }

  @override
  void initState() {
    super.initState();
    getMatches(id: widget.id);
  }

  @override
  Widget build(BuildContext context) {
    return _isLoadingMatches
        ? const Center(child: Loading())
        : _isErrorMatches
            ? const ErrorMsg()
            : ListView(
                children: [
                  for (var e in _matches.keys)
                    MatchesList(listName: e, matches: _matches[e]),
                ],
              );
  }
}
