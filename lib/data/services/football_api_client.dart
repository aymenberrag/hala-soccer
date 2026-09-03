import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../../core/constants/api_constants.dart';
import '../../core/network/api_exception.dart';

/// Direct client for API-Sports.io — same third-party API and endpoints
/// the v1 app used (fixtures, rounds, standings, topscorers). This is
/// unrelated to our own Flask backend; it stays as a thin, faithful port
/// so we don't touch working API integration logic.
class FootballApiClient {
  FootballApiClient._();
  static final FootballApiClient instance = FootballApiClient._();

  String get _apiKey => dotenv.env["API_KEY"] ?? "";
  final String _base = ApiConstants.footballApiBaseUrl;

  Future<List<dynamic>> fixturesByDate(String yyyyMmDd) async {
    final data = await _get("/fixtures", {"date": yyyyMmDd});
    return data["response"] as List<dynamic>;
  }

  Future<List<dynamic>> fixturesByLeagueAndRound({
    required int leagueId,
    required int season,
    required String round,
  }) async {
    final data = await _get("/fixtures", {
      "league": "$leagueId",
      "season": "$season",
      "round": round,
    });
    return data["response"] as List<dynamic>;
  }

  Future<String?> currentRound({required int leagueId, required int season}) async {
    final data = await _get("/fixtures/rounds", {
      "league": "$leagueId",
      "season": "$season",
      "current": "true",
    });
    final response = data["response"] as List<dynamic>;
    return response.isNotEmpty ? response.first as String : null;
  }

  /// Returns the list of team standing rows for the league's main
  /// group/table. API-Football nests this as `response[0].league.standings`,
  /// which is itself a list of *groups* (relevant for leagues split into
  /// multiple tables) — we take the first group, which is a list of row
  /// objects (rank/team/points/goalsDiff/all/form/...).
  Future<List<dynamic>?> standings({required int leagueId, required int season}) async {
    final data = await _get("/standings", {"league": "$leagueId", "season": "$season"});
    final response = data["response"] as List<dynamic>;
    if (response.isEmpty) return null;
    final league = response.first["league"] as Map<String, dynamic>;
    final standingsGroups = league["standings"] as List<dynamic>;
    return standingsGroups.isNotEmpty ? standingsGroups.first as List<dynamic> : null;
  }

  Future<List<dynamic>> topScorers({required int leagueId, required int season}) async {
    final data = await _get("/players/topscorers", {"league": "$leagueId", "season": "$season"});
    return data["response"] as List<dynamic>;
  }

  Future<List<dynamic>> topAssists({required int leagueId, required int season}) async {
    final data = await _get("/players/topassists", {"league": "$leagueId", "season": "$season"});
    return data["response"] as List<dynamic>;
  }

  /// All rounds for a league/season, in API order — used to move
  /// previous/next relative to the current round (section 7).
  Future<List<String>> allRounds({required int leagueId, required int season}) async {
    final data = await _get("/fixtures/rounds", {"league": "$leagueId", "season": "$season"});
    return (data["response"] as List<dynamic>).cast<String>();
  }

  /// Team search for the onboarding "Favorite Teams" step.
  Future<List<dynamic>> searchTeams(String query) async {
    if (query.trim().length < 3) return const [];
    final data = await _get("/teams", {"search": query.trim()});
    return data["response"] as List<dynamic>;
  }

  /// League search for the onboarding "Favorite Leagues" step.
  Future<List<dynamic>> searchLeagues(String query) async {
    if (query.trim().length < 3) return const [];
    final data = await _get("/leagues", {"search": query.trim()});
    return data["response"] as List<dynamic>;
  }

  Future<Map<String, dynamic>?> fixtureById(int fixtureId) async {
    final data = await _get("/fixtures", {"id": "$fixtureId"});
    final response = data["response"] as List<dynamic>;
    return response.isNotEmpty ? response.first as Map<String, dynamic> : null;
  }

  Future<List<dynamic>> fixtureEvents(int fixtureId) async {
    final data = await _get("/fixtures/events", {"fixture": "$fixtureId"});
    return data["response"] as List<dynamic>;
  }

  Future<List<dynamic>> fixtureStatistics(int fixtureId) async {
    final data = await _get("/fixtures/statistics", {"fixture": "$fixtureId"});
    return data["response"] as List<dynamic>;
  }

  Future<List<dynamic>> fixtureLineups(int fixtureId) async {
    final data = await _get("/fixtures/lineups", {"fixture": "$fixtureId"});
    return data["response"] as List<dynamic>;
  }

  Future<List<dynamic>> headToHead({required int team1Id, required int team2Id}) async {
    final data = await _get("/fixtures/headtohead", {
      "h2h": "$team1Id-$team2Id",
      "last": "5",
    });
    return data["response"] as List<dynamic>;
  }

  Future<Map<String, dynamic>> _get(String path, Map<String, String> query) async {
    final uri = Uri.parse("$_base$path").replace(queryParameters: query);
    http.Response response;
    try {
      response = await http
          .get(uri, headers: {"x-apisports-key": _apiKey})
          .timeout(ApiConstants.requestTimeout);
    } on SocketException {
      throw ApiException("No internet connection.");
    } catch (_) {
      throw ApiException("Couldn't reach the football data service.");
    }

    if (response.statusCode != 200) {
      throw ApiException("Football data request failed (${response.statusCode})",
          statusCode: response.statusCode);
    }
    return jsonDecode(response.body) as Map<String, dynamic>;
  }
}
