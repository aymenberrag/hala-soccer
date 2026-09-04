import { useQuery } from "@tanstack/react-query";

import { featuredLeagues } from "@/utils/leagueConstants";
import { footballRepository, homeFeedAll } from "@/services/footballRepository";
import type { Fixture, LeagueSummary } from "@/types/models";
import { useFavoriteLeagueIds, useFavoriteLeagues, useFavoriteTeamIds } from "./useFavorites";
import { curateHome } from "@/services/curationService";

const STALE_5_MIN = 5 * 60 * 1000;

export function useHomeFeed() {
  return useQuery({
    queryKey: ["football", "homeFeed"],
    queryFn: () => footballRepository.homeFeed(),
    staleTime: STALE_5_MIN,
  });
}

/** Featured/live/today/yesterday/upcoming, ranked by the rule-based curator (spec sections 4-6). */
export function useCuratedHome() {
  const feedQuery = useHomeFeed();
  const favTeamIds = useFavoriteTeamIds();
  const favLeagueIds = useFavoriteLeagueIds();

  const feed = feedQuery.data;
  const curation = feed ? curateHome(feed, [...favTeamIds], [...favLeagueIds]) : null;

  const byId = new Map<number, Fixture>();
  if (feed) for (const f of homeFeedAll(feed)) byId.set(f.id, f);
  const resolve = (ids: number[]) => ids.map((id) => byId.get(id)).filter((f): f is Fixture => !!f);

  return {
    isLoading: feedQuery.isLoading,
    isError: feedQuery.isError,
    error: feedQuery.error,
    refetch: feedQuery.refetch,
    featured: curation?.featuredFixtureId != null ? (byId.get(curation.featuredFixtureId) ?? null) : null,
    live: curation ? resolve(curation.liveFixtureIds) : [],
    todayResults: curation ? resolve(curation.todayResultFixtureIds) : [],
    yesterdayResults: curation ? resolve(curation.yesterdayResultFixtureIds) : [],
    upcoming: curation ? resolve(curation.upcomingFixtureIds) : [],
    rankedLeagueIds: curation?.rankedLeagueIds ?? [],
    isEmpty: !!curation && !curation.featuredFixtureId && homeFeedAll(feed!).length === 0,
  };
}

/** Fixtures/Leagues page league selector: favorites -> important -> AI-ranked, deduplicated (spec sections 7, 9). */
export function useRelevantLeagues(): { data: LeagueSummary[]; isLoading: boolean } {
  const favLeaguesQuery = useFavoriteLeagues();
  const feedQuery = useHomeFeed();
  const favTeamIds = useFavoriteTeamIds();
  const favLeagueIds = useFavoriteLeagueIds();

  const feed = feedQuery.data;
  const curation = feed ? curateHome(feed, [...favTeamIds], [...favLeagueIds]) : null;

  const byId = new Map<number, LeagueSummary>();
  for (const fav of favLeaguesQuery.data ?? []) {
    byId.set(fav.leagueId, {
      id: fav.leagueId,
      name: fav.leagueName ?? `League #${fav.leagueId}`,
      logo: fav.leagueLogo ?? "",
      country: fav.leagueCountry,
    });
  }
  for (const l of featuredLeagues) {
    if (!byId.has(l.id)) byId.set(l.id, l);
  }
  if (feed) {
    const metaFromFixtures = new Map(homeFeedAll(feed).map((f) => [f.leagueId, f]));
    for (const id of curation?.rankedLeagueIds ?? []) {
      if (byId.has(id)) continue;
      const f = metaFromFixtures.get(id);
      if (f) byId.set(id, { id, name: f.leagueName, logo: f.leagueLogo, country: f.leagueCountry });
    }
  }

  return {
    data: [...byId.values()].slice(0, 16),
    isLoading: favLeaguesQuery.isLoading || feedQuery.isLoading,
  };
}

export function useRoundNavigation(leagueId: number | null) {
  return useQuery({
    queryKey: ["football", "roundNavigation", leagueId],
    queryFn: () => footballRepository.roundNavigation(leagueId as number),
    enabled: leagueId != null,
    staleTime: STALE_5_MIN,
  });
}

export function useLeagueFixtures(leagueId: number | null, round: string | null | undefined) {
  return useQuery({
    queryKey: ["football", "leagueFixtures", leagueId, round],
    queryFn: () => footballRepository.leagueFixtures(leagueId as number, round),
    enabled: leagueId != null && round !== undefined,
    staleTime: STALE_5_MIN,
  });
}

export function useLeagueStandings(leagueId: number) {
  return useQuery({
    queryKey: ["football", "standings", leagueId],
    queryFn: () => footballRepository.leagueStandings(leagueId),
    staleTime: STALE_5_MIN,
  });
}

export function useLeagueTopScorers(leagueId: number) {
  return useQuery({
    queryKey: ["football", "topScorers", leagueId],
    queryFn: () => footballRepository.leagueTopScorers(leagueId),
    staleTime: STALE_5_MIN,
  });
}

export function useLeagueTopAssists(leagueId: number) {
  return useQuery({
    queryKey: ["football", "topAssists", leagueId],
    queryFn: () => footballRepository.leagueTopAssists(leagueId),
    staleTime: STALE_5_MIN,
  });
}

export function useFixtureDetails(fixtureId: number, seed?: Fixture | null) {
  return useQuery({
    queryKey: ["football", "fixtureDetails", fixtureId],
    queryFn: async () => {
      const fixture = seed ?? (await footballRepository.fixtureById(fixtureId));
      if (!fixture) throw new Error("Fixture not found.");
      return footballRepository.fixtureDetails(fixture);
    },
    staleTime: 60 * 1000,
  });
}

export function useTeamSearch(query: string) {
  return useQuery({
    queryKey: ["football", "searchTeams", query],
    queryFn: () => footballRepository.searchTeams(query),
    enabled: query.trim().length >= 3,
  });
}

export function useLeagueSearch(query: string) {
  return useQuery({
    queryKey: ["football", "searchLeagues", query],
    queryFn: () => footballRepository.searchLeagues(query),
    enabled: query.trim().length >= 3,
  });
}
