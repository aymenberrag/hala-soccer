import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/league_constants.dart';
import '../../data/models/fixture.dart';
import '../../data/models/fixture_details.dart';
import '../../data/models/league_summary.dart';
import '../../data/repositories/football_repository.dart';
import '../favorites/favorites_providers.dart';
import '../home/home_providers.dart';

/// Keyed on fixture id (not the whole [Fixture] object) so re-opening the
/// same fixture from two different screens still hits one cached call.
final fixtureDetailsProvider =
    FutureProvider.autoDispose.family<FixtureDetails, ({int fixtureId, Fixture? seed})>((ref, args) async {
  final repo = ref.watch(footballRepositoryProvider);
  final fixture = args.seed ?? await repo.fixtureById(args.fixtureId);
  if (fixture == null) {
    throw Exception("Fixture not found.");
  }
  return repo.fixtureDetails(fixture);
});

/// Leagues offered by the Fixtures page's horizontal selector (spec
/// section 7), in priority order: 1) the user's favorite leagues,
/// 2) well-known important leagues, 3) whatever else the AI curator
/// ranked highly today. Deduplicated and capped so the strip stays usable.
final relevantLeaguesProvider = FutureProvider.autoDispose<List<LeagueSummary>>((ref) async {
  final favoriteLeagues = await ref.watch(favoriteLeaguesProvider.future);
  final homeFeed = await ref.watch(homeFeedProvider.future);
  List<int> aiRankedIds = const [];
  try {
    final curation = await ref.watch(homeCurationProvider.future);
    aiRankedIds = curation.rankedLeagueIds;
  } catch (_) {
    // Curation is best-effort here; the selector still works without it.
  }

  final byId = <int, LeagueSummary>{};

  for (final fav in favoriteLeagues) {
    byId[fav.leagueId] = LeagueSummary(
      id: fav.leagueId,
      name: fav.leagueName ?? "League #${fav.leagueId}",
      logo: fav.leagueLogo ?? "",
      country: fav.leagueCountry,
    );
  }
  for (final l in featuredLeagues) {
    byId.putIfAbsent(l["id"] as int, () => LeagueSummary.fromStatic(l));
  }
  // Metadata for any AI-ranked league not already covered comes from
  // today's fixtures themselves — no extra API call needed.
  final metaFromFixtures = {for (final f in homeFeed.all) f.leagueId: f};
  for (final id in aiRankedIds) {
    if (byId.containsKey(id)) continue;
    final f = metaFromFixtures[id];
    if (f != null) {
      byId[id] = LeagueSummary(id: id, name: f.leagueName, logo: f.leagueLogo, country: f.leagueCountry);
    }
  }

  return byId.values.take(16).toList();
});

final roundNavigationProvider =
    FutureProvider.autoDispose.family<RoundNavigation, int>((ref, leagueId) {
  return ref.watch(footballRepositoryProvider).roundNavigation(leagueId: leagueId);
});

final leagueFixturesProvider =
    FutureProvider.autoDispose.family<List<Fixture>, ({int leagueId, String? round})>((ref, args) {
  return ref.watch(footballRepositoryProvider).leagueFixtures(leagueId: args.leagueId, round: args.round);
});
