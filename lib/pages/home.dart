import 'package:flutter/material.dart';
import 'package:hala_soccer/widgets/halasoccerwidgets.dart';
import 'package:hala_soccer/widgets/customwidgets.dart';
import 'package:hala_soccer/services/APIrequest.dart';
/* *****************************************


this moduole return the home page of the app it contain matche of the 
day and all today matches and results



********************************************/
class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool _isLoading = true, _isError = false;
  var _data;
  void getData() {
    setState(() {
      _isLoading=true;
    });
    APIRequest().getHomeData().then((res) {
      setState(() {
        _isLoading = false;
        _isError = false;
        _data = res;
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
    return RefreshIndicator(
      child: _isLoading
          ? const Center(child: Loading())
          : _isError
              ?  const ErrorMsg()
              : ListView(
                  children: [
                    MatchOfTheDay(matche: _data["MOTD"]),
                    for (var e in _data["matches"].keys)
                      MatchesList(listName: e, matches: _data["matches"][e]),
                  ],
                ),
      onRefresh: () async {
        getData();
      },
    );
  }
}
