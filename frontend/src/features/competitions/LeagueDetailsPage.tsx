import { useState } from "react";
import { useLocation, useNavigate, useParams } from "react-router-dom";

import { AppRoutes } from "@/app/routes";
import {
  useLeagueFixtures,
  useLeagueStandings,
  useLeagueTopAssists,
  useLeagueTopScorers,
  useRoundNavigation,
} from "@/hooks/useFootball";
import { AppStateEmpty, AppStateError, HomeFeedSkeleton, ShimmerBox } from "@/components/common/states";
import { FixtureCard } from "@/components/matches/FixtureCard";
import type { Fixture, StandingEntry, TopPlayerEntry } from "@/types/models";

type TabKey = "standings" | "fixtures" | "players";

export default function LeagueDetailsPage() {
  const { id } = useParams<{ id: string }>();
  const location = useLocation();
  const navigate = useNavigate();
  const leagueId = Number(id);
  const extra = (location.state as { name?: string; logo?: string; country?: string } | null) ?? {};
  const [tab, setTab] = useState<TabKey>("standings");

  return (
    <div className="min-h-dvh pb-4">
      <div className="flex items-center gap-2 px-4 py-3">
        <button onClick={() => navigate(-1)} className="text-xl text-text-primary">
          ‹
        </button>
        {extra.logo && <img src={extra.logo} alt="" className="h-6 w-6" />}
        <h1 className="truncate text-base font-bold text-text-primary">{extra.name ?? "League"}</h1>
      </div>

      <div className="flex gap-1 border-b border-divider px-4">
        {(
          [
            { key: "standings", label: "Standings" },
            { key: "fixtures", label: "Fixtures" },
            { key: "players", label: "Top Players" },
          ] as { key: TabKey; label: string }[]
        ).map((t) => (
          <button
            key={t.key}
            onClick={() => setTab(t.key)}
            className={
              "px-3 py-2.5 text-sm font-semibold " +
              (tab === t.key ? "border-b-2 border-brand-green-bright text-brand-green-bright" : "text-text-muted")
            }
          >
            {t.label}
          </button>
        ))}
      </div>

      {tab === "standings" && <StandingsTab leagueId={leagueId} />}
      {tab === "fixtures" && (
        <FixturesTab leagueId={leagueId} onOpen={(f) => navigate(AppRoutes.matchDetails(f.id), { state: { fixture: f } })} />
      )}
      {tab === "players" && <TopPlayersTab leagueId={leagueId} />}
    </div>
  );
}

function StandingsTab({ leagueId }: { leagueId: number }) {
  const query = useLeagueStandings(leagueId);
  if (query.isLoading) return <HomeFeedSkeleton />;
  if (query.isError) return <AppStateError message="Couldn't load standings." onRetry={() => query.refetch()} />;
  if (!query.data || query.data.length === 0) {
    return <AppStateEmpty message="Standings aren't available for this league yet." />;
  }
  return (
    <div className="px-2 py-2">
      <div className="flex items-center px-2 py-1 text-xs text-text-muted">
        <span className="w-7">#</span>
        <span className="flex-1">Team</span>
        <span className="w-8 text-center">P</span>
        <span className="w-8 text-center">GD</span>
        <span className="w-8 text-center">Pts</span>
      </div>
      {query.data.map((row) => (
        <StandingRow key={row.teamId} entry={row} />
      ))}
    </div>
  );
}

function StandingRow({ entry }: { entry: StandingEntry }) {
  return (
    <div className="flex items-center px-2 py-1.5">
      <span className="w-7 text-sm text-text-primary">{entry.rank}</span>
      <img src={entry.teamLogo} alt="" className="h-5 w-5 shrink-0" />
      <span className="ml-2 flex-1 truncate text-sm text-text-primary">{entry.teamName}</span>
      <span className="w-8 text-center text-xs text-text-muted">{entry.played}</span>
      <span className="w-8 text-center text-xs text-text-muted">
        {entry.goalsDiff > 0 ? `+${entry.goalsDiff}` : entry.goalsDiff}
      </span>
      <span className="w-8 text-center text-sm font-bold text-text-primary">{entry.points}</span>
    </div>
  );
}

function FixturesTab({ leagueId, onOpen }: { leagueId: number; onOpen: (f: Fixture) => void }) {
  // Keying on leagueId remounts this subtree (and resets roundIndex)
  // whenever the league changes — no effect needed.
  return <FixturesTabInner key={leagueId} leagueId={leagueId} onOpen={onOpen} />;
}

function FixturesTabInner({ leagueId, onOpen }: { leagueId: number; onOpen: (f: Fixture) => void }) {
  const nav = useRoundNavigation(leagueId);
  const [roundIndex, setRoundIndex] = useState<number | null>(null);

  if (nav.isLoading) return <HomeFeedSkeleton />;
  if (nav.isError) return <AppStateError message="Couldn't load rounds." onRetry={() => nav.refetch()} />;
  if (!nav.data || nav.data.rounds.length === 0) return <AppStateEmpty message="No fixtures found for this league yet." />;

  const index = Math.min(Math.max(roundIndex ?? nav.data.currentIndex, 0), nav.data.rounds.length - 1);
  const round = nav.data.rounds[index];

  return (
    <FixturesTabBody
      leagueId={leagueId}
      round={round}
      hasPrev={index > 0}
      hasNext={index < nav.data.rounds.length - 1}
      onPrev={() => setRoundIndex(index - 1)}
      onNext={() => setRoundIndex(index + 1)}
      onOpen={onOpen}
    />
  );
}

function FixturesTabBody({
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

function TopPlayersTab({ leagueId }: { leagueId: number }) {
  const scorers = useLeagueTopScorers(leagueId);
  const assists = useLeagueTopAssists(leagueId);

  return (
    <div className="px-4 py-4">
      <h2 className="mb-2 text-sm font-bold text-text-primary">Top Scorers</h2>
      {scorers.isLoading && <ShimmerBox height={120} />}
      {scorers.data && scorers.data.length === 0 && <p className="text-sm text-text-muted">No data available yet.</p>}
      {scorers.data?.slice(0, 10).map((p) => <PlayerStatRow key={p.playerId} player={p} label="goals" />)}

      <h2 className="mt-6 mb-2 text-sm font-bold text-text-primary">Top Assists</h2>
      {assists.isLoading && <ShimmerBox height={120} />}
      {assists.data && assists.data.length === 0 && <p className="text-sm text-text-muted">No data available yet.</p>}
      {assists.data?.slice(0, 10).map((p) => <PlayerStatRow key={p.playerId} player={p} label="assists" />)}
    </div>
  );
}

function PlayerStatRow({ player, label }: { player: TopPlayerEntry; label: string }) {
  return (
    <div className="flex items-center gap-2 py-1.5">
      {player.playerPhoto ? (
        <img src={player.playerPhoto} alt="" className="h-8 w-8 rounded-full object-cover" />
      ) : (
        <div className="flex h-8 w-8 items-center justify-center rounded-full bg-surface-elevated text-text-muted">?</div>
      )}
      <div className="min-w-0 flex-1">
        <p className="truncate text-sm text-text-primary">{player.playerName}</p>
        <p className="truncate text-xs text-text-muted">{player.teamName}</p>
      </div>
      <span className="text-sm font-bold text-text-primary">
        {player.value} {label}
      </span>
    </div>
  );
}
