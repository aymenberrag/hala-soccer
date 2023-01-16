import 'package:flutter/material.dart';
import 'package:hala_soccer/widgets/halasoccerwidgets.dart';
import 'package:hala_soccer/services/APIrequest.dart';
import 'package:hala_soccer/widgets/customwidgets.dart';

class LeagueScorers extends StatefulWidget {
  final id;
  const LeagueScorers({super.key, this.id});

  @override
  State<LeagueScorers> createState() => _LeagueScorersState();
}

class _LeagueScorersState extends State<LeagueScorers> {
  bool _isLoading = true, _isError = false;
  var _scorers;
  void getData() {
    setState(() {
      _isLoading = true;
    });
    APIRequest().getLeagueScorers(leagueId: widget.id).then((res) {
      setState(() {
        _isLoading = false;
        _scorers = res;
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
    return _isLoading
        ? const Center(child: Loading())
        : _isError
            ? const ErrorMsg()
            : RefreshIndicator(
                child: ListView(
                  children: [
                    for (var player in _scorers)
                      ListTile(
                        leading: Image.network(
                          player["player"]["photo"],
                          width: 50.0,
                          height: 50.0,
                        ),
                        title: Text(player["player"]["name"]),
                        subtitle: Text(player["statistics"][0]["team"]["name"]),
                        trailing: Text(
                            "${player["statistics"][0]["goals"]["total"]}"),
                      )
                  ],
                ),
                onRefresh: () async {},
              );
  }
}
