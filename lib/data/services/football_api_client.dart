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

  Future<Map<String, dynamic>?> standings({required int leagueId, required int season}) async {
    final data = await _get("/standings", {"league": "$leagueId", "season": "$season"});
    final response = data["response"] as List<dynamic>;
    if (response.isEmpty) return null;
    final league = response.first["league"] as Map<String, dynamic>;
    final standingsGroups = league["standings"] as List<dynamic>;
    return standingsGroups.isNotEmpty ? standingsGroups.first as Map<String, dynamic> : null;
  }

  Future<List<dynamic>> topScorers({required int leagueId, required int season}) async {
    final data = await _get("/players/topscorers", {"league": "$leagueId", "season": "$season"});
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
