// Ported from lib/data/models/*.dart — keep field names/shapes identical
// to those Dart models since both clients talk to the same two APIs.

export type FixtureStatusGroup = "scheduled" | "live" | "finished" | "other";

export interface Fixture {
  id: number;
  kickoff: string; // ISO 8601, as returned by API-Football
  statusShort: string;
  elapsedMinutes: number | null;

  leagueId: number;
  leagueName: string;
  leagueLogo: string;
  leagueCountry: string | null;
  round: string | null;

  homeTeamId: number;
  homeTeamName: string;
  homeTeamLogo: string;
  awayTeamId: number;
  awayTeamName: string;
  awayTeamLogo: string;

  homeGoals: number | null;
  awayGoals: number | null;
  venue: string | null;
}

const LIVE_CODES = new Set(["1H", "HT", "2H", "ET", "BT", "P", "LIVE"]);
const FINISHED_CODES = new Set(["FT", "AET", "PEN"]);
const SCHEDULED_CODES = new Set(["TBD", "NS"]);

/** Mirrors Fixture.status in fixture.dart. */
export function fixtureStatusGroup(f: Fixture): FixtureStatusGroup {
  if (LIVE_CODES.has(f.statusShort)) return "live";
  if (FINISHED_CODES.has(f.statusShort)) return "finished";
  if (SCHEDULED_CODES.has(f.statusShort)) return "scheduled";
  return "other";
}

export function fixtureScoreDisplay(f: Fixture): string {
  return f.homeGoals != null && f.awayGoals != null ? `${f.homeGoals} - ${f.awayGoals}` : "vs";
}

/** Parses one API-Football `/fixtures` response entry into a [Fixture]. */
export function parseFixture(json: any): Fixture {
  const fixture = json.fixture;
  const league = json.league;
  const teams = json.teams;
  const goals = json.goals ?? {};
  const status = fixture.status ?? {};
  return {
    id: fixture.id,
    kickoff: fixture.date,
    statusShort: status.short,
    elapsedMinutes: status.elapsed ?? null,
    leagueId: league.id,
    leagueName: league.name,
    leagueLogo: league.logo,
    leagueCountry: league.country ?? null,
    round: league.round ?? null,
    homeTeamId: teams.home.id,
    homeTeamName: teams.home.name,
    homeTeamLogo: teams.home.logo,
    awayTeamId: teams.away.id,
    awayTeamName: teams.away.name,
    awayTeamLogo: teams.away.logo,
    homeGoals: goals.home ?? null,
    awayGoals: goals.away ?? null,
    venue: fixture.venue?.name ?? null,
  };
}

export interface Team {
  id: number;
  name: string;
  logo: string;
  country: string | null;
}

export function parseTeam(json: any): Team {
  const team = json.team;
  return { id: team.id, name: team.name, logo: team.logo, country: team.country ?? null };
}

export interface LeagueSummary {
  id: number;
  name: string;
  logo: string;
  country: string | null;
  type?: string | null;
}

export function parseLeagueSummary(json: any): LeagueSummary {
  const league = json.league;
  const country = json.country;
  return {
    id: league.id,
    name: league.name,
    logo: league.logo,
    country: country?.name ?? null,
    type: league.type ?? null,
  };
}

export interface AppUser {
  id: string;
  name: string;
  email: string;
  createdAt: string | null;
  country: string | null;
  age: number | null;
  gender: string | null;
  preferencesComplete: boolean;
  favoriteTeamIds: number[];
  favoriteLeagueIds: number[];
}

export function parseAppUser(json: any): AppUser {
  return {
    id: json.id,
    name: json.name,
    email: json.email,
    createdAt: json.created_at ?? null,
    country: json.country ?? null,
    age: json.age ?? null,
    gender: json.gender ?? null,
    preferencesComplete: json.preferences_complete ?? false,
    favoriteTeamIds: json.favorite_team_ids ?? [],
    favoriteLeagueIds: json.favorite_league_ids ?? [],
  };
}

export interface FavoriteTeam {
  id: string;
  teamId: number;
  teamName: string | null;
  teamLogo: string | null;
}

export interface FavoriteLeague {
  id: string;
  leagueId: number;
  leagueName: string | null;
  leagueLogo: string | null;
  leagueCountry: string | null;
}

export function parseFavoriteTeam(json: any): FavoriteTeam {
  return {
    id: json.id,
    teamId: json.team_id,
    teamName: json.team_name ?? null,
    teamLogo: json.team_logo ?? null,
  };
}

export function parseFavoriteLeague(json: any): FavoriteLeague {
  return {
    id: json.id,
    leagueId: json.league_id,
    leagueName: json.league_name ?? null,
    leagueLogo: json.league_logo ?? null,
    leagueCountry: json.league_country ?? null,
  };
}

// --- Fixture Details (events / stats / lineups / H2H) ---

export interface FixtureEvent {
  minute: number | null;
  extraMinute: number | null;
  teamName: string;
  teamLogo: string;
  playerName: string;
  assistName: string | null;
  type: string;
  detail: string;
}

export function parseFixtureEvent(json: any): FixtureEvent {
  const time = json.time ?? {};
  const team = json.team ?? {};
  const player = json.player ?? {};
  const assist = json.assist;
  return {
    minute: time.elapsed ?? null,
    extraMinute: time.extra ?? null,
    teamName: team.name ?? "",
    teamLogo: team.logo ?? "",
    playerName: player.name ?? "Unknown",
    assistName: assist?.name ?? null,
    type: json.type ?? "",
    detail: json.detail ?? "",
  };
}

export interface StatItem {
  type: string;
  value: unknown;
}

export interface TeamStatistics {
  teamName: string;
  teamLogo: string;
  stats: StatItem[];
}

export function parseTeamStatistics(json: any): TeamStatistics {
  const team = json.team ?? {};
  const raw: any[] = json.statistics ?? [];
  return {
    teamName: team.name ?? "",
    teamLogo: team.logo ?? "",
    stats: raw.map((s) => ({ type: s.type ?? "", value: s.value })),
  };
}

export function statValue(stats: TeamStatistics, type: string): string | null {
  const match = stats.stats.find((s) => s.type.toLowerCase() === type.toLowerCase());
  if (!match) return null;
  return match.value == null ? "-" : String(match.value);
}

export interface LineupPlayer {
  name: string;
  position: string | null;
  number: number | null;
}

export interface TeamLineup {
  teamName: string;
  teamLogo: string;
  formation: string | null;
  coachName: string | null;
  startXI: LineupPlayer[];
  substitutes: LineupPlayer[];
}

function parseLineupPlayer(json: any): LineupPlayer {
  const player = json.player ?? {};
  return { name: player.name ?? "Unknown", position: player.pos ?? null, number: player.number ?? null };
}

export function parseTeamLineup(json: any): TeamLineup {
  const team = json.team ?? {};
  const coach = json.coach;
  return {
    teamName: team.name ?? "",
    teamLogo: team.logo ?? "",
    formation: json.formation ?? null,
    coachName: coach?.name ?? null,
    startXI: (json.startXI ?? []).map(parseLineupPlayer),
    substitutes: (json.substitutes ?? []).map(parseLineupPlayer),
  };
}

export interface FixtureDetails {
  fixture: Fixture;
  events: FixtureEvent[];
  statistics: TeamStatistics[];
  lineups: TeamLineup[];
  headToHead: Fixture[];
}

// --- Standings / top scorers & assists ---

export interface StandingEntry {
  rank: number;
  teamId: number;
  teamName: string;
  teamLogo: string;
  points: number;
  goalsDiff: number;
  played: number;
  win: number;
  draw: number;
  lose: number;
  goalsFor: number;
  goalsAgainst: number;
  form: string | null;
  description: string | null;
}

export function parseStandingEntry(json: any): StandingEntry {
  const team = json.team ?? {};
  const all = json.all ?? {};
  const goals = all.goals ?? {};
  return {
    rank: json.rank ?? 0,
    teamId: team.id,
    teamName: team.name ?? "",
    teamLogo: team.logo ?? "",
    points: json.points ?? 0,
    goalsDiff: json.goalsDiff ?? 0,
    played: all.played ?? 0,
    win: all.win ?? 0,
    draw: all.draw ?? 0,
    lose: all.lose ?? 0,
    goalsFor: goals.for ?? 0,
    goalsAgainst: goals.against ?? 0,
    form: json.form ?? null,
    description: json.description ?? null,
  };
}

export interface TopPlayerEntry {
  playerId: number;
  playerName: string;
  playerPhoto: string;
  teamName: string;
  teamLogo: string;
  value: number;
  appearances: number | null;
}

export function parseTopPlayerEntry(json: any, assists: boolean): TopPlayerEntry {
  const player = json.player ?? {};
  const stats = (json.statistics ?? [])[0] ?? {};
  const team = stats.team ?? {};
  const goals = stats.goals ?? {};
  const games = stats.games ?? {};
  return {
    playerId: player.id,
    playerName: player.name ?? "",
    playerPhoto: player.photo ?? "",
    teamName: team.name ?? "",
    teamLogo: team.logo ?? "",
    value: (assists ? goals.assists : goals.total) ?? 0,
    appearances: games.appearences ?? games.appearances ?? null,
  };
}
