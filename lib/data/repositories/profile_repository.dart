import '../../core/network/backend_api_client.dart';
import '../models/app_user.dart';
import '../models/league_summary.dart';
import '../models/team.dart';

/// Backend calls for the "user information / favorite teams / favorite
/// leagues" onboarding step (spec section 3) and later edits from Profile
/// (spec section 12). Football data itself is never touched here — only
/// our own account/preferences backend.
class ProfileRepository {
  final _client = BackendApiClient.instance;

  Future<AppUser> saveOnboardingPreferences({
    String? country,
    int? age,
    String? gender,
    required List<Team> teams,
    required List<LeagueSummary> leagues,
  }) async {
    final raw = await _client.post(
      "/api/profile/onboarding-preferences",
      body: {
        "country": country,
        "age": age,
        "gender": gender,
        "favorite_teams": teams
            .map((t) => {"team_id": t.id, "team_name": t.name, "team_logo": t.logo})
            .toList(),
        "favorite_leagues": leagues
            .map((l) => {
                  "league_id": l.id,
                  "league_name": l.name,
                  "league_logo": l.logo,
                  "league_country": l.country,
                })
            .toList(),
      },
    );
    return AppUser.fromJson(raw);
  }

  /// Used by Profile (section 12) for editing personal info after
  /// onboarding — a lighter-weight call than the bulk onboarding one,
  /// since it leaves favorites untouched.
  Future<AppUser> updatePersonalInfo({String? name, String? country, int? age, String? gender}) async {
    final body = <String, dynamic>{
      if (name != null) "name": name,
      if (country != null) "country": country,
      if (age != null) "age": age,
      if (gender != null) "gender": gender,
    };
    final raw = await _client.patch("/api/profile", body: body);
    return AppUser.fromJson(raw);
  }

  Future<void> changePassword({required String currentPassword, required String newPassword}) async {
    await _client.post(
      "/api/profile/change-password",
      body: {"current_password": currentPassword, "new_password": newPassword},
    );
  }
}
