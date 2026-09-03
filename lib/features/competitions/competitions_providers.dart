import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/standing_entry.dart';
import '../home/home_providers.dart';
import '../matches/matches_providers.dart';

/// Reuses [relevantLeaguesProvider]'s favorites-first, important-leagues,
/// AI-ranked ordering — the Leagues page (section 9) and Fixtures page
/// (section 7) intentionally show the same prioritized set.
final leaguesPageProvider = relevantLeaguesProvider;

final leagueStandingsProvider =
    FutureProvider.autoDispose.family<List<StandingEntry>, int>((ref, leagueId) {
  return ref.watch(footballRepositoryProvider).leagueStandings(leagueId: leagueId);
});

final leagueTopScorersProvider =
    FutureProvider.autoDispose.family<List<TopPlayerEntry>, int>((ref, leagueId) {
  return ref.watch(footballRepositoryProvider).leagueTopScorers(leagueId: leagueId);
});

final leagueTopAssistsProvider =
    FutureProvider.autoDispose.family<List<TopPlayerEntry>, int>((ref, leagueId) {
  return ref.watch(footballRepositoryProvider).leagueTopAssists(leagueId: leagueId);
});
