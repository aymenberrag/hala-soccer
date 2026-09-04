import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";

import { favoritesService } from "@/services/favoritesService";
import { footballRepository, homeFeedAll } from "@/services/footballRepository";
import { useHomeFeed } from "./useFootball";

export function useFavoriteTeams() {
  return useQuery({ queryKey: ["favorites", "teams"], queryFn: favoritesService.listTeams });
}

export function useFavoriteLeagues() {
  return useQuery({ queryKey: ["favorites", "leagues"], queryFn: favoritesService.listLeagues });
}

export function useFavoriteTeamIds() {
  const { data } = useFavoriteTeams();
  return new Set((data ?? []).map((t) => t.teamId));
}

export function useFavoriteLeagueIds() {
  const { data } = useFavoriteLeagues();
  return new Set((data ?? []).map((l) => l.leagueId));
}

export function useAddFavoriteTeam() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: (team: { id: number; name: string; logo: string }) =>
      favoritesService.addTeam(team.id, team.name, team.logo),
    onSuccess: () => qc.invalidateQueries({ queryKey: ["favorites", "teams"] }),
  });
}

export function useRemoveFavoriteTeam() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: (favoriteId: string) => favoritesService.removeTeam(favoriteId),
    onSuccess: () => qc.invalidateQueries({ queryKey: ["favorites", "teams"] }),
  });
}

export function useAddFavoriteLeague() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: (league: { id: number; name: string; logo: string; country: string | null }) =>
      favoritesService.addLeague(league.id, league.name, league.logo, league.country ?? undefined),
    onSuccess: () => qc.invalidateQueries({ queryKey: ["favorites", "leagues"] }),
  });
}

export function useRemoveFavoriteLeague() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: (favoriteId: string) => favoritesService.removeLeague(favoriteId),
    onSuccess: () => qc.invalidateQueries({ queryKey: ["favorites", "leagues"] }),
  });
}

/** Upcoming/recent matches involving favorite teams — spec section 11. */
export function useFavoritesActivity() {
  const feedQuery = useHomeFeed();
  const favTeamIds = useFavoriteTeamIds();

  const feed = feedQuery.data;
  const involvesFavorite = (homeId: number, awayId: number) => favTeamIds.has(homeId) || favTeamIds.has(awayId);

  const upcoming = feed
    ? [...feed.live, ...feed.upcoming].filter((f) => involvesFavorite(f.homeTeamId, f.awayTeamId))
    : [];
  const recentResults = feed
    ? [...feed.todayResults, ...feed.yesterdayResults].filter((f) => involvesFavorite(f.homeTeamId, f.awayTeamId))
    : [];

  return {
    isLoading: feedQuery.isLoading,
    upcoming,
    recentResults,
    isEmpty: upcoming.length === 0 && recentResults.length === 0,
  };
}

// Re-exported so callers of useFavoritesActivity don't need a second import
// just to know the shape of the underlying feed helper.
export { footballRepository, homeFeedAll };
