import { useState } from "react";
import { useLocation, useNavigate, useParams } from "react-router-dom";

import { useFixtureDetails } from "@/hooks/useFootball";
import { AppStateEmpty, AppStateError, ShimmerBox } from "@/components/common/states";
import { FixtureCard } from "@/components/matches/FixtureCard";
import { AppRoutes } from "@/app/routes";
import {
  type Fixture,
  type FixtureDetails,
  type FixtureEvent,
  type TeamLineup,
  type TeamStatistics,
  fixtureScoreDisplay,
  fixtureStatusGroup,
  statValue,
} from "@/types/models";

type TabKey = "events" | "stats" | "lineups" | "h2h";

export default function FixtureDetailsPage() {
  const { id } = useParams<{ id: string }>();
  const location = useLocation();
  const navigate = useNavigate();
  const seed = (location.state as { fixture?: Fixture } | null)?.fixture ?? null;
  const fixtureId = Number(id);
  const query = useFixtureDetails(fixtureId, seed);

  return (
    <div className="min-h-dvh pb-4">
      <div className="flex items-center gap-2 px-4 py-3">
        <button onClick={() => navigate(-1)} className="text-xl text-text-primary">
          ‹
        </button>
        <h1 className="text-base font-bold text-text-primary">Match Details</h1>
      </div>

      {query.isLoading && (
        <div className="flex flex-col gap-4 p-4">
          <ShimmerBox height={160} />
          <ShimmerBox height={220} />
        </div>
      )}
      {query.isError && (
        <AppStateError
          message={query.error instanceof Error ? query.error.message : "Something went wrong."}
          onRetry={() => query.refetch()}
        />
      )}
      {query.data && (
        <FixtureDetailsBody
          details={query.data}
          onOpenFixture={(f) => navigate(AppRoutes.matchDetails(f.id), { state: { fixture: f } })}
        />
      )}
    </div>
  );
}

function FixtureDetailsBody({
  details,
  onOpenFixture,
}: {
  details: FixtureDetails;
  onOpenFixture: (f: Fixture) => void;
}) {
  const f = details.fixture;
  const hasEvents = details.events.length > 0;
  const hasStats = details.statistics.length > 0;
  const hasLineups = details.lineups.length > 0;
  const hasH2H = details.headToHead.length > 0;

  const tabs: { key: TabKey; label: string }[] = [
    ...(hasEvents ? [{ key: "events" as const, label: "Events" }] : []),
    ...(hasStats ? [{ key: "stats" as const, label: "Stats" }] : []),
    ...(hasLineups ? [{ key: "lineups" as const, label: "Lineups" }] : []),
    ...(hasH2H ? [{ key: "h2h" as const, label: "H2H" }] : []),
  ];
  const [tab, setTab] = useState<TabKey | null>(tabs[0]?.key ?? null);
  const active = tab ?? tabs[0]?.key ?? null;

  return (
    <div>
      <ScoreHeader fixture={f} />
      {tabs.length === 0 ? (
        <AppStateEmpty message="More details will appear closer to kickoff." />
      ) : (
        <>
          <div className="scrollbar-thin flex gap-1 overflow-x-auto border-b border-divider px-4">
            {tabs.map((t) => (
              <button
                key={t.key}
                onClick={() => setTab(t.key)}
                className={
                  "shrink-0 border-b-2 px-3 py-2.5 text-sm font-semibold " +
                  (active === t.key
                    ? "border-brand-green-bright text-brand-green-bright"
                    : "border-transparent text-text-muted")
                }
              >
                {t.label}
              </button>
            ))}
          </div>
          <div className="p-4">
            {active === "events" && <EventsTab events={details.events} />}
            {active === "stats" && <StatsTab statistics={details.statistics} />}
            {active === "lineups" && <LineupsTab lineups={details.lineups} />}
            {active === "h2h" && <H2HTab fixtures={details.headToHead} onOpen={onOpenFixture} />}
          </div>
        </>
      )}
    </div>
  );
}

function ScoreHeader({ fixture }: { fixture: Fixture }) {
  const group = fixtureStatusGroup(fixture);
  let statusLabel = fixture.statusShort;
  if (group === "live") statusLabel = fixture.elapsedMinutes != null ? `LIVE • ${fixture.elapsedMinutes}'` : "LIVE";
  else if (group === "finished") statusLabel = "Full Time";
  else if (group === "scheduled") {
    const d = new Date(fixture.kickoff);
    statusLabel = `${d.getDate()}/${d.getMonth() + 1} • ${String(d.getHours()).padStart(2, "0")}:${String(d.getMinutes()).padStart(2, "0")}`;
  }

  return (
    <div className="bg-brand-gradient-vertical px-6 py-6 text-center">
      <p className="text-xs text-white/70">{fixture.leagueName}</p>
      {fixture.round && <p className="text-[11px] text-white/50">{fixture.round}</p>}
      <div className="mt-5 flex items-center">
        <HeaderTeam name={fixture.homeTeamName} logo={fixture.homeTeamLogo} />
        <div className="flex shrink-0 flex-col items-center px-3">
          <span className="text-3xl font-extrabold text-white">{fixtureScoreDisplay(fixture)}</span>
          <span className={"mt-1 text-xs font-bold " + (group === "live" ? "text-live" : "text-white/70")}>
            {statusLabel}
          </span>
        </div>
        <HeaderTeam name={fixture.awayTeamName} logo={fixture.awayTeamLogo} alignEnd />
      </div>
      {fixture.venue && <p className="mt-3 text-xs text-white/70">🏟 {fixture.venue}</p>}
    </div>
  );
}

function HeaderTeam({ name, logo, alignEnd = false }: { name: string; logo: string; alignEnd?: boolean }) {
  return (
    <div className={"flex min-w-0 flex-1 flex-col gap-1 " + (alignEnd ? "items-end" : "items-start")}>
      <img src={logo} alt="" className="h-11 w-11" />
      <span className={"w-full truncate text-sm font-semibold text-white " + (alignEnd ? "text-right" : "text-left")}>
        {name}
      </span>
    </div>
  );
}

function EventsTab({ events }: { events: FixtureEvent[] }) {
  return (
    <div className="flex flex-col gap-3">
      {events.map((e, i) => {
        const isGoal = e.type.toLowerCase() === "goal";
        const isCard = e.type.toLowerCase() === "card";
        const isYellow = isCard && e.detail.toLowerCase().includes("yellow");
        const icon = isGoal ? "⚽" : e.type.toLowerCase() === "subst" ? "🔁" : isCard ? (isYellow ? "🟨" : "🟥") : "•";
        const minute = e.minute != null ? `${e.minute}${e.extraMinute != null ? `+${e.extraMinute}` : ""}'` : "";
        return (
          <div key={i} className="flex items-center gap-2">
            <span className="w-9 shrink-0 text-center text-xs text-text-muted">{minute}</span>
            <span>{icon}</span>
            <div className="min-w-0 flex-1">
              <p className="text-sm text-text-primary">{e.playerName}</p>
              <p className="text-xs text-text-muted">
                {e.detail}
                {e.assistName && ` • assist: ${e.assistName}`} • {e.teamName}
              </p>
            </div>
          </div>
        );
      })}
    </div>
  );
}

function StatsTab({ statistics }: { statistics: TeamStatistics[] }) {
  if (statistics.length < 2) return <AppStateEmpty message="Statistics aren't available for this match yet." />;
  const [home, away] = statistics;
  const types = [...new Set([...home.stats.map((s) => s.type), ...away.stats.map((s) => s.type)])];

  return (
    <div>
      <div className="mb-4 flex justify-between">
        <span className="truncate text-sm font-bold text-text-primary">{home.teamName}</span>
        <span className="truncate text-sm font-bold text-text-primary">{away.teamName}</span>
      </div>
      {types.map((type) => (
        <div key={type} className="mb-3">
          <div className="flex items-center justify-between">
            <span className="text-sm font-bold text-text-primary">{statValue(home, type) ?? "-"}</span>
            <span className="text-xs text-text-muted">{type}</span>
            <span className="text-sm font-bold text-text-primary">{statValue(away, type) ?? "-"}</span>
          </div>
          <div className="mt-1 border-b border-divider" />
        </div>
      ))}
    </div>
  );
}

function LineupsTab({ lineups }: { lineups: TeamLineup[] }) {
  return (
    <div className="flex flex-col gap-4">
      {lineups.map((team) => (
        <div key={team.teamName} className="rounded-[16px] border border-divider bg-surface-card p-4">
          <div className="flex items-center gap-2">
            <img src={team.teamLogo} alt="" className="h-6 w-6" />
            <span className="flex-1 truncate text-sm font-bold text-text-primary">{team.teamName}</span>
            {team.formation && <span className="text-xs text-brand-green-bright">{team.formation}</span>}
          </div>
          {team.coachName && <p className="mt-1 text-xs text-text-muted">Coach: {team.coachName}</p>}
          <p className="mt-3 text-xs font-bold text-text-secondary">Starting XI</p>
          {team.startXI.map((p, i) => (
            <PlayerRow key={i} player={p} />
          ))}
          {team.substitutes.length > 0 && (
            <>
              <p className="mt-3 text-xs font-bold text-text-secondary">Substitutes</p>
              {team.substitutes.map((p, i) => (
                <PlayerRow key={i} player={p} />
              ))}
            </>
          )}
        </div>
      ))}
    </div>
  );
}

function PlayerRow({ player }: { player: { name: string; position: string | null; number: number | null } }) {
  return (
    <div className="flex items-center gap-2 py-0.5">
      <span className="w-6 text-xs text-text-muted">{player.number ?? ""}</span>
      <span className="flex-1 truncate text-sm text-text-primary">{player.name}</span>
      {player.position && <span className="text-xs text-text-muted">{player.position}</span>}
    </div>
  );
}

function H2HTab({ fixtures, onOpen }: { fixtures: Fixture[]; onOpen: (f: Fixture) => void }) {
  return (
    <div className="flex flex-col gap-2">
      {fixtures.map((f) => (
        <FixtureCard key={f.id} fixture={f} onClick={() => onOpen(f)} />
      ))}
    </div>
  );
}
