import 'package:flutter/material.dart';
import 'package:hala_soccer/services/functions.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hala_soccer/screens/leagueScreen.dart';

/* *****************************************


loading widget animation



********************************************/
class Loading extends StatelessWidget {
  const Loading({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }
}

/* *****************************************


this widget is for the most important match in this week
it take match as arg and dispalayet in contaner



********************************************/

Widget MatchOfTheDay({required matche}) {
  return Container(
      padding: const EdgeInsets.all(20.0),
      margin: const EdgeInsetsDirectional.all(5.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
        gradient: const LinearGradient(
          colors: [
            Color.fromARGB(255, 8, 107, 102),
            Color.fromARGB(255, 26, 218, 154)
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Image.network(
                matche["teams"]["home"]["logo"],
                height: 100.0,
                width: 100.0,
              ),
              TeameName(teameName: matche["teams"]["home"]["name"])
            ],
          ),
          Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  Image.network(
                    matche["league"]["logo"],
                    height: 50.0,
                    width: 50.0,
                  ),
                  Container(
                    padding: const EdgeInsets.all(8.0),
                    width: 100.0,
                    child: Text(
                      matche["league"]["name"],
                      style: const TextStyle(
                        fontSize: 15.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      softWrap: true,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(5.0),
                color: const Color.fromARGB(255, 5, 37, 32),
                child: Text(
                  getFixtureStatus(fixture: matche) == -1
                      ? getFixtureDate(fixture: matche)["time"]
                      : getFixtureGoals(fixture: matche),
                  style: const TextStyle(
                    fontSize: 35.0,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          Column(
            children: [
              Image.network(
                matche["teams"]["away"]["logo"],
                height: 100.0,
                width: 100.0,
              ),
              TeameName(teameName: matche["teams"]["away"]["name"])
            ],
          )
        ],
      ));
}

/* *****************************************


this widget is for the text used for naming the teams 
it's flexeble it takes string name as arg



********************************************/
Widget TeameName({String teameName = ""}) {
  return Container(
    padding: const EdgeInsets.all(5.0),
    width: 100.0,
    child: FittedBox(
      fit: BoxFit.fitWidth,
      child: Text(
        teameName,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
  );
}
/* *****************************************


this widget is for display list of matches with title of 
this list it takes string list name and matche as arg



********************************************/

Widget MatchesList({required String listName, required matches}) {
  return Container(
    margin: const EdgeInsets.all(5.00),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(10.0),
          color: const Color.fromARGB(255, 219, 219, 219),
          child: Text(
            listName,
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 5, 37, 32)),
          ),
        ),
        Column(
          children: [
            for (int i = 0; i < matches.length; i++) Matche(matche: matches[i])
          ],
        )
      ],
    ),
  );
}

/* *****************************************


this widget is for display match data such the teames and time and the league
 it takes matche as arg



********************************************/
Widget Matche({required matche}) {
  return Container(
    margin: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 0.0),
    child: Column(
      children: [
        Container(
          padding: const EdgeInsets.all(2.0),
          width: 55.0,
          color: const Color.fromARGB(255, 26, 218, 154),
          child: Image.network(
            matche["league"]["logo"],
            width: 20.0,
            height: 20.0,
          ),
        ),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(3.0),
              color: const Color.fromARGB(255, 8, 107, 102),
              child: Image.network(
                matche["teams"]["home"]["logo"],
                width: 30.0,
                height: 30.0,
              ),
            ),
            Expanded(
              child: Container(
                height: 36.0,
                color: const Color.fromARGB(255, 240, 240, 240),
                child: Center(
                  child: Text(
                    matche["teams"]["home"]["name"],
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 5, 37, 32),
                    ),
                  ),
                ),
              ),
            ),
            Container(
              width: 55.0,
              color: const Color.fromARGB(255, 5, 37, 32),
              padding:
                  const EdgeInsets.symmetric(vertical: 7.5, horizontal: 4.0),
              child: Center(
                child: Text(
                  getFixtureStatus(fixture: matche) == -1
                      ? getFixtureDate(fixture: matche)["time"]
                      : getFixtureGoals(fixture: matche),
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18.0),
                ),
              ),
            ),
            Expanded(
              child: Container(
                height: 36.0,
                color: const Color.fromARGB(255, 240, 240, 240),
                child: Center(
                  child: Text(
                    matche["teams"]["away"]["name"],
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 5, 37, 32),
                    ),
                  ),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(3.0),
              color: const Color.fromARGB(255, 8, 107, 102),
              child: Image.network(
                matche["teams"]["away"]["logo"],
                width: 30.0,
                height: 30.0,
              ),
            ),
          ],
        ),
        getFixtureStatus(fixture: matche) == -1
            ? PaddingText(text: getFixtureDay(fixture: matche), padding: 5.0)
            : getFixtureStatus(fixture: matche) == 0
                ? LiveWidget()
                : PaddingText(text: "finish", padding: 5.0)
      ],
    ),
  );
}

/* *****************************************


this widget is for chose the leage as choiceship  it take the id of 
the league as arg



********************************************/
Widget LiveWidget() {
  return Container(
    padding: const EdgeInsets.all(2.0),
    width: 55.0,
    color: const Color.fromARGB(255, 165, 44, 54),
    child: const Text(
      "Live",
      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      textAlign: TextAlign.center,
    ),
  );
}

/* *****************************************


this widget is for chose the leage as choiceship  it take the id of 
the league as arg



********************************************/
Widget PaddingText({required String text, required padding}) {
  return Container(
    padding: EdgeInsets.all(padding),
    color: const Color.fromARGB(255, 235, 235, 235),
    child: Text(
      text,
      style: const TextStyle(fontWeight: FontWeight.bold),
      textAlign: TextAlign.center,
    ),
  );
}

/* *****************************************


this widget is for chose the leage as choiceship  it take the id of 
the league as arg



********************************************/
Widget LeagueChip({required league, required onSelected, required selected}) {
  return Container(
    margin: const EdgeInsets.all(10.0),
    child: ChoiceChip(
      onSelected: (select) {
        onSelected(select);
      },
      selectedColor: const Color.fromARGB(255, 26, 218, 154),
      disabledColor: Colors.white,
      label: Image.network(
        "https://media.api-sports.io/football/leagues/${league}.png",
        width: 50.0,
        height: 50.0,
      ),
      selected: selected == league,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
    ),
  );
}
/* *****************************************


this widget is for chose the leage as choiceship  it take the id of 
the league as arg



********************************************/
class LeagueTile extends StatelessWidget {
  final league;
  const LeagueTile({super.key,this.league});

  @override
  Widget build(BuildContext context) {
    return ListTile(
    onTap: (() {
      Navigator.of(context).push(MaterialPageRoute(builder: (context)=> LeagueScreen(league: league)));
    }),
    leading: Image.network(
      league["logo"],
      width: 50.0,
      height: 50.0,
    ),
    title: Text(
      league["name"],
      style: const TextStyle(fontWeight: FontWeight.bold),
    ),
    subtitle: Text(league["country"]),
    trailing: CircleAvatar(
      backgroundColor: Colors.transparent,
      radius: 15.0,
      child: SvgPicture.network(league["flag"]),
    ),
  );
  }
}


/* *****************************************


this widget is for chose the leage as choiceship  it take the id of 
the league as arg



********************************************/
dynamic StandingsTableRow({required stand}) {
  return DataRow(cells: [
     DataCell(
      Text("${stand["rank"]}"),
    ),
    DataCell(
      Row(
        children: [
          Padding(
            padding: const EdgeInsets.all(3.0),
            child: Image.network(
              stand["team"]["logo"],
              height: 30.0,
              width: 30.0,
            ),
          ),
          Text(stand["team"]["name"]),
        ],
      ),
    ),
    DataCell(
      Text("${stand["points"]}"),
    ),
    DataCell(
      Text("${stand["all"]["played"]}"),
    ),
    DataCell(
      Text("${stand["goalsDiff"]}"),
    )
  ]);
}
