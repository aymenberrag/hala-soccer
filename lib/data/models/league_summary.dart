class LeagueSummary {
  final int id;
  final String name;
  final String logo;
  final String? country;
  final String? type;

  LeagueSummary({
    required this.id,
    required this.name,
    required this.logo,
    this.country,
    this.type,
  });

  factory LeagueSummary.fromJson(Map<String, dynamic> json) {
    final league = json["league"] as Map<String, dynamic>;
    final country = json["country"] as Map<String, dynamic>?;
    return LeagueSummary(
      id: league["id"] as int,
      name: league["name"] as String,
      logo: league["logo"] as String,
      country: country?["name"] as String?,
      type: league["type"] as String?,
    );
  }

  /// From the static [featuredLeagues] constant list, not a live API call.
  factory LeagueSummary.fromStatic(Map<String, Object> m) => LeagueSummary(
        id: m["id"] as int,
        name: m["name"] as String,
        logo: m["logo"] as String,
        country: m["country"] as String?,
      );
}
