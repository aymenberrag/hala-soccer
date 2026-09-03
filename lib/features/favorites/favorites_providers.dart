import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/backend_api_client.dart';
import '../../data/models/fixture.dart';
import '../home/home_providers.dart';

class FavoriteTeam {
  final String id;
  final int teamId;
  final String? teamName;
  final String? teamLogo;
  FavoriteTeam({required this.id, required this.teamId, this.teamName, this.teamLogo});

  factory FavoriteTeam.fromJson(Map<String, dynamic> json) => FavoriteTeam(
        id: json["id"] as String,
        teamId: json["team_id"] as int,
        teamName: json["team_name"] as String?,
        teamLogo: json["team_logo"] as String?,
      );
}

class FavoriteLeague {
  final String id;
  final int leagueId;
  final String? leagueName;
  final String? leagueLogo;
  final String? leagueCountry;
  FavoriteLeague({
    required this.id,
    required this.leagueId,
    this.leagueName,
    this.leagueLogo,
    this.leagueCountry,
  });

  factory FavoriteLeague.fromJson(Map<String, dynamic> json) => FavoriteLeague(
        id: json["id"] as String,
        leagueId: json["league_id"] as int,
        leagueName: json["league_name"] as String?,
        leagueLogo: json["league_logo"] as String?,
        leagueCountry: json["league_country"] as String?,
      );
}

class FavoritesService {
  final _client = BackendApiClient.instance;

  Future<List<FavoriteTeam>> listTeams() async {
    final raw = await _client.get("/api/favorites");
    final items = (raw["teams"] as List?) ?? (raw["favorites"] as List?) ?? [];
    return items.map((e) => FavoriteTeam.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> addTeam({required int teamId, String? teamName, String? teamLogo}) => _client.post(
        "/api/favorites",
        body: {"team_id": teamId, "team_name": teamName, "team_logo": teamLogo},
      );

  Future<void> removeTeam(String favoriteId) => _client.delete("/api/favorites/$favoriteId");

  Future<List<FavoriteLeague>> listLeagues() async {
    final raw = await _client.get("/api/favorites/leagues");
    final items = (raw["leagues"] as List?) ?? [];
    return items.map((e) => FavoriteLeague.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> addLeague({
    required int leagueId,
    String? leagueName,
    String? leagueLogo,
    String? leagueCountry,
  }) =>
      _client.post(
        "/api/favorites/leagues",
        body: {
          "league_id": leagueId,
          "league_name": leagueName,
          "league_logo": leagueLogo,
          "league_country": leagueCountry,
        },
      );

  Future<void> removeLeague(String favoriteId) => _client.delete("/api/favorites/leagues/$favoriteId");
}

final favoritesServiceProvider = Provider<FavoritesService>((ref) => FavoritesService());

final favoritesProvider =
    FutureProvider.autoDispose((ref) => ref.watch(favoritesServiceProvider).listTeams());

final favoriteLeaguesProvider =
    FutureProvider.autoDispose((ref) => ref.watch(favoritesServiceProvider).listLeagues());

/// Plain ID sets, watched by the AI curation providers — kept separate
/// from the full favorite objects above so Home doesn't rebuild on every
/// unrelated favorites-list field change.
final favoriteTeamIdsProvider = FutureProvider.autoDispose<Set<int>>((ref) async {
  final teams = await ref.watch(favoritesProvider.future);
  return teams.map((t) => t.teamId).toSet();
});

final favoriteLeagueIdsProvider = FutureProvider.autoDispose<Set<int>>((ref) async {
  final leagues = await ref.watch(favoriteLeaguesProvider.future);
  return leagues.map((l) => l.leagueId).toSet();
});

/// Upcoming and recent matches involving the user's favorite teams (spec
/// section 11). Reuses the same tracked-league fixture pool as Home/AI
/// curation rather than issuing extra API-Football calls — just filtered
/// down to favorite teams instead of AI-ranked importance.
class FavoritesActivity {
  final List<Fixture> upcoming;
  final List<Fixture> recentResults;
  const FavoritesActivity({required this.upcoming, required this.recentResults});
  bool get isEmpty => upcoming.isEmpty && recentResults.isEmpty;
}

final favoritesActivityProvider = FutureProvider.autoDispose<FavoritesActivity>((ref) async {
  final teamIds = await ref.watch(favoriteTeamIdsProvider.future);
  if (teamIds.isEmpty) return const FavoritesActivity(upcoming: [], recentResults: []);

  final feed = await ref.watch(homeFeedProvider.future);
  bool involvesFavorite(Fixture f) => teamIds.contains(f.homeTeamId) || teamIds.contains(f.awayTeamId);

  return FavoritesActivity(
    upcoming: [...feed.live, ...feed.upcoming].where(involvesFavorite).toList(),
    recentResults: [...feed.todayResults, ...feed.yesterdayResults].where(involvesFavorite).toList(),
  );
});
