import 'package:flutter/material.dart';
import 'package:hala_soccer/widgets/customwidgets.dart';
import 'package:hala_soccer/widgets/halasoccerwidgets.dart';
import 'package:hala_soccer/services/APIrequest.dart';
/* *****************************************


this module return the list of today legues and the matches of 
each league 



********************************************/
class Matches extends StatefulWidget {
  const Matches({super.key});

  @override
  State<Matches> createState() => _MatchesState();
}

class _MatchesState extends State<Matches> {
  bool _isLoading = true,
      _isError = false,
      _isLoadingMatches = true,
      _isErrorMatches = false;
  var _list;
  var _selected;
  var _matches;
  void getMatches({required id}) {
    setState(() {
      _isLoadingMatches = true;
    });
    APIRequest().getMatchesLeague(leagueId: id).then((res) {
      setState(() {
        _isLoadingMatches = false;
        _isErrorMatches = false;
        _matches = res;
      });
    }).catchError((e) {
      setState(() {
        _isLoadingMatches = false;
        _isErrorMatches = true;
      });
    });
  }

  void getData() {
    setState(() {
      _isLoading = true;
    });
    APIRequest().getMatchesData().then((res) {
      setState(() {
        _isLoading = false;
        _isError = false;
        _list = res;
        _selected = _list[0];
        getMatches(id:_selected);
      });
    }).catchError((e) {
      setState(() {
        _isLoading = false;
        _isError = true;
      });
    });
  }

  @override
  void initState() {
    super.initState();
    getData();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: _isLoading
          ? const Center(child: Loading())
          : _isError
              ? const ErrorMsg()
              : Column(
                  children: [
                    Container(
                      color: const Color.fromARGB(255, 240, 240, 240),
                      height: 80.0,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          for (int i = 0; i < _list.length; i++)
                            LeagueChip(
                                league: _list[i],
                                onSelected: (select) {
                                  setState(() {
                                    _selected = _list[i];
                                  });
                                  getMatches(id:_list[i]);
                                },
                                selected: _selected)
                        ],
                      ),
                    ),
                    Expanded(
                      child: _isLoadingMatches
                          ? const Center(child: Loading())
                          : _isErrorMatches
                              ? const ErrorMsg()
                              : ListView(
                                  children: [
                                    for (var e in _matches.keys)
                                      MatchesList(
                                          listName: e,
                                          matches: _matches[e]),
                                  ],
                                ),
                    )
                  ],
                ),
    );
  }
}
