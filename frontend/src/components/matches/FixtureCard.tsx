import type { SyntheticEvent } from "react";

import { type Fixture, fixtureScoreDisplay, fixtureStatusGroup } from "@/types/models";
import { fixtureDateLabel, fixtureTimeLabel } from "@/utils/fixtureDateLabel";

export function FixtureCard({ fixture, onClick }: { fixture: Fixture; onClick?: () => void }) {
  return (
    <button
      type="button"
      onClick={onClick}
      className="block w-full rounded-[16px] border border-divider bg-surface-card p-4 text-left"
    >
      <div className="flex items-center gap-1">
        <img src={fixture.leagueLogo} alt="" className="h-4 w-4 shrink-0" onError={hideOnError} />
        <span className="min-w-0 flex-1 truncate text-xs font-medium text-text-muted">{fixture.leagueName}</span>
        <span className="shrink-0 text-xs font-medium text-text-muted">{fixtureDateLabel(fixture.kickoff)}</span>
        <StatusPill fixture={fixture} />
      </div>
      <div className="mt-2 flex items-center">
        <TeamRow name={fixture.homeTeamName} logo={fixture.homeTeamLogo} />
        <span className="shrink-0 px-2 text-base font-bold text-text-primary">{fixtureScoreDisplay(fixture)}</span>
        <TeamRow name={fixture.awayTeamName} logo={fixture.awayTeamLogo} alignEnd />
      </div>
    </button>
  );
}

function hideOnError(e: SyntheticEvent<HTMLImageElement>) {
  e.currentTarget.style.visibility = "hidden";
}

function TeamRow({ name, logo, alignEnd = false }: { name: string; logo: string; alignEnd?: boolean }) {
  const image = <img src={logo} alt="" className="h-6 w-6 shrink-0" onError={hideOnError} />;
  const text = (
    <span className={"min-w-0 flex-1 truncate text-sm text-text-primary " + (alignEnd ? "text-right" : "text-left")}>
      {name}
    </span>
  );
  return (
    <div className="flex min-w-0 flex-1 items-center gap-1.5">
      {alignEnd ? (
        <>
          {text}
          {image}
        </>
      ) : (
        <>
          {image}
          {text}
        </>
      )}
    </div>
  );
}

function StatusPill({ fixture }: { fixture: Fixture }) {
  const group = fixtureStatusGroup(fixture);
  let color = "var(--color-text-muted)";
  let label = fixture.statusShort;

  if (group === "live") {
    color = "var(--color-live)";
    label = fixture.elapsedMinutes != null ? `${fixture.elapsedMinutes}'` : "LIVE";
  } else if (group === "finished") {
    color = "var(--color-text-muted)";
    label = "FT";
  } else if (group === "scheduled") {
    color = "var(--color-brand-green-bright)";
    label = fixtureTimeLabel(fixture.kickoff);
  }

  return (
    <span
      className="ml-2 shrink-0 rounded-full px-2 py-0.5 text-xs font-bold"
      style={{ color, backgroundColor: `color-mix(in srgb, ${color} 15%, transparent)` }}
    >
      {label}
    </span>
  );
}
