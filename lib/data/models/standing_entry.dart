class StandingEntry {
  final int rank;
  final int teamId;
  final String teamName;
  final String teamLogo;
  final int points;
  final int goalsDiff;
  final int played;
  final int win;
  final int draw;
  final int lose;
  final int goalsFor;
  final int goalsAgainst;
  final String? form;
  final String? description;

  StandingEntry({
    required this.rank,
    required this.teamId,
    required this.teamName,
    required this.teamLogo,
    required this.points,
    required this.goalsDiff,
    required this.played,
    required this.win,
    required this.draw,
    required this.lose,
    required this.goalsFor,
    required this.goalsAgainst,
    this.form,
    this.description,
  });

  factory StandingEntry.fromJson(Map<String, dynamic> json) {
    final team = json["team"] as Map<String, dynamic>;
    final all = json["all"] as Map<String, dynamic>? ?? {};
    final goals = all["goals"] as Map<String, dynamic>? ?? {};
    return StandingEntry(
      rank: json["rank"] as int? ?? 0,
      teamId: team["id"] as int,
      teamName: team["name"] as String? ?? "",
      teamLogo: team["logo"] as String? ?? "",
      points: json["points"] as int? ?? 0,
      goalsDiff: json["goalsDiff"] as int? ?? 0,
      played: all["played"] as int? ?? 0,
      win: all["win"] as int? ?? 0,
      draw: all["draw"] as int? ?? 0,
      lose: all["lose"] as int? ?? 0,
      goalsFor: goals["for"] as int? ?? 0,
      goalsAgainst: goals["against"] as int? ?? 0,
      form: json["form"] as String?,
      description: json["description"] as String?,
    );
  }
}

/// A row from `/players/topscorers` or `/players/topassists` — same
/// response shape, so one model covers both.
class TopPlayerEntry {
  final int playerId;
  final String playerName;
  final String playerPhoto;
  final String teamName;
  final String teamLogo;
  final int value; // goals or assists, depending on which endpoint this came from
  final int? appearances;

  TopPlayerEntry({
    required this.playerId,
    required this.playerName,
    required this.playerPhoto,
    required this.teamName,
    required this.teamLogo,
    required this.value,
    this.appearances,
  });

  factory TopPlayerEntry.fromJson(Map<String, dynamic> json, {required bool assists}) {
    final player = json["player"] as Map<String, dynamic>;
    final stats = (json["statistics"] as List<dynamic>).first as Map<String, dynamic>;
    final team = stats["team"] as Map<String, dynamic>;
    final goals = stats["goals"] as Map<String, dynamic>? ?? {};
    final games = stats["games"] as Map<String, dynamic>? ?? {};
    return TopPlayerEntry(
      playerId: player["id"] as int,
      playerName: player["name"] as String? ?? "",
      playerPhoto: player["photo"] as String? ?? "",
      teamName: team["name"] as String? ?? "",
      teamLogo: team["logo"] as String? ?? "",
      value: (assists ? goals["assists"] : goals["total"]) as int? ?? 0,
      appearances: games["appearences"] as int? ?? games["appearances"] as int?,
    );
  }
}
