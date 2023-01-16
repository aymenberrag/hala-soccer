import 'dart:convert';
import 'dart:io';

var leagues = [
  for (int i = 1; i < 10; i++) i,
  for (int i = 12; i < 21; i++) i,
  for (int i = 29; i < 41; i++) i,
  45,
  61,
  66,
  71,
  78,
  88,
  94,
  106,
  113,
  128,
  140,
  143,
  556,
  135,
  137,
  547
];
dynamic filterFixtures({required fixtures}) => fixtures
    .where((element) => leagues.contains(element["league"]["id"]))
    .toList();

dynamic getLiveFixtures({required fixtures}) => fixtures.where((element) {
      var status = element["fixture"]["status"]["short"];
      return status == "1H" ||
          status == "HT" ||
          status == "2H" ||
          status == "ET" ||
          status == "BT" ||
          status == "P" ||
          status == "LIVE";
    });

dynamic getFixturesTypes({required fixtures}) {
  return {
    "NS": fixtures.where((element) {
      var status = element["fixture"]["status"]["short"];
      return status == "TBD" || status == "NS";
    }).toList(),
    "IP": fixtures.where((element) {
      var status = element["fixture"]["status"]["short"];
      return status == "1H" ||
          status == "HT" ||
          status == "2H" ||
          status == "ET" ||
          status == "BT" ||
          status == "P" ||
          status == "LIVE";
    }).toList(),
    "FT": fixtures.where((element) {
      var status = element["fixture"]["status"]["short"];
      return status == "FT" || status == "AET" || status == "PEN";
    }).toList()
  };
}

int getFixtureStatus({required fixture}) {
  var status = fixture["fixture"]["status"]["short"];
  if (status == "TBD" || status == "NS") {
    return -1;
  } else if (status == "1H" ||
      status == "HT" ||
      status == "2H" ||
      status == "ET" ||
      status == "BT" ||
      status == "P" ||
      status == "LIVE") {
    return 0;
  } else if (status == "FT" || status == "AET" || status == "PEN") {
    return 1;
  } else {
    return -1;
  }
}

String towDigits(int num) => num > 9 ? "${num}" : "0${num}";
dynamic getFixtureDate({required fixture}) {
  var date = DateTime.parse(fixture["fixture"]["date"]);
  return {
    "time": "${towDigits(date.hour)}:${towDigits(date.minute)}",
    "date": "${towDigits(date.day)}-${towDigits(date.month)}-${date.year}"
  };
}

dynamic getFixtureDay({required fixture}) {
  var date = DateTime.parse(fixture["fixture"]["date"]);
  var difference = date.difference(DateTime.now());
  if (difference.inDays<29) {
    switch (date.day-DateTime.now().day) {
    case -1:
      return "yesterday";
    case 0:
      return "today";
    case 1:
      return "tomorrow";
  }
  }
  return "${towDigits(date.day)}-${towDigits(date.month)}-${date.year}";
}

dynamic getFixturesByDate({required fixtures}){
  var fixture;
  var fixtureDates={};
  while(fixtures.length>0){
    fixture=fixtures[0];
    fixtureDates.addAll({getFixtureDate(fixture: fixture)["date"]:fixtures.where((element) => getFixtureDate(fixture: element)["date"]==getFixtureDate(fixture: fixture)["date"]).toList()});
    fixtures=fixtures.where((element) => getFixtureDate(fixture: element)["date"]!=getFixtureDate(fixture: fixture)["date"]).toList();
  }
  return fixtureDates;
}


dynamic getFixturesByLeagueId({required fixtures}){
  var fixture;
  var fixtureIds=[];
  while(fixtures.length>0){
    fixture=fixtures[0];
    fixtureIds.add(fixture["league"]["id"]);
    fixtures=fixtures.where((element) => fixture["league"]["id"]!=element["league"]["id"]).toList();
  }
  return fixtureIds;
}


dynamic getFixtureGoals({required fixture}){
  return "${fixture["goals"]["home"]} - ${fixture["goals"]["away"]}";
}

dynamic convertToDate({required DateTime date}){
  return "${towDigits(date.year)}-${towDigits(date.month)}-${date.day}";
}
