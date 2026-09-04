import { footballApi } from "./footballApi";
import { trackedLeagueIds } from "@/utils/leagueConstants";
import {
  type Fixture,
  type FixtureDetails,
  type LeagueSummary,
  type StandingEntry,
  type Team,
  type TopPlayerEntry,
  fixtureStatusGroup,
  parseFixture,
  parseFixtureEvent,
  parseLeagueSummary,
  parseStandingEntry,
  parseTeam,
  parseTeamLineup,
  parseTeamStatistics,
  parseTopPlayerEntry,
} from "@/types/models";

export interface HomeFeed {
  live: Fixture[];
  upcoming: Fixture[];
  todayResults: Fixture[];
  yesterdayResults: Fixture[];
}

export function homeFeedAll(feed: HomeFeed): Fixture[] {
  return [...feed.live, ...feed.upcoming, ...feed.todayResults, ...feed.yesterdayResults];
}

export function homeFeedIsEmpty(feed: HomeFeed): boolean {
  return feed.live.length === 0 && feed.upcoming.length === 0 && feed.todayResults.length === 0 && feed.yesterdayResults.length === 0;
}

export interface RoundNavigation {
  rounds: string[];
  currentIndex: number;
}

/** European domestic leagues run Aug-May; before August we're still in the season that started the previous year. */
export function currentSeason(now: Date = new Date()): number {
  return now.getMonth() + 1 >= 8 ? now.getFullYear() : now.getFullYear() - 1;
}

function fmtDate(d: Date): string {
  const y = String(d.getFullYear()).padStart(4, "0");
  const m = String(d.getMonth() + 1).padStart(2, "0");
  const day = String(d.getDate()).padStart(2, "0");
  return `${y}-${m}-${day}`;
}

export const footballRepository = {
  async fixturesForDate(date: Date): Promise<Fixture[]> {
    const raw = await footballApi.fixturesByDate(fmtDate(date));
    return raw.filter((f) => trackedLeagueIds.includes(f.league.id)).map(parseFixture);
  },

  async homeFeed(date: Date = new Date()): Promise<HomeFeed> {
    const yesterday = new Date(date);
    yesterday.setDate(yesterday.getDate() - 1);

    const [todayFixtures, yesterdayFixtures] = await Promise.all([
      footballRepository.fixturesForDate(date),
      footballRepository.fixturesForDate(yesterday),
    ]);

    return {
      live: todayFixtures.filter((f) => fixtureStatusGroup(f) === "live"),
      upcoming: todayFixtures.filter((f) => fixtureStatusGroup(f) === "scheduled"),
      todayResults: todayFixtures.filter((f) => fixtureStatusGroup(f) === "finished"),
      yesterdayResults: yesterdayFixtures.filter((f) => fixtureStatusGroup(f) === "finished"),
    };
  },

  async leagueFixtures(leagueId: number, round?: string | null): Promise<Fixture[]> {
    const season = currentSeason();
    const r = round ?? (await footballApi.currentRound(leagueId, season));
    if (!r) return [];
    const raw = await footballApi.fixturesByLeagueAndRound(leagueId, season, r);
    return raw.map(parseFixture);
  },

  async roundNavigation(leagueId: number): Promise<RoundNavigation> {
    const season = currentSeason();
    const [rounds, current] = await Promise.all([
      footballApi.allRounds(leagueId, season),
      footballApi.currentRound(leagueId, season),
    ]);
    const idx = current != null ? rounds.indexOf(current) : -1;
    return { rounds, currentIndex: idx };
  },

  async leagueStandings(leagueId: number): Promise<StandingEntry[]> {
    const raw = await footballApi.standings(leagueId, currentSeason());
    if (!raw) return [];
    return raw.map(parseStandingEntry);
  },

  async leagueTopScorers(leagueId: number): Promise<TopPlayerEntry[]> {
    const raw = await footballApi.topScorers(leagueId, currentSeason());
    return raw.map((e) => parseTopPlayerEntry(e, false));
  },

  async leagueTopAssists(leagueId: number): Promise<TopPlayerEntry[]> {
    const raw = await footballApi.topAssists(leagueId, currentSeason());
    return raw.map((e) => parseTopPlayerEntry(e, true));
  },

  async fixtureById(fixtureId: number): Promise<Fixture | null> {
    const raw = await footballApi.fixtureById(fixtureId);
    return raw ? parseFixture(raw) : null;
  },

  async searchTeams(query: string): Promise<Team[]> {
    const raw = await footballApi.searchTeams(query);
    return raw.map(parseTeam);
  },

  async searchLeagues(query: string): Promise<LeagueSummary[]> {
    const raw = await footballApi.searchLeagues(query);
    return raw.map(parseLeagueSummary);
  },

  async fixtureDetails(fixture: Fixture): Promise<FixtureDetails> {
    const [events, statistics, lineups, headToHead] = await Promise.all([
      footballApi.fixtureEvents(fixture.id),
      footballApi.fixtureStatistics(fixture.id),
      footballApi.fixtureLineups(fixture.id),
      footballApi.headToHead(fixture.homeTeamId, fixture.awayTeamId),
    ]);

    return {
      fixture,
      events: events.map(parseFixtureEvent),
      statistics: statistics.map(parseTeamStatistics),
      lineups: lineups.map(parseTeamLineup),
      headToHead: headToHead.map(parseFixture),
    };
  },
};
