import { backendApi } from "./backendApi";
import { type AppUser, type LeagueSummary, type Team, parseAppUser } from "@/types/models";

export const profileService = {
  async saveOnboardingPreferences(
    country: string | null,
    age: number | null,
    gender: string | null,
    teams: Team[],
    leagues: LeagueSummary[],
  ): Promise<AppUser> {
    const { data } = await backendApi.post("/api/profile/onboarding-preferences", {
      country,
      age,
      gender,
      favorite_teams: teams.map((t) => ({ team_id: t.id, team_name: t.name, team_logo: t.logo })),
      favorite_leagues: leagues.map((l) => ({
        league_id: l.id,
        league_name: l.name,
        league_logo: l.logo,
        league_country: l.country,
      })),
    });
    return parseAppUser(data);
  },

  async updatePersonalInfo(
    fields: { name?: string; country?: string; age?: number; gender?: string },
  ): Promise<AppUser> {
    const { data } = await backendApi.patch("/api/profile", fields);
    return parseAppUser(data);
  },

  async changePassword(currentPassword: string, newPassword: string): Promise<void> {
    await backendApi.post("/api/profile/change-password", {
      current_password: currentPassword,
      new_password: newPassword,
    });
  },
};
