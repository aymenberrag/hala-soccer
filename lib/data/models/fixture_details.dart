import 'fixture.dart';

class FixtureEvent {
  final int? minute;
  final int? extraMinute;
  final String teamName;
  final String teamLogo;
  final String playerName;
  final String? assistName;
  final String type; // Goal, Card, subst, Var
  final String detail; // Normal Goal, Yellow Card, Substitution 1, ...

  FixtureEvent({
    this.minute,
    this.extraMinute,
    required this.teamName,
    required this.teamLogo,
    required this.playerName,
    this.assistName,
    required this.type,
    required this.detail,
  });

  factory FixtureEvent.fromJson(Map<String, dynamic> json) {
    final time = json["time"] as Map<String, dynamic>;
    final team = json["team"] as Map<String, dynamic>;
    final player = json["player"] as Map<String, dynamic>;
    final assist = json["assist"] as Map<String, dynamic>?;
    return FixtureEvent(
      minute: time["elapsed"] as int?,
      extraMinute: time["extra"] as int?,
      teamName: team["name"] as String? ?? "",
      teamLogo: team["logo"] as String? ?? "",
      playerName: player["name"] as String? ?? "Unknown",
      assistName: assist?["name"] as String?,
      type: json["type"] as String? ?? "",
      detail: json["detail"] as String? ?? "",
    );
  }

  bool get isGoal => type == "Goal";
  bool get isCard => type == "Card";
  bool get isSub => type == "subst";
  bool get isYellow => detail.toLowerCase().contains("yellow");
  bool get isRed => detail.toLowerCase().contains("red");
}

class StatItem {
  final String type;
  final Object? value;
  StatItem({required this.type, required this.value});

  factory StatItem.fromJson(Map<String, dynamic> json) =>
      StatItem(type: json["type"] as String? ?? "", value: json["value"]);

  String get display => value == null ? "-" : value.toString();
}

class TeamStatistics {
  final String teamName;
  final String teamLogo;
  final List<StatItem> stats;

  TeamStatistics({required this.teamName, required this.teamLogo, required this.stats});

  factory TeamStatistics.fromJson(Map<String, dynamic> json) {
    final team = json["team"] as Map<String, dynamic>;
    final raw = (json["statistics"] as List<dynamic>? ?? [])
        .map((s) => StatItem.fromJson(s as Map<String, dynamic>))
        .toList();
    return TeamStatistics(
      teamName: team["name"] as String? ?? "",
      teamLogo: team["logo"] as String? ?? "",
      stats: raw,
    );
  }

  String? statValue(String type) {
    for (final s in stats) {
      if (s.type.toLowerCase() == type.toLowerCase()) return s.display;
    }
    return null;
  }
}

class LineupPlayer {
  final String name;
  final String? position;
  final int? number;
  LineupPlayer({required this.name, this.position, this.number});

  factory LineupPlayer.fromJson(Map<String, dynamic> json) {
    final player = json["player"] as Map<String, dynamic>;
    return LineupPlayer(
      name: player["name"] as String? ?? "Unknown",
      position: player["pos"] as String?,
      number: player["number"] as int?,
    );
  }
}

class TeamLineup {
  final String teamName;
  final String teamLogo;
  final String? formation;
  final String? coachName;
  final List<LineupPlayer> startXI;
  final List<LineupPlayer> substitutes;

  TeamLineup({
    required this.teamName,
    required this.teamLogo,
    this.formation,
    this.coachName,
    required this.startXI,
    required this.substitutes,
  });

  factory TeamLineup.fromJson(Map<String, dynamic> json) {
    final team = json["team"] as Map<String, dynamic>;
    final coach = json["coach"] as Map<String, dynamic>?;
    return TeamLineup(
      teamName: team["name"] as String? ?? "",
      teamLogo: team["logo"] as String? ?? "",
      formation: json["formation"] as String?,
      coachName: coach?["name"] as String?,
      startXI: (json["startXI"] as List<dynamic>? ?? [])
          .map((p) => LineupPlayer.fromJson(p as Map<String, dynamic>))
          .toList(),
      substitutes: (json["substitutes"] as List<dynamic>? ?? [])
          .map((p) => LineupPlayer.fromJson(p as Map<String, dynamic>))
          .toList(),
    );
  }
}

/// Aggregate bundle the Fixture Details screen renders. Every field is
/// independently empty-safe — API-Football simply returns an empty list
/// for data that isn't available yet (e.g. lineups before ~1h pre-kickoff),
/// and the screen hides those sections rather than showing placeholders.
class FixtureDetails {
  final Fixture fixture;
  final List<FixtureEvent> events;
  final List<TeamStatistics> statistics;
  final List<TeamLineup> lineups;
  final List<Fixture> headToHead;

  FixtureDetails({
    required this.fixture,
    required this.events,
    required this.statistics,
    required this.lineups,
    required this.headToHead,
  });
}
