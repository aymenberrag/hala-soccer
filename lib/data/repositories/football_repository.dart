import '../../core/constants/league_constants.dart';
import '../models/fixture.dart';
import '../services/football_api_client.dart';

class HomeFeed {
  final List<Fixture> live;
  final List<Fixture> upcoming;
  final List<Fixture> recentResults;
  const HomeFeed({required this.live, required this.upcoming, required this.recentResults});

  bool get isEmpty => live.isEmpty && upcoming.isEmpty && recentResults.isEmpty;
}

class FootballRepository {
  final FootballApiClient _client;
  FootballRepository({FootballApiClient? client}) : _client = client ?? FootballApiClient.instance;

  /// v1 hardcoded season=2022, which goes stale every year. European
  /// domestic leagues run Aug-May, so before August we're still in the
  /// season that *started* the previous calendar year.
  int currentSeason([DateTime? now]) {
    final n = now ?? DateTime.now();
    return n.month >= 8 ? n.year : n.year - 1;
  }

  Future<HomeFeed> homeFeed({DateTime? date}) async {
    final d = date ?? DateTime.now();
    final dateStr =
        "${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}";

    final raw = await _client.fixturesByDate(dateStr);
    final fixtures = raw
        .where((f) => trackedLeagueIds.contains(f["league"]["id"]))
        .map((f) => Fixture.fromJson(f as Map<String, dynamic>))
        .toList();

    return HomeFeed(
      live: fixtures.where((f) => f.isLive).toList(),
      upcoming: fixtures.where((f) => f.isScheduled).toList(),
      recentResults: fixtures.where((f) => f.isFinished).toList(),
    );
  }

  /// Distinct league IDs with fixtures today — used to power the
  /// Matches tab's league picker, same approach as v1's
  /// `getFixturesByLeagueId`.
  Future<List<int>> leaguesWithFixturesToday() async {
    final feed = await homeFeed();
    final all = [...feed.live, ...feed.upcoming, ...feed.recentResults];
    return all.map((f) => f.leagueId).toSet().toList();
  }

  Future<List<Fixture>> leagueFixtures({required int leagueId}) async {
    final season = currentSeason();
    final round = await _client.currentRound(leagueId: leagueId, season: season);
    if (round == null) return [];
    final raw = await _client.fixturesByLeagueAndRound(
      leagueId: leagueId,
      season: season,
      round: round,
    );
    return raw.map((f) => Fixture.fromJson(f as Map<String, dynamic>)).toList();
  }

  Future<Map<String, dynamic>?> leagueStandings({required int leagueId}) =>
      _client.standings(leagueId: leagueId, season: currentSeason());

  Future<List<dynamic>> leagueTopScorers({required int leagueId}) =>
      _client.topScorers(leagueId: leagueId, season: currentSeason());
}
