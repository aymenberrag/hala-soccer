import axios from "axios";

import { ApiException } from "./apiException";

/**
 * SECURITY NOTE (see frontend/README.md "Known gaps" for the full writeup):
 * the Flutter app calls API-Sports.io directly from the client with an
 * embedded key, and this mirrors that same architecture per the rebuild
 * spec ("do not create a new football data system"). On mobile that key
 * ships inside a compiled APK; in a browser it is visible in plain text
 * to anyone who opens devtools, which is a materially bigger exposure.
 * Treat VITE_FOOTBALL_API_KEY as effectively public once this is deployed,
 * and consider proxying these calls through the Flask backend before
 * shipping to production — the backend intentionally doesn't do this yet
 * (see backend/app/__init__.py's module docstring).
 */
const FOOTBALL_API_BASE_URL = "https://v3.football.api-sports.io";
const FOOTBALL_API_KEY = import.meta.env.VITE_FOOTBALL_API_KEY ?? "";

const footballHttp = axios.create({
  baseURL: FOOTBALL_API_BASE_URL,
  timeout: 15_000,
  headers: { "x-apisports-key": FOOTBALL_API_KEY },
});

async function get(path: string, params: Record<string, string>): Promise<any> {
  try {
    const response = await footballHttp.get(path, { params });
    return response.data;
  } catch (err: any) {
    if (err.response) {
      throw new ApiException(`Football data request failed (${err.response.status})`, err.response.status);
    }
    throw new ApiException("Couldn't reach the football data service.");
  }
}

export const footballApi = {
  async fixturesByDate(yyyyMmDd: string): Promise<any[]> {
    const data = await get("/fixtures", { date: yyyyMmDd });
    return data.response;
  },

  async fixturesByLeagueAndRound(leagueId: number, season: number, round: string): Promise<any[]> {
    const data = await get("/fixtures", { league: String(leagueId), season: String(season), round });
    return data.response;
  },

  async currentRound(leagueId: number, season: number): Promise<string | null> {
    const data = await get("/fixtures/rounds", { league: String(leagueId), season: String(season), current: "true" });
    const response: string[] = data.response;
    return response.length > 0 ? response[0] : null;
  },

  async allRounds(leagueId: number, season: number): Promise<string[]> {
    const data = await get("/fixtures/rounds", { league: String(leagueId), season: String(season) });
    return data.response;
  },

  /** Returns the first standings group (list of row objects), or null. */
  async standings(leagueId: number, season: number): Promise<any[] | null> {
    const data = await get("/standings", { league: String(leagueId), season: String(season) });
    const response: any[] = data.response;
    if (response.length === 0) return null;
    const league = response[0].league;
    const groups: any[] = league.standings ?? [];
    return groups.length > 0 ? groups[0] : null;
  },

  async topScorers(leagueId: number, season: number): Promise<any[]> {
    const data = await get("/players/topscorers", { league: String(leagueId), season: String(season) });
    return data.response;
  },

  async topAssists(leagueId: number, season: number): Promise<any[]> {
    const data = await get("/players/topassists", { league: String(leagueId), season: String(season) });
    return data.response;
  },

  async searchTeams(query: string): Promise<any[]> {
    if (query.trim().length < 3) return [];
    const data = await get("/teams", { search: query.trim() });
    return data.response;
  },

  async searchLeagues(query: string): Promise<any[]> {
    if (query.trim().length < 3) return [];
    const data = await get("/leagues", { search: query.trim() });
    return data.response;
  },

  async fixtureById(fixtureId: number): Promise<any | null> {
    const data = await get("/fixtures", { id: String(fixtureId) });
    const response: any[] = data.response;
    return response.length > 0 ? response[0] : null;
  },

  async fixtureEvents(fixtureId: number): Promise<any[]> {
    const data = await get("/fixtures/events", { fixture: String(fixtureId) });
    return data.response;
  },

  async fixtureStatistics(fixtureId: number): Promise<any[]> {
    const data = await get("/fixtures/statistics", { fixture: String(fixtureId) });
    return data.response;
  },

  async fixtureLineups(fixtureId: number): Promise<any[]> {
    const data = await get("/fixtures/lineups", { fixture: String(fixtureId) });
    return data.response;
  },

  async headToHead(team1Id: number, team2Id: number): Promise<any[]> {
    const data = await get("/fixtures/headtohead", { h2h: `${team1Id}-${team2Id}`, last: "5" });
    return data.response;
  },
};
