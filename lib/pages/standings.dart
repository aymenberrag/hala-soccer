import 'package:flutter/material.dart';
import 'package:hala_soccer/widgets/halasoccerwidgets.dart';
import 'package:hala_soccer/services/APIrequest.dart';
import 'package:hala_soccer/widgets/customwidgets.dart';

class StandingsTable extends StatefulWidget {
  final id;
  const StandingsTable({super.key,this.id});

  @override
  State<StandingsTable> createState() => _StandingsTableState();
}

class _StandingsTableState extends State<StandingsTable> {
  bool _isLoading = true, _isError = false;
  var _standings;
  void getData() {
    setState(() {
      _isLoading = true;
    });
    APIRequest().getLeagueStanding(leagueId: widget.id).then((res) {
      setState(() {
        _isLoading = false;
        _standings = res;
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
            : ListView(children: [
                DataTable(
                  columnSpacing: 2.0,
                  horizontalMargin: 5.0,
                  headingTextStyle: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18.0,
                      color: Color.fromARGB(255, 5, 37, 32)),
                  dataTextStyle: const TextStyle(
                      fontSize: 18.0, color: Color.fromARGB(255, 5, 37, 32)),
                  columns: const [
                    DataColumn(label: Text("N°")),
                    DataColumn(label: Expanded(child: Text("teame"))),
                    DataColumn(label: Text("PTS")),
                    DataColumn(label: Text("PLD")),
                    DataColumn(label: Text("DIF")),
                  ],
                  rows: [for (var stand in _standings) StandingsTableRow(stand: stand)],
                ),
              ]);
    ;
  }
}
