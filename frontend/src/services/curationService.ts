import type { Fixture } from "@/types/models";
import { homeFeedAll, type HomeFeed } from "./footballRepository";

/**
 * Ported from lib/data/services/ai/football_importance.dart. The Flutter
 * app layers an optional OpenRouter LLM call on top of this and falls back
 * to it whenever that call is unavailable — see frontend/README.md for why
 * this web build intentionally skips the LLM step (an AI provider key
 * embedded in browser JS is public, same issue as the football API key,
 * just for a provider that can be more expensive to abuse) and always
 * uses this same rule-based ranking the Flutter app relies on as its
 * safety net.
 */
const TIER1_LEAGUE_IDS = new Set([1, 2, 3, 4]); // World Cup, UCL, UEL, Euros
const TIER2_LEAGUE_IDS = new Set([39, 140, 135, 78, 61, 71, 94, 88]); // top 5 + a few strong others

const GLOBAL_DRAW_TEAMS = [
  "real madrid",
  "barcelona",
  "manchester united",
  "manchester city",
  "liverpool",
  "arsenal",
  "chelsea",
  "tottenham",
  "bayern",
  "borussia dortmund",
  "psg",
  "paris saint",
  "juventus",
  "ac milan",
  "inter",
  "napoli",
  "roma",
  "atletico madrid",
  "atlético madrid",
  "boca juniors",
  "river plate",
  "flamengo",
  "brazil",
  "argentina",
  "france",
  "england",
  "germany",
  "spain",
  "portugal",
];

const KNOCKOUT_KEYWORDS = ["final", "semi-final", "quarter-final", "playoff", "play-off", "3rd place"];

function isGlobalDraw(teamName: string): boolean {
  const n = teamName.toLowerCase();
  return GLOBAL_DRAW_TEAMS.some((t) => n.includes(t));
}

export function footballImportanceScore(
  fixture: Fixture,
  favoriteTeamIds: Set<number>,
  favoriteLeagueIds: Set<number>,
): number {
  let s = 0;

  if (favoriteTeamIds.has(fixture.homeTeamId) || favoriteTeamIds.has(fixture.awayTeamId)) s += 50;
  if (favoriteLeagueIds.has(fixture.leagueId)) s += 20;

  if (TIER1_LEAGUE_IDS.has(fixture.leagueId)) s += 30;
  else if (TIER2_LEAGUE_IDS.has(fixture.leagueId)) s += 18;
  else s += 5;

  const homeIsBig = isGlobalDraw(fixture.homeTeamName);
  const awayIsBig = isGlobalDraw(fixture.awayTeamName);
  if (homeIsBig && awayIsBig) s += 40;
  else if (homeIsBig || awayIsBig) s += 15;

  const round = (fixture.round ?? "").toLowerCase();
  if (KNOCKOUT_KEYWORDS.some((k) => round.includes(k))) s += 25;

  if (fixture.statusShort && ["1H", "HT", "2H", "ET", "BT", "P", "LIVE"].includes(fixture.statusShort)) s += 8;

  return s;
}

export interface CurationResult {
  featuredFixtureId: number | null;
  liveFixtureIds: number[];
  todayResultFixtureIds: number[];
  yesterdayResultFixtureIds: number[];
  upcomingFixtureIds: number[];
  rankedLeagueIds: number[];
}

const MAX_PER_SECTION = 8;

export function curateHome(feed: HomeFeed, favoriteTeamIds: number[], favoriteLeagueIds: number[]): CurationResult {
  const favTeams = new Set(favoriteTeamIds);
  const favLeagues = new Set(favoriteLeagueIds);
  const all = homeFeedAll(feed);

  const scored = new Map<number, number>();
  for (const f of all) scored.set(f.id, footballImportanceScore(f, favTeams, favLeagues));

  const topOf = (list: Fixture[]): number[] =>
    [...list]
      .sort((a, b) => (scored.get(b.id) ?? 0) - (scored.get(a.id) ?? 0))
      .slice(0, MAX_PER_SECTION)
      .map((f) => f.id);

  let featured: Fixture | null = null;
  if (all.length > 0) {
    featured = [...all].sort((a, b) => (scored.get(b.id) ?? 0) - (scored.get(a.id) ?? 0))[0];
  }

  const leagueScore = new Map<number, number>();
  for (const f of all) {
    const s = scored.get(f.id) ?? 0;
    if (s > (leagueScore.get(f.leagueId) ?? -1)) leagueScore.set(f.leagueId, s);
  }
  const rankedLeagueIds = [...leagueScore.keys()].sort((a, b) => (leagueScore.get(b) ?? 0) - (leagueScore.get(a) ?? 0));

  return {
    featuredFixtureId: featured?.id ?? null,
    liveFixtureIds: topOf(feed.live),
    todayResultFixtureIds: topOf(feed.todayResults),
    yesterdayResultFixtureIds: topOf(feed.yesterdayResults),
    upcomingFixtureIds: topOf(feed.upcoming),
    rankedLeagueIds,
  };
}
