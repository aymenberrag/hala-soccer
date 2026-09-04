import { useState } from "react";
import { useNavigate } from "react-router-dom";

import { AppRoutes } from "@/app/routes";
import { useLeagueFixtures, useRelevantLeagues, useRoundNavigation } from "@/hooks/useFootball";
import { FixtureCard } from "@/components/matches/FixtureCard";
import { AppStateEmpty, AppStateError, HomeFeedSkeleton } from "@/components/common/states";
import type { Fixture, LeagueSummary } from "@/types/models";

export default function MatchesPage() {
  const { data: leagues, isLoading } = useRelevantLeagues();
  const [selectedId, setSelectedId] = useState<number | null>(null);
  const navigate = useNavigate();

  const selected = leagues.find((l) => l.id === selectedId) ?? leagues[0] ?? null;

  return (
    <div className="pb-4">
      <h1 className="px-4 pt-4 pb-2 text-lg font-extrabold text-text-primary">Fixtures</h1>

      {isLoading && <HomeFeedSkeleton />}
      {!isLoading && leagues.length === 0 && <AppStateEmpty message="No leagues to show yet." />}

      {!isLoading && leagues.length > 0 && selected && (
        <>
          <LeagueSelector leagues={leagues} selectedId={selected.id} onSelect={setSelectedId} />
          <div className="border-t border-divider" />
          <RoundFixtures
            league={selected}
            onOpen={(f) => navigate(AppRoutes.matchDetails(f.id), { state: { fixture: f } })}
          />
        </>
      )}
    </div>
  );
}

function LeagueSelector({
  leagues,
  selectedId,
  onSelect,
}: {
  leagues: LeagueSummary[];
  selectedId: number;
  onSelect: (id: number) => void;
}) {
  return (
    <div className="scrollbar-thin flex gap-2 overflow-x-auto px-4 py-2">
      {leagues.map((l) => {
        const active = l.id === selectedId;
        return (
          <button
            key={l.id}
            onClick={() => onSelect(l.id)}
            className={
              "flex w-16 shrink-0 flex-col items-center gap-1 rounded-[12px] border py-2 " +
              (active ? "border-brand-green-bright bg-brand-green-bright/10" : "border-divider")
            }
          >
            {l.logo ? <img src={l.logo} alt="" className="h-7 w-7" /> : <span className="text-lg">🏆</span>}
            <span
              className={
                "line-clamp-1 max-w-full px-1 text-center text-[10px] font-semibold " +
                (active ? "text-brand-green-bright" : "text-text-muted")
              }
            >
              {l.name}
            </span>
          </button>
        );
      })}
    </div>
  );
}

function RoundFixtures({ league, onOpen }: { league: LeagueSummary; onOpen: (f: Fixture) => void }) {
  // Keying on league.id remounts this subtree (and resets roundIndex)
  // whenever the selected league changes — no effect needed.
  return <RoundFixturesInner key={league.id} league={league} onOpen={onOpen} />;
}

function RoundFixturesInner({ league, onOpen }: { league: LeagueSummary; onOpen: (f: Fixture) => void }) {
  const nav = useRoundNavigation(league.id);
  const [roundIndex, setRoundIndex] = useState<number | null>(null);

  if (nav.isLoading) return <HomeFeedSkeleton />;
  if (nav.isError) return <AppStateError message="Couldn't load rounds." onRetry={() => nav.refetch()} />;
  if (!nav.data || nav.data.rounds.length === 0) {
    return <AppStateEmpty message="No rounds found for this league yet." />;
  }

  const index = Math.min(Math.max(roundIndex ?? nav.data.currentIndex, 0), nav.data.rounds.length - 1);
  const round = nav.data.rounds[index];

  return (
    <RoundFixturesBody
      leagueId={league.id}
      round={round}
      hasPrev={index > 0}
      hasNext={index < nav.data.rounds.length - 1}
      onPrev={() => setRoundIndex(index - 1)}
      onNext={() => setRoundIndex(index + 1)}
      onOpen={onOpen}
    />
  );
}

function RoundFixturesBody({
  leagueId,
  round,
  hasPrev,
  hasNext,
  onPrev,
  onNext,
  onOpen,
}: {
  leagueId: number;
  round: string;
  hasPrev: boolean;
  hasNext: boolean;
  onPrev: () => void;
  onNext: () => void;
  onOpen: (f: Fixture) => void;
}) {
  const fixturesQuery = useLeagueFixtures(leagueId, round);

  return (
    <div>
      <div className="flex items-center justify-between px-2 py-2">
        <button onClick={onPrev} disabled={!hasPrev} className="px-2 text-xl text-text-primary disabled:text-text-muted/40">
          ‹
        </button>
        <span className="flex-1 truncate text-center text-sm font-bold text-text-primary">{round}</span>
        <button onClick={onNext} disabled={!hasNext} className="px-2 text-xl text-text-primary disabled:text-text-muted/40">
          ›
        </button>
      </div>

      {fixturesQuery.isLoading && <HomeFeedSkeleton />}
      {fixturesQuery.isError && (
        <AppStateError message="Couldn't load fixtures." onRetry={() => fixturesQuery.refetch()} />
      )}
      {fixturesQuery.data && fixturesQuery.data.length === 0 && <AppStateEmpty message="No fixtures for this round." />}
      {fixturesQuery.data && fixturesQuery.data.length > 0 && (
        <div className="flex flex-col gap-2 px-4 pb-4">
          {fixturesQuery.data.map((f) => (
            <FixtureCard key={f.id} fixture={f} onClick={() => onOpen(f)} />
          ))}
        </div>
      )}
    </div>
  );
}
