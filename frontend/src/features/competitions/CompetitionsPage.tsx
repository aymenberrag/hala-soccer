import { useNavigate } from "react-router-dom";

import { AppRoutes } from "@/app/routes";
import { useRelevantLeagues } from "@/hooks/useFootball";
import { AppStateEmpty, HomeFeedSkeleton } from "@/components/common/states";
import type { LeagueSummary } from "@/types/models";

export default function CompetitionsPage() {
  const { data: leagues, isLoading } = useRelevantLeagues();
  const navigate = useNavigate();

  return (
    <div className="pb-4">
      <h1 className="px-4 pt-4 pb-2 text-lg font-extrabold text-text-primary">Leagues</h1>

      {isLoading && <HomeFeedSkeleton />}
      {!isLoading && leagues.length === 0 && <AppStateEmpty message="No leagues to show yet." />}

      {!isLoading && leagues.length > 0 && (
        <div className="flex flex-col gap-2 px-4">
          {leagues.map((l) => (
            <LeagueRow
              key={l.id}
              league={l}
              onClick={() =>
                navigate(AppRoutes.competitionDetails(l.id), {
                  state: { name: l.name, logo: l.logo, country: l.country },
                })
              }
            />
          ))}
        </div>
      )}
    </div>
  );
}

function LeagueRow({ league, onClick }: { league: LeagueSummary; onClick: () => void }) {
  return (
    <button
      onClick={onClick}
      className="flex items-center gap-3 rounded-[16px] border border-divider bg-surface-card p-4 text-left"
    >
      {league.logo ? <img src={league.logo} alt="" className="h-9 w-9 shrink-0" /> : <span className="text-2xl">🏆</span>}
      <div className="min-w-0 flex-1">
        <p className="truncate text-sm font-bold text-text-primary">{league.name}</p>
        {league.country && <p className="truncate text-xs text-text-muted">{league.country}</p>}
      </div>
      <span className="text-text-muted">›</span>
    </button>
  );
}
