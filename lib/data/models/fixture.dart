enum FixtureStatus { scheduled, live, finished, other }

class Fixture {
  final int id;
  final DateTime kickoff;
  final String statusShort;
  final int? elapsedMinutes;

  final int leagueId;
  final String leagueName;
  final String leagueLogo;
  final String? leagueCountry;
  final String? round;

  final int homeTeamId;
  final String homeTeamName;
  final String homeTeamLogo;
  final int awayTeamId;
  final String awayTeamName;
  final String awayTeamLogo;

  final int? homeGoals;
  final int? awayGoals;
  final String? venue;

  Fixture({
    required this.id,
    required this.kickoff,
    required this.statusShort,
    this.elapsedMinutes,
    required this.leagueId,
    required this.leagueName,
    required this.leagueLogo,
    this.leagueCountry,
    this.round,
    required this.homeTeamId,
    required this.homeTeamName,
    required this.homeTeamLogo,
    required this.awayTeamId,
    required this.awayTeamName,
    required this.awayTeamLogo,
    this.homeGoals,
    this.awayGoals,
    this.venue,
  });

  factory Fixture.fromJson(Map<String, dynamic> json) {
    final fixture = json["fixture"] as Map<String, dynamic>;
    final league = json["league"] as Map<String, dynamic>;
    final teams = json["teams"] as Map<String, dynamic>;
    final goals = json["goals"] as Map<String, dynamic>?;
    final status = fixture["status"] as Map<String, dynamic>;

    return Fixture(
      id: fixture["id"] as int,
      kickoff: DateTime.parse(fixture["date"] as String),
      statusShort: status["short"] as String,
      elapsedMinutes: status["elapsed"] as int?,
      leagueId: league["id"] as int,
      leagueName: league["name"] as String,
      leagueLogo: league["logo"] as String,
      leagueCountry: league["country"] as String?,
      round: league["round"] as String?,
      homeTeamId: teams["home"]["id"] as int,
      homeTeamName: teams["home"]["name"] as String,
      homeTeamLogo: teams["home"]["logo"] as String,
      awayTeamId: teams["away"]["id"] as int,
      awayTeamName: teams["away"]["name"] as String,
      awayTeamLogo: teams["away"]["logo"] as String,
      homeGoals: goals?["home"] as int?,
      awayGoals: goals?["away"] as int?,
      venue: fixture["venue"]?["name"] as String?,
    );
  }

  /// Status grouping, matching v1's `getFixturesTypes` short-code logic.
  FixtureStatus get status {
    const live = {"1H", "HT", "2H", "ET", "BT", "P", "LIVE"};
    const finished = {"FT", "AET", "PEN"};
    const scheduled = {"TBD", "NS"};

    if (live.contains(statusShort)) return FixtureStatus.live;
    if (finished.contains(statusShort)) return FixtureStatus.finished;
    if (scheduled.contains(statusShort)) return FixtureStatus.scheduled;
    return FixtureStatus.other;
  }

  bool get isLive => status == FixtureStatus.live;
  bool get isFinished => status == FixtureStatus.finished;
  bool get isScheduled => status == FixtureStatus.scheduled;

  String get scoreDisplay =>
      (homeGoals != null && awayGoals != null) ? "$homeGoals - $awayGoals" : "vs";
}
