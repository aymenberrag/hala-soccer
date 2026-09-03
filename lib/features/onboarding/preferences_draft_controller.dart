import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/league_summary.dart';
import '../../data/models/team.dart';
import '../../data/repositories/profile_repository.dart';
import '../auth/auth_controller.dart';

/// Holds the in-progress answers as the user moves through
/// User Information -> Favorite Teams -> Favorite Leagues (spec section
/// 3). Nothing is sent to the backend until [submit] on the final step,
/// so backing out and changing an earlier answer just mutates local state.
class PreferencesDraft {
  final String? country;
  final int? age;
  final String? gender;
  final List<Team> teams;
  final List<LeagueSummary> leagues;

  const PreferencesDraft({
    this.country,
    this.age,
    this.gender,
    this.teams = const [],
    this.leagues = const [],
  });

  PreferencesDraft copyWith({
    String? country,
    int? age,
    String? gender,
    List<Team>? teams,
    List<LeagueSummary>? leagues,
  }) =>
      PreferencesDraft(
        country: country ?? this.country,
        age: age ?? this.age,
        gender: gender ?? this.gender,
        teams: teams ?? this.teams,
        leagues: leagues ?? this.leagues,
      );
}

class PreferencesDraftController extends StateNotifier<PreferencesDraft> {
  final ProfileRepository _repo;
  final Ref _ref;

  PreferencesDraftController(this._ref, {ProfileRepository? repo})
      : _repo = repo ?? ProfileRepository(),
        super(const PreferencesDraft());

  void setInfo({String? country, int? age, String? gender}) {
    state = state.copyWith(country: country, age: age, gender: gender);
  }

  bool hasTeam(int teamId) => state.teams.any((t) => t.id == teamId);
  bool hasLeague(int leagueId) => state.leagues.any((l) => l.id == leagueId);

  void toggleTeam(Team team) {
    state = state.copyWith(
      teams: hasTeam(team.id)
          ? state.teams.where((t) => t.id != team.id).toList()
          : [...state.teams, team],
    );
  }

  void toggleLeague(LeagueSummary league) {
    state = state.copyWith(
      leagues: hasLeague(league.id)
          ? state.leagues.where((l) => l.id != league.id).toList()
          : [...state.leagues, league],
    );
  }

  /// Bulk-saves everything to the backend and refreshes the shared
  /// [AuthController] user so `preferencesComplete` flips true and the
  /// router redirects to Home. Returns an error message on failure.
  Future<String?> submit() async {
    try {
      final user = await _repo.saveOnboardingPreferences(
        country: state.country,
        age: state.age,
        gender: state.gender,
        teams: state.teams,
        leagues: state.leagues,
      );
      _ref.read(authControllerProvider.notifier).setUser(user);
      return null;
    } catch (e) {
      return e.toString();
    }
  }
}

final preferencesDraftProvider =
    StateNotifierProvider.autoDispose<PreferencesDraftController, PreferencesDraft>(
        (ref) => PreferencesDraftController(ref));
