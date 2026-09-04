import { useNavigate } from "react-router-dom";

import { AppRoutes } from "@/app/routes";
import { useAuth } from "@/context/AuthContext";
import { useCuratedHome } from "@/hooks/useFootball";
import { FixtureCard } from "@/components/matches/FixtureCard";
import { AppStateEmpty, AppStateError, HomeFeedSkeleton } from "@/components/common/states";
import { fixtureScoreDisplay } from "@/types/models";
import type { Fixture } from "@/types/models";

export default function HomePage() {
  const { user } = useAuth();
  const feed = useCuratedHome();
  const navigate = useNavigate();

  const openFixture = (f: Fixture) => navigate(AppRoutes.matchDetails(f.id), { state: { fixture: f } });

  return (
    <div className="pb-6">
      <header className="flex items-center justify-between px-4 pt-4 pb-2">
        <div>
          <h1 className="text-lg font-extrabold tracking-tight text-text-primary">HALA SOCCER</h1>
          {user?.name && <p className="text-xs text-text-muted">Welcome back, {user.name.split(" ")[0]}</p>}
        </div>
        <div className="bg-brand-gradient flex h-10 w-10 items-center justify-center rounded-full text-white">👤</div>
      </header>

      {feed.isLoading && <HomeFeedSkeleton />}
      {feed.isError && (
        <AppStateError message={feed.error instanceof Error ? feed.error.message : "Something went wrong."} onRetry={() => feed.refetch()} />
      )}
      {!feed.isLoading && !feed.isError && feed.isEmpty && (
        <AppStateEmpty message="No relevant matches right now. Check back soon." />
      )}

      {!feed.isLoading && !feed.isError && !feed.isEmpty && (
        <div className="flex flex-col gap-2">
          {feed.featured && <FeaturedFixture fixture={feed.featured} onClick={() => openFixture(feed.featured!)} />}
          <Section title="Live Now" fixtures={feed.live} onOpen={openFixture} />
          <Section title="Today's Results" fixtures={feed.todayResults} onOpen={openFixture} />
          <Section title="Yesterday's Results" fixtures={feed.yesterdayResults} onOpen={openFixture} />
          <Section title="Upcoming Matches" fixtures={feed.upcoming} onOpen={openFixture} />
        </div>
      )}
    </div>
  );
}

function Section({ title, fixtures, onOpen }: { title: string; fixtures: Fixture[]; onOpen: (f: Fixture) => void }) {
  if (fixtures.length === 0) return null;
  return (
    <section className="px-4 py-2">
      <h2 className="mb-2 text-base font-bold text-text-primary">{title}</h2>
      <div className="flex flex-col gap-2">
        {fixtures.map((f) => (
          <FixtureCard key={f.id} fixture={f} onClick={() => onOpen(f)} />
        ))}
      </div>
    </section>
  );
}

function FeaturedFixture({ fixture, onClick }: { fixture: Fixture; onClick: () => void }) {
  return (
    <div className="px-4 py-2">
      <button
        onClick={onClick}
        className="bg-brand-gradient shadow-card block w-full rounded-[24px] p-5 text-left"
      >
        <div className="flex items-center">
          <span className="rounded-full bg-white/20 px-2 py-0.5 text-[11px] font-bold text-white">
            {fixture.statusShort === "NS" ? "FEATURED MATCH" : "LIVE • FEATURED"}
          </span>
          <span className="ml-auto truncate text-[11px] text-white/70">{fixture.leagueName}</span>
        </div>
        <div className="mt-5 flex items-center">
          <FeaturedTeam name={fixture.homeTeamName} logo={fixture.homeTeamLogo} />
          <span className="shrink-0 px-2 text-3xl font-extrabold text-white">{fixtureScoreDisplay(fixture)}</span>
          <FeaturedTeam name={fixture.awayTeamName} logo={fixture.awayTeamLogo} alignEnd />
        </div>
      </button>
    </div>
  );
}

function FeaturedTeam({ name, logo, alignEnd = false }: { name: string; logo: string; alignEnd?: boolean }) {
  return (
    <div className={"flex min-w-0 flex-1 flex-col gap-1 " + (alignEnd ? "items-end" : "items-start")}>
      <img src={logo} alt="" className="h-10 w-10" />
      <span className={"w-full truncate text-sm font-semibold text-white " + (alignEnd ? "text-right" : "text-left")}>
        {name}
      </span>
    </div>
  );
}
