import 'dart:convert';
import 'dart:developer' as developer;

import '../../models/curation_result.dart';
import '../../models/fixture.dart';
import '../../repositories/football_repository.dart';
import 'ai_provider.dart';
import 'ai_provider_factory.dart';
import 'football_importance.dart';

/// The one piece of "AI" in Hala Soccer (spec sections 5-6): given the
/// day's candidate fixtures and what the user likes, decide what Home
/// leads with. It is NOT a chatbot and has no conversational surface —
/// its only output is a ranked/selected set of fixture & league IDs.
///
/// Always safe to call: if no AI provider is configured, the request
/// fails, or the model returns something we can't parse, this silently
/// falls back to [FootballImportance]'s rule-based ranking so Home never
/// breaks because of the AI step.
class AiCurationService {
  static const _maxCandidates = 40;
  static const _maxPerSection = 8;

  final AiProvider _provider;
  AiCurationService({AiProvider? provider}) : _provider = provider ?? AiProviderFactory.create();

  Future<CurationResult> curateHome({
    required HomeFeed feed,
    required List<int> favoriteTeamIds,
    required List<int> favoriteLeagueIds,
    String? userCountry,
  }) async {
    final favTeams = favoriteTeamIds.toSet();
    final favLeagues = favoriteLeagueIds.toSet();

    final scored = {
      for (final f in feed.all) f.id: FootballImportance.score(f, favoriteTeamIds: favTeams, favoriteLeagueIds: favLeagues),
    };

    final fallback = _fallbackResult(feed, scored);

    try {
      final ai = await _tryAi(
        feed: feed,
        scored: scored,
        favTeams: favTeams,
        favLeagues: favLeagues,
        userCountry: userCountry,
      );
      return ai ?? fallback;
    } catch (e, st) {
      developer.log("AI curation failed, using rule-based fallback", error: e, stackTrace: st, name: "AiCurationService");
      return fallback;
    }
  }

  // --- rule-based fallback -------------------------------------------------

  CurationResult _fallbackResult(HomeFeed feed, Map<int, double> scored) {
    List<int> topOf(List<Fixture> list) {
      final sorted = [...list]..sort((a, b) => (scored[b.id] ?? 0).compareTo(scored[a.id] ?? 0));
      return sorted.take(_maxPerSection).map((f) => f.id).toList();
    }

    final all = feed.all;
    Fixture? featured;
    if (all.isNotEmpty) {
      featured = ([...all]..sort((a, b) => (scored[b.id] ?? 0).compareTo(scored[a.id] ?? 0))).first;
    }

    final leagueScore = <int, double>{};
    for (final f in all) {
      final s = scored[f.id] ?? 0;
      if (s > (leagueScore[f.leagueId] ?? -1)) leagueScore[f.leagueId] = s;
    }
    final rankedLeagues = leagueScore.keys.toList()
      ..sort((a, b) => (leagueScore[b] ?? 0).compareTo(leagueScore[a] ?? 0));

    return CurationResult(
      featuredFixtureId: featured?.id,
      liveFixtureIds: topOf(feed.live),
      todayResultFixtureIds: topOf(feed.todayResults),
      yesterdayResultFixtureIds: topOf(feed.yesterdayResults),
      upcomingFixtureIds: topOf(feed.upcoming),
      rankedLeagueIds: rankedLeagues,
      fromAi: false,
    );
  }

  // --- AI path ---------------------------------------------------------------

  Future<CurationResult?> _tryAi({
    required HomeFeed feed,
    required Map<int, double> scored,
    required Set<int> favTeams,
    required Set<int> favLeagues,
    String? userCountry,
  }) async {
    // Trim to the highest-signal candidates so the prompt stays small and
    // cheap — this also protects against gigantic days (busy Saturdays).
    final candidates = [...feed.all]
      ..sort((a, b) => (scored[b.id] ?? 0).compareTo(scored[a.id] ?? 0));
    final pool = candidates.take(_maxCandidates).toList();
    if (pool.isEmpty) return null;

    final candidateJson = pool
        .map((f) => {
              "id": f.id,
              "home": f.homeTeamName,
              "away": f.awayTeamName,
              "league": f.leagueName,
              "leagueId": f.leagueId,
              "country": f.leagueCountry,
              "round": f.round,
              "status": f.status.name,
              "favoriteTeam": favTeams.contains(f.homeTeamId) || favTeams.contains(f.awayTeamId),
              "favoriteLeague": favLeagues.contains(f.leagueId),
              "ruleImportance": scored[f.id]?.round(),
            })
        .toList();

    const system = """
You curate the home feed of a football (soccer) app called Hala Soccer.
You choose which fixtures and leagues deserve visibility today — you do
not chat with the user and you never invent fixtures or data.

Combine two things:
1) What this user personally cares about (favoriteTeam/favoriteLeague flags).
2) What is genuinely important in world football right now — major
   derbies and rivalries (e.g. Real Madrid vs Barcelona), Champions
   League knockout games, finals, semi-finals, title-deciders,
   relegation battles, and major international fixtures — even if the
   user didn't pick that team or league.

Respond with ONLY a JSON object, no prose, matching exactly:
{
  "featuredFixtureId": <id or null>,
  "liveFixtureIds": [<ids>],
  "todayResultFixtureIds": [<ids>],
  "yesterdayResultFixtureIds": [<ids>],
  "upcomingFixtureIds": [<ids>],
  "rankedLeagueIds": [<leagueIds>]
}
Every id you return MUST come from the candidate list provided. Do not
add ids that aren't present. Keep each fixture list to at most 8 ids,
ordered most-important first.
""";

    final userPrompt = jsonEncode({
      "userCountry": userCountry,
      "candidates": candidateJson,
    });

    final raw = await _provider.complete(systemPrompt: system, userPrompt: userPrompt);
    final parsed = _safeParse(raw);
    if (parsed == null) return null;

    final validIds = pool.map((f) => f.id).toSet();
    final validLeagueIds = pool.map((f) => f.leagueId).toSet();

    List<int> extractIds(String key) {
      final list = parsed[key] as List<dynamic>?;
      if (list == null) return const [];
      return list.whereType<num>().map((n) => n.toInt()).where(validIds.contains).take(_maxPerSection).toList();
    }

    final rankedLeagueIds = (parsed["rankedLeagueIds"] as List<dynamic>?)
            ?.whereType<num>()
            .map((n) => n.toInt())
            .where(validLeagueIds.contains)
            .toList() ??
        const [];

    final featuredRaw = parsed["featuredFixtureId"];
    final featuredId = featuredRaw is num && validIds.contains(featuredRaw.toInt()) ? featuredRaw.toInt() : null;

    return CurationResult(
      featuredFixtureId: featuredId,
      liveFixtureIds: extractIds("liveFixtureIds"),
      todayResultFixtureIds: extractIds("todayResultFixtureIds"),
      yesterdayResultFixtureIds: extractIds("yesterdayResultFixtureIds"),
      upcomingFixtureIds: extractIds("upcomingFixtureIds"),
      rankedLeagueIds: rankedLeagueIds,
      fromAi: true,
    );
  }

  Map<String, dynamic>? _safeParse(String raw) {
    try {
      // Models sometimes wrap JSON in ```json fences despite instructions.
      final cleaned = raw.replaceAll(RegExp(r"```json|```"), "").trim();
      final decoded = jsonDecode(cleaned);
      return decoded is Map<String, dynamic> ? decoded : null;
    } catch (_) {
      return null;
    }
  }
}
