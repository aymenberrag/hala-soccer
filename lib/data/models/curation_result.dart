/// What the AI curation service decided to show on Home (spec section 5),
/// as fixture/league IDs. Screens resolve these IDs back against the
/// already-fetched fixture objects — the curator never invents data.
class CurationResult {
  final int? featuredFixtureId;
  final List<int> liveFixtureIds;
  final List<int> todayResultFixtureIds;
  final List<int> yesterdayResultFixtureIds;
  final List<int> upcomingFixtureIds;

  /// Leagues worth surfacing on Fixtures/Leagues pages, most relevant
  /// first (spec sections 7 & 9).
  final List<int> rankedLeagueIds;

  /// True if this came from the AI provider; false if it fell back to
  /// the rule-based heuristic (no key configured, provider error, or
  /// malformed response). Surfaced only for debugging/telemetry.
  final bool fromAi;

  const CurationResult({
    this.featuredFixtureId,
    this.liveFixtureIds = const [],
    this.todayResultFixtureIds = const [],
    this.yesterdayResultFixtureIds = const [],
    this.upcomingFixtureIds = const [],
    this.rankedLeagueIds = const [],
    this.fromAi = false,
  });
}
