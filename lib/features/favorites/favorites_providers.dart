import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/backend_api_client.dart';

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

class FavoritesService {
  final _client = BackendApiClient.instance;

  Future<List<FavoriteTeam>> list() async {
    final raw = await _client.get("/api/favorites");
    final items = (raw["favorites"] as List?) ?? [];
    return items.map((e) => FavoriteTeam.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> add({required int teamId, String? teamName, String? teamLogo}) => _client.post(
        "/api/favorites",
        body: {"team_id": teamId, "team_name": teamName, "team_logo": teamLogo},
      );

  Future<void> remove(String favoriteId) => _client.delete("/api/favorites/$favoriteId");
}

final favoritesServiceProvider = Provider<FavoritesService>((ref) => FavoritesService());

final favoritesProvider = FutureProvider.autoDispose((ref) => ref.watch(favoritesServiceProvider).list());
