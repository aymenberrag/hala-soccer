import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hala_soccer/services/functions.dart';
import 'package:http/http.dart' as http;

class APIRequest {
  final String _API_KEY = dotenv.env["API_KEY"]!=null?dotenv.env["API_KEY"] as String:"" ;
  final String _url = "v3.football.api-sports.io";
  Future getHomeData() async {
    var data = {};
    var response = await http.get(
        Uri.https(
            _url, "fixtures", {"date": convertToDate(date: DateTime.now())}),
        headers: {"x-apisports-key": _API_KEY});
    if (response.statusCode == 200) {
      var fixtures =
          filterFixtures(fixtures: jsonDecode(response.body)["response"]);
      if (fixtures.length > 0) {
        if (getFixturesTypes(fixtures: fixtures)["IP"].length > 0) {
          data.addAll({"live": getFixturesTypes(fixtures: fixtures)["IP"]});
        }

        if (getFixturesTypes(fixtures: fixtures)["NS"].length > 0) {
          data.addAll({"today": getFixturesTypes(fixtures: fixtures)["NS"]});
        }

        if (getFixturesTypes(fixtures: fixtures)["FT"].length > 0) {
          data.addAll({"results": getFixturesTypes(fixtures: fixtures)["FT"]});
        }
        return {"MOTD": fixtures[0], "matches": data};
      } else {
        throw "ops somthing wrong";
      }
    } else {
      throw "ops somthing wrong";
    }
  }

  Future getMatchesData() async {
    var response = await http.get(
        Uri.https(
            _url, "fixtures", {"date": convertToDate(date: DateTime.now())}),
        headers: {"x-apisports-key": _API_KEY});
    if (response.statusCode == 200) {
      var fixtures =
          filterFixtures(fixtures: jsonDecode(response.body)["response"]);
      return getFixturesByLeagueId(fixtures: fixtures);
    } else {
      throw "ops somthing wrong";
    }
  }

  Future getMatchesLeague({required leagueId}) async {
    var round = await http.get(
        Uri.parse(
            "https://v3.football.api-sports.io/fixtures/rounds?league=${leagueId}&season=2022&current=true"),
        headers: {"x-apisports-key": _API_KEY});
    if (round.statusCode == 200) {
      var response = await http.get(
          Uri.parse(
              "https://v3.football.api-sports.io/fixtures?league=${leagueId}&season=2022&round=${jsonDecode(round.body)["response"][0]}"),
          headers: {"x-apisports-key": _API_KEY});
      if (response.statusCode == 200) {
        var fixtures =
            jsonDecode(response.body)["response"];
        return getFixturesByDate(fixtures: fixtures);
      } else {
        throw "ops somthing wrong";
      }
    } else {
      throw "ops somthing wrong";
    }
  }

  dynamic getLeagueStanding({required leagueId}) async {
    var response = await http.get(
        Uri.parse(
              "https://v3.football.api-sports.io/standings?league=${leagueId}&season=2022"),
        headers: {"x-apisports-key": _API_KEY});
    if (response.statusCode == 200) {
      var standings = jsonDecode(response.body)["response"][0]["league"]["standings"][0];
      return standings;
    } else {
      throw "ops somthing wrong";
    }
  }
  dynamic getLeagueScorers({required leagueId}) async {
    var response = await http.get(
        Uri.parse(
              "https://v3.football.api-sports.io/players/topscorers?league=${leagueId}&season=2022"),
        headers: {"x-apisports-key": _API_KEY});
    if (response.statusCode == 200) {
      var scorers = jsonDecode(response.body)["response"];
      return scorers;
    } else {
      throw "ops somthing wrong";
    }
  }
}
