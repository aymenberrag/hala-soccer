import { useState } from "react";

import { usePreferencesDraft } from "@/context/PreferencesDraftContext";
import { useLeagueSearch } from "@/hooks/useFootball";
import { AppStateError } from "@/components/common/states";
import { OnboardingStepScaffold } from "./OnboardingStepScaffold";

export default function FavoriteLeaguesPage() {
  const [query, setQuery] = useState("");
  const { draft, hasLeague, toggleLeague, submit } = usePreferencesDraft();
  const search = useLeagueSearch(query);
  const [submitting, setSubmitting] = useState(false);
  const [submitError, setSubmitError] = useState<string | null>(null);

  async function finish() {
    setSubmitting(true);
    setSubmitError(null);
    const err = await submit();
    setSubmitting(false);
    if (err) setSubmitError(err);
    // On success the root gate redirects to Home once user.preferencesComplete flips true.
  }

  return (
    <OnboardingStepScaffold
      step={3}
      totalSteps={3}
      title="Favorite Leagues"
      subtitle="Pick the competitions you want front and center on Home."
      onSkip={finish}
      onNext={finish}
      nextLabel={draft.leagues.length === 0 ? "Finish" : `Finish (${draft.leagues.length} selected)`}
      loading={submitting}
      error={submitError}
    >
      <div className="flex flex-col gap-4">
        <input
          value={query}
          onChange={(e) => setQuery(e.target.value)}
          placeholder="Search leagues, e.g. Premier League"
          className="h-[52px] w-full rounded-[12px] border border-divider bg-surface-elevated px-4 text-sm text-text-primary outline-none placeholder:text-text-muted focus:border-brand-green-bright"
        />

        {draft.leagues.length > 0 && (
          <div>
            <span className="mb-2 block text-sm font-bold text-text-primary">Selected</span>
            <div className="flex flex-wrap gap-2">
              {draft.leagues.map((l) => (
                <span
                  key={l.id}
                  className="flex items-center gap-1.5 rounded-full border border-divider bg-surface-elevated py-1 pr-1 pl-3 text-sm text-text-primary"
                >
                  {l.name}
                  <button
                    onClick={() => toggleLeague(l)}
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
          <AppStateError message="Couldn't search leagues. Check your connection." onRetry={() => search.refetch()} />
        )}
        {!search.isLoading && query.trim().length >= 3 && search.data?.length === 0 && (
          <p className="py-6 text-center text-sm text-text-muted">No leagues found for "{query.trim()}".</p>
        )}
        <div className="flex flex-col gap-2">
          {search.data?.map((league) => {
            const selected = hasLeague(league.id);
            return (
              <button
                key={league.id}
                onClick={() => toggleLeague(league)}
                className={
                  "flex items-center gap-3 rounded-[12px] p-2 text-left " +
                  (selected ? "bg-brand-green-bright/10" : "bg-surface-card")
                }
              >
                <img src={league.logo} alt="" className="h-8 w-8 shrink-0" />
                <div className="min-w-0 flex-1">
                  <p className="truncate text-sm text-text-primary">{league.name}</p>
                  {league.country && <p className="truncate text-xs text-text-muted">{league.country}</p>}
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
