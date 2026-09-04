import { createContext, useCallback, useContext, useMemo, useState, type ReactNode } from "react";

import { useAuth } from "@/context/AuthContext";
import { profileService } from "@/services/profileService";
import { ApiException } from "@/services/apiException";
import type { LeagueSummary, Team } from "@/types/models";

interface PreferencesDraft {
  country: string | null;
  age: number | null;
  gender: string | null;
  teams: Team[];
  leagues: LeagueSummary[];
}

interface PreferencesDraftContextValue {
  draft: PreferencesDraft;
  setInfo: (info: { country?: string | null; age?: number | null; gender?: string | null }) => void;
  hasTeam: (id: number) => boolean;
  hasLeague: (id: number) => boolean;
  toggleTeam: (team: Team) => void;
  toggleLeague: (league: LeagueSummary) => void;
  submit: () => Promise<string | null>;
}

const PreferencesDraftContext = createContext<PreferencesDraftContextValue | null>(null);

const EMPTY_DRAFT: PreferencesDraft = { country: null, age: null, gender: null, teams: [], leagues: [] };

export function PreferencesDraftProvider({ children }: { children: ReactNode }) {
  const [draft, setDraft] = useState<PreferencesDraft>(EMPTY_DRAFT);
  const { setUser } = useAuth();

  const setInfo = useCallback((info: { country?: string | null; age?: number | null; gender?: string | null }) => {
    setDraft((d) => ({
      country: info.country !== undefined ? info.country : d.country,
      age: info.age !== undefined ? info.age : d.age,
      gender: info.gender !== undefined ? info.gender : d.gender,
      teams: d.teams,
      leagues: d.leagues,
    }));
  }, []);

  const hasTeam = useCallback((id: number) => draft.teams.some((t) => t.id === id), [draft.teams]);
  const hasLeague = useCallback((id: number) => draft.leagues.some((l) => l.id === id), [draft.leagues]);

  const toggleTeam = useCallback((team: Team) => {
    setDraft((d) => ({
      ...d,
      teams: d.teams.some((t) => t.id === team.id) ? d.teams.filter((t) => t.id !== team.id) : [...d.teams, team],
    }));
  }, []);

  const toggleLeague = useCallback((league: LeagueSummary) => {
    setDraft((d) => ({
      ...d,
      leagues: d.leagues.some((l) => l.id === league.id)
        ? d.leagues.filter((l) => l.id !== league.id)
        : [...d.leagues, league],
    }));
  }, []);

  const submit = useCallback(async (): Promise<string | null> => {
    try {
      const user = await profileService.saveOnboardingPreferences(
        draft.country,
        draft.age,
        draft.gender,
        draft.teams,
        draft.leagues,
      );
      setUser(user);
      return null;
    } catch (e) {
      return e instanceof ApiException ? e.message : "Something went wrong. Please try again.";
    }
  }, [draft, setUser]);

  const value = useMemo(
    () => ({ draft, setInfo, hasTeam, hasLeague, toggleTeam, toggleLeague, submit }),
    [draft, setInfo, hasTeam, hasLeague, toggleTeam, toggleLeague, submit],
  );

  return <PreferencesDraftContext.Provider value={value}>{children}</PreferencesDraftContext.Provider>;
}

export function usePreferencesDraft(): PreferencesDraftContextValue {
  const ctx = useContext(PreferencesDraftContext);
  if (!ctx) throw new Error("usePreferencesDraft must be used within a PreferencesDraftProvider");
  return ctx;
}
