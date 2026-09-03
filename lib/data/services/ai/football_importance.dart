import '../../models/fixture.dart';

/// Rule-based "real-world importance" scoring (spec section 5). This is
/// deliberately simple and transparent — it's both (a) the safety-net
/// ranking used when the AI provider is unreachable/unconfigured, and
/// (b) a `ruleScore` hint we hand to the AI prompt so the model doesn't
/// have to guess general football knowledge from scratch.
///
/// League-tier weights below are approximate (API-Football league IDs
/// for the major competitions/cups); tune `_tier1LeagueIds` /
/// `_tier2LeagueIds` if a competition is mis-weighted.
class FootballImportance {
  FootballImportance._();

  // World Cup, Champions League, Europa League, Euros — biggest stage.
  static const _tier1LeagueIds = {1, 2, 3, 4};

  // Top 5 domestic leagues + a few other historically strong ones.
  static const _tier2LeagueIds = {39, 140, 135, 78, 61, 71, 94, 88};

  /// Clubs/national teams whose fixtures are inherently high-interest
  /// regardless of the user's own picks — famous rivalries, biggest
  /// global fanbases. Matched by substring against team names, so
  /// "Real Madrid" catches "Real Madrid CF" too.
  static const _globalDrawTeams = {
    "real madrid",
    "barcelona",
    "manchester united",
    "manchester city",
    "liverpool",
    "arsenal",
    "chelsea",
    "tottenham",
    "bayern",
    "borussia dortmund",
    "psg",
    "paris saint",
    "juventus",
    "ac milan",
    "inter",
    "napoli",
    "roma",
    "atletico madrid",
    "atlético madrid",
    "boca juniors",
    "river plate",
    "flamengo",
    "brazil",
    "argentina",
    "france",
    "england",
    "germany",
    "spain",
    "portugal",
  };

  static const _knockoutKeywords = {
    "final",
    "semi-final",
    "quarter-final",
    "playoff",
    "play-off",
    "3rd place",
  };

  static bool _isGlobalDraw(String teamName) {
    final n = teamName.toLowerCase();
    return _globalDrawTeams.any(n.contains);
  }

  /// Higher is more important. Not bounded — only used for relative
  /// ranking within a candidate pool, never shown to the user.
  static double score(
    Fixture fixture, {
    required Set<int> favoriteTeamIds,
    required Set<int> favoriteLeagueIds,
  }) {
    double s = 0;

    // --- what the user likes ---
    if (favoriteTeamIds.contains(fixture.homeTeamId) ||
        favoriteTeamIds.contains(fixture.awayTeamId)) {
      s += 50;
    }
    if (favoriteLeagueIds.contains(fixture.leagueId)) {
      s += 20;
    }

    // --- what's genuinely important in football ---
    if (_tier1LeagueIds.contains(fixture.leagueId)) {
      s += 30;
    } else if (_tier2LeagueIds.contains(fixture.leagueId)) {
      s += 18;
    } else {
      s += 5;
    }

    final homeIsBig = _isGlobalDraw(fixture.homeTeamName);
    final awayIsBig = _isGlobalDraw(fixture.awayTeamName);
    if (homeIsBig && awayIsBig) {
      s += 40; // marquee derby/rivalry, e.g. Real Madrid vs Barcelona
    } else if (homeIsBig || awayIsBig) {
      s += 15;
    }

    final round = fixture.round?.toLowerCase() ?? "";
    if (_knockoutKeywords.any(round.contains)) {
      s += 25;
    }

    // --- recency/urgency tie-breakers ---
    if (fixture.isLive) s += 8;

    return s;
  }
}
