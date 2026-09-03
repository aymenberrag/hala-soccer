class AppUser {
  final String id;
  final String name;
  final String email;
  final DateTime? createdAt;

  // Onboarding "user information" (spec section 3).
  final String? country;
  final int? age;
  final String? gender;
  final bool preferencesComplete;

  // Cached so the app doesn't need a second round trip after login just
  // to know what to highlight on Home.
  final List<int> favoriteTeamIds;
  final List<int> favoriteLeagueIds;

  AppUser({
    required this.id,
    required this.name,
    required this.email,
    this.createdAt,
    this.country,
    this.age,
    this.gender,
    this.preferencesComplete = false,
    this.favoriteTeamIds = const [],
    this.favoriteLeagueIds = const [],
  });

  factory AppUser.fromJson(Map<String, dynamic> json) => AppUser(
        id: json["id"] as String,
        name: json["name"] as String,
        email: json["email"] as String,
        createdAt: json["created_at"] != null
            ? DateTime.tryParse(json["created_at"] as String)
            : null,
        country: json["country"] as String?,
        age: json["age"] as int?,
        gender: json["gender"] as String?,
        preferencesComplete: json["preferences_complete"] as bool? ?? false,
        favoriteTeamIds: (json["favorite_team_ids"] as List<dynamic>?)
                ?.map((e) => e as int)
                .toList() ??
            const [],
        favoriteLeagueIds: (json["favorite_league_ids"] as List<dynamic>?)
                ?.map((e) => e as int)
                .toList() ??
            const [],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "email": email,
        "created_at": createdAt?.toIso8601String(),
        "country": country,
        "age": age,
        "gender": gender,
        "preferences_complete": preferencesComplete,
        "favorite_team_ids": favoriteTeamIds,
        "favorite_league_ids": favoriteLeagueIds,
      };

  AppUser copyWith({
    String? country,
    int? age,
    String? gender,
    bool? preferencesComplete,
    List<int>? favoriteTeamIds,
    List<int>? favoriteLeagueIds,
  }) =>
      AppUser(
        id: id,
        name: name,
        email: email,
        createdAt: createdAt,
        country: country ?? this.country,
        age: age ?? this.age,
        gender: gender ?? this.gender,
        preferencesComplete: preferencesComplete ?? this.preferencesComplete,
        favoriteTeamIds: favoriteTeamIds ?? this.favoriteTeamIds,
        favoriteLeagueIds: favoriteLeagueIds ?? this.favoriteLeagueIds,
      );
}
