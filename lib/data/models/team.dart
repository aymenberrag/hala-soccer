class Team {
  final int id;
  final String name;
  final String logo;
  final String? country;

  Team({required this.id, required this.name, required this.logo, this.country});

  factory Team.fromJson(Map<String, dynamic> json) {
    final team = json["team"] as Map<String, dynamic>;
    return Team(
      id: team["id"] as int,
      name: team["name"] as String,
      logo: team["logo"] as String,
      country: team["country"] as String?,
    );
  }
}
