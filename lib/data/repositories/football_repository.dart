import '../../core/constants/league_constants.dart';
import '../models/fixture.dart';
import '../models/fixture_details.dart';
import '../models/league_summary.dart';
import '../models/standing_entry.dart';
import '../models/team.dart';
import '../services/football_api_client.dart';

class HomeFeed {
  final List<Fixture> live;
  final List<Fixture> upcoming;
  final List<Fixture> todayResults;
  final List<Fixture> yesterdayResults;
  const HomeFeed({
    required this.live,
    required this.upcoming,
    required this.todayResults,
    required this.yesterdayResults,
  });

  bool get isEmpty =>
      live.isEmpty && upcoming.isEmpty && todayResults.isEmpty && yesterdayResults.isEmpty;

  List<Fixture> get all => [...live, ...upcoming, ...todayResults, ...yesterdayResults];
}

class RoundNavigation {
  final List<String> rounds;
  final int currentIndex;
  const RoundNavigation({required this.rounds, required this.currentIndex});

  String? get current =>
      currentIndex >= 0 && currentIndex < rounds.length ? rounds[currentIndex] : null;
  bool get hasPrevious => currentIndex > 0;
  bool get hasNext => currentIndex >= 0 && currentIndex < rounds.length - 1;
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

  String _fmt(DateTime d) =>
      "${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}";

  /// Raw candidate pool for a given day, filtered to leagues the app's
  /// API-Sports plan actually covers ([trackedLeagueIds]). This is the
  /// pool the AI curation service later ranks/selects from — see
  /// AiCurationService in data/services/ai.
  Future<List<Fixture>> fixturesForDate(DateTime date) async {
    final raw = await _client.fixturesByDate(_fmt(date));
    return raw
        .where((f) => trackedLeagueIds.contains(f["league"]["id"]))
        .map((f) => Fixture.fromJson(f as Map<String, dynamic>))
        .toList();
  }

  Future<HomeFeed> homeFeed({DateTime? date}) async {
    final today = date ?? DateTime.now();
    final yesterday = today.subtract(const Duration(days: 1));

    final todayFixtures = await fixturesForDate(today);
    final yesterdayFixtures = await fixturesForDate(yesterday);

    return HomeFeed(
      live: todayFixtures.where((f) => f.isLive).toList(),
      upcoming: todayFixtures.where((f) => f.isScheduled).toList(),
      todayResults: todayFixtures.where((f) => f.isFinished).toList(),
      yesterdayResults: yesterdayFixtures.where((f) => f.isFinished).toList(),
    );
  }

  Future<List<Fixture>> leagueFixtures({required int leagueId, String? round}) async {
    final season = currentSeason();
    final r = round ?? await _client.currentRound(leagueId: leagueId, season: season);
    if (r == null) return [];
    final raw = await _client.fixturesByLeagueAndRound(
      leagueId: leagueId,
      season: season,
      round: r,
    );
    return raw.map((f) => Fixture.fromJson(f as Map<String, dynamic>)).toList();
  }

  /// Rounds list + index of the current round, so the Fixtures page can
  /// move Previous round / Current round / Next round (section 7).
  Future<RoundNavigation> roundNavigation({required int leagueId}) async {
    final season = currentSeason();
    final rounds = await _client.allRounds(leagueId: leagueId, season: season);
    final current = await _client.currentRound(leagueId: leagueId, season: season);
    final idx = current != null ? rounds.indexOf(current) : -1;
    return RoundNavigation(rounds: rounds, currentIndex: idx);
  }

  /// The list of team standing rows for the league's main group/table.
  /// (API-Football nests this as `response[0].league.standings[0]` — a
  /// *list* of row objects, not a map; [FootballApiClient.standings]
  /// already unwraps down to that inner list.)
  Future<List<dynamic>?> leagueStandingsRaw({required int leagueId}) =>
      _client.standings(leagueId: leagueId, season: currentSeason());

  Future<List<StandingEntry>> leagueStandings({required int leagueId}) async {
    final raw = await leagueStandingsRaw(leagueId: leagueId);
    if (raw == null) return [];
    return raw.map((e) => StandingEntry.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<TopPlayerEntry>> leagueTopScorers({required int leagueId}) async {
    final raw = await _client.topScorers(leagueId: leagueId, season: currentSeason());
    return raw.map((e) => TopPlayerEntry.fromJson(e as Map<String, dynamic>, assists: false)).toList();
  }

  Future<List<TopPlayerEntry>> leagueTopAssists({required int leagueId}) async {
    final raw = await _client.topAssists(leagueId: leagueId, season: currentSeason());
    return raw.map((e) => TopPlayerEntry.fromJson(e as Map<String, dynamic>, assists: true)).toList();
  }

  /// Looks up a single fixture by id — used when Fixture Details is opened
  /// without an already-fetched [Fixture] object at hand (e.g. deep link).
  Future<Fixture?> fixtureById(int fixtureId) async {
    final raw = await _client.fixtureById(fixtureId);
    return raw != null ? Fixture.fromJson(raw) : null;
  }

  Future<List<Team>> searchTeams(String query) async {
    final raw = await _client.searchTeams(query);
    return raw.map((t) => Team.fromJson(t as Map<String, dynamic>)).toList();
  }

  Future<List<LeagueSummary>> searchLeagues(String query) async {
    final raw = await _client.searchLeagues(query);
    return raw.map((l) => LeagueSummary.fromJson(l as Map<String, dynamic>)).toList();
  }

  /// Everything the Fixture Details screen needs, fetched in parallel.
  /// Each piece degrades gracefully to empty/null if API-Football simply
  /// doesn't have it yet for this fixture (e.g. events before kickoff).
  Future<FixtureDetails> fixtureDetails(Fixture fixture) async {
    final results = await Future.wait([
      _client.fixtureEvents(fixture.id),
      _client.fixtureStatistics(fixture.id),
      _client.fixtureLineups(fixture.id),
      _client.headToHead(team1Id: fixture.homeTeamId, team2Id: fixture.awayTeamId),
    ]);

    return FixtureDetails(
      fixture: fixture,
      events: (results[0] as List<dynamic>)
          .map((e) => FixtureEvent.fromJson(e as Map<String, dynamic>))
          .toList(),
      statistics: (results[1] as List<dynamic>)
          .map((s) => TeamStatistics.fromJson(s as Map<String, dynamic>))
          .toList(),
      lineups: (results[2] as List<dynamic>)
          .map((l) => TeamLineup.fromJson(l as Map<String, dynamic>))
          .toList(),
      headToHead: (results[3] as List<dynamic>)
          .map((f) => Fixture.fromJson(f as Map<String, dynamic>))
          .toList(),
    );
  }
}
