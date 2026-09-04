import { useState } from "react";
import { useNavigate } from "react-router-dom";

import { AppRoutes } from "@/app/routes";
import { usePreferencesDraft } from "@/context/PreferencesDraftContext";
import { useTeamSearch } from "@/hooks/useFootball";
import { AppStateError } from "@/components/common/states";
import { OnboardingStepScaffold } from "./OnboardingStepScaffold";

export default function FavoriteTeamsPage() {
  const [query, setQuery] = useState("");
  const { draft, hasTeam, toggleTeam } = usePreferencesDraft();
  const search = useTeamSearch(query);
  const navigate = useNavigate();

  function next() {
    navigate(AppRoutes.preferencesLeagues);
  }

  return (
    <OnboardingStepScaffold
      step={2}
      totalSteps={3}
      title="Favorite Teams"
      subtitle="Search and select the clubs you follow. You can pick as many as you like."
      onSkip={next}
      onNext={next}
      nextLabel={draft.teams.length === 0 ? "Continue" : `Continue (${draft.teams.length} selected)`}
    >
      <div className="flex flex-col gap-4">
        <input
          value={query}
          onChange={(e) => setQuery(e.target.value)}
          placeholder="Search teams, e.g. Real Madrid"
          className="h-[52px] w-full rounded-[12px] border border-divider bg-surface-elevated px-4 text-sm text-text-primary outline-none placeholder:text-text-muted focus:border-brand-green-bright"
        />

        {draft.teams.length > 0 && (
          <div>
            <span className="mb-2 block text-sm font-bold text-text-primary">Selected</span>
            <div className="flex flex-wrap gap-2">
              {draft.teams.map((t) => (
                <span
                  key={t.id}
                  className="flex items-center gap-1.5 rounded-full border border-divider bg-surface-elevated py-1 pr-1 pl-3 text-sm text-text-primary"
                >
                  {t.name}
                  <button
                    onClick={() => toggleTeam(t)}
                    className="flex h-5 w-5 items-center justify-center rounded-full text-text-muted"
                  >
                    ×
                  </button>
                </span>
              ))}
            </div>
          </div>
        )}

        {search.isLoading && <p className="py-6 text-center text-sm text-text-muted">Searching…</p>}
        {search.isError && (
          <AppStateError message="Couldn't search teams. Check your connection." onRetry={() => search.refetch()} />
        )}
        {!search.isLoading && query.trim().length >= 3 && search.data?.length === 0 && (
          <p className="py-6 text-center text-sm text-text-muted">No teams found for "{query.trim()}".</p>
        )}
        <div className="flex flex-col gap-2">
          {search.data?.map((team) => {
            const selected = hasTeam(team.id);
            return (
              <button
                key={team.id}
                onClick={() => toggleTeam(team)}
                className={
                  "flex items-center gap-3 rounded-[12px] p-2 text-left " +
                  (selected ? "bg-brand-green-bright/10" : "bg-surface-card")
                }
              >
                <img src={team.logo} alt="" className="h-8 w-8 shrink-0" />
                <div className="min-w-0 flex-1">
                  <p className="truncate text-sm text-text-primary">{team.name}</p>
                  {team.country && <p className="truncate text-xs text-text-muted">{team.country}</p>}
                </div>
                <span className={selected ? "text-brand-green-bright" : "text-text-muted"}>
                  {selected ? "✓" : "+"}
                </span>
              </button>
            );
          })}
        </div>
      </div>
    </OnboardingStepScaffold>
  );
}
