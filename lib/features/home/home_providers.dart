import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/curation_result.dart';
import '../../data/models/fixture.dart';
import '../../data/repositories/football_repository.dart';
import '../../data/services/ai/curation_service.dart';
import '../auth/auth_controller.dart';
import '../favorites/favorites_providers.dart';

final footballRepositoryProvider = Provider<FootballRepository>((ref) => FootballRepository());

final aiCurationServiceProvider = Provider<AiCurationService>((ref) => AiCurationService());

/// Today/yesterday's candidate fixture pool, already trimmed to tracked
/// leagues by the repository. This is the raw pool the AI curator (or its
/// rule-based fallback) picks and ranks from — never shown directly.
final homeFeedProvider = FutureProvider.autoDispose<HomeFeed>((ref) {
  return ref.watch(footballRepositoryProvider).homeFeed();
});

/// The actual "AI chooses what deserves to be shown" step (spec sections
/// 5-6): combines the candidate pool with the user's favorites + country.
/// Always resolves — falls back to rule-based importance scoring inside
/// [AiCurationService] if the AI provider is unreachable/unconfigured.
final homeCurationProvider = FutureProvider.autoDispose<CurationResult>((ref) async {
  final feed = await ref.watch(homeFeedProvider.future);
  final favTeams = await ref.watch(favoriteTeamIdsProvider.future);
  final favLeagues = await ref.watch(favoriteLeagueIdsProvider.future);
  final user = ref.watch(authControllerProvider).user;

  return ref.watch(aiCurationServiceProvider).curateHome(
        feed: feed,
        favoriteTeamIds: favTeams.toList(),
        favoriteLeagueIds: favLeagues.toList(),
        userCountry: user?.country,
      );
});

/// What the Home screen actually renders — the raw feed's fixtures,
/// resolved against the curator's chosen IDs and re-ordered to match.
class CuratedHomeFeed {
  final Fixture? featured;
  final List<Fixture> live;
  final List<Fixture> todayResults;
  final List<Fixture> yesterdayResults;
  final List<Fixture> upcoming;
  final bool fromAi;

  const CuratedHomeFeed({
    this.featured,
    required this.live,
    required this.todayResults,
    required this.yesterdayResults,
    required this.upcoming,
    required this.fromAi,
  });

  bool get isEmpty => live.isEmpty && todayResults.isEmpty && yesterdayResults.isEmpty && upcoming.isEmpty;
}

final curatedHomeFeedProvider = FutureProvider.autoDispose<CuratedHomeFeed>((ref) async {
  final feed = await ref.watch(homeFeedProvider.future);
  final curation = await ref.watch(homeCurationProvider.future);

  final byId = {for (final f in feed.all) f.id: f};
  List<Fixture> resolve(List<int> ids) => ids.map((id) => byId[id]).whereType<Fixture>().toList();

  return CuratedHomeFeed(
    featured: curation.featuredFixtureId != null ? byId[curation.featuredFixtureId] : null,
    live: resolve(curation.liveFixtureIds),
    todayResults: resolve(curation.todayResultFixtureIds),
    yesterdayResults: resolve(curation.yesterdayResultFixtureIds),
    upcoming: resolve(curation.upcomingFixtureIds),
    fromAi: curation.fromAi,
  );
});
