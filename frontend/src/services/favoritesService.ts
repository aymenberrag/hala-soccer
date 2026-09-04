import { backendApi } from "./backendApi";
import { type FavoriteLeague, type FavoriteTeam, parseFavoriteLeague, parseFavoriteTeam } from "@/types/models";

export const favoritesService = {
  async listTeams(): Promise<FavoriteTeam[]> {
    const { data } = await backendApi.get("/api/favorites");
    const items: any[] = data.teams ?? data.favorites ?? [];
    return items.map(parseFavoriteTeam);
  },

  async addTeam(teamId: number, teamName?: string, teamLogo?: string): Promise<void> {
    await backendApi.post("/api/favorites", { team_id: teamId, team_name: teamName, team_logo: teamLogo });
  },

  async removeTeam(favoriteId: string): Promise<void> {
    await backendApi.delete(`/api/favorites/${favoriteId}`);
  },

  async listLeagues(): Promise<FavoriteLeague[]> {
    const { data } = await backendApi.get("/api/favorites/leagues");
    const items: any[] = data.leagues ?? [];
    return items.map(parseFavoriteLeague);
  },

  async addLeague(leagueId: number, leagueName?: string, leagueLogo?: string, leagueCountry?: string): Promise<void> {
    await backendApi.post("/api/favorites/leagues", {
      league_id: leagueId,
      league_name: leagueName,
      league_logo: leagueLogo,
      league_country: leagueCountry,
    });
  },

  async removeLeague(favoriteId: string): Promise<void> {
    await backendApi.delete(`/api/favorites/leagues/${favoriteId}`);
  },
};
