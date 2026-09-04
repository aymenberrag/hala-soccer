import { useNavigate } from "react-router-dom";

import { AppRoutes } from "@/app/routes";
import {
  useFavoriteLeagues,
  useFavoriteTeams,
  useFavoritesActivity,
  useRemoveFavoriteLeague,
  useRemoveFavoriteTeam,
} from "@/hooks/useFavorites";
import { AppStateEmpty, HomeFeedSkeleton } from "@/components/common/states";
import { FixtureCard } from "@/components/matches/FixtureCard";
import type { Fixture } from "@/types/models";

export default function FavoritesPage() {
  const teamsQuery = useFavoriteTeams();
  const leaguesQuery = useFavoriteLeagues();
  const activity = useFavoritesActivity();
  const removeTeam = useRemoveFavoriteTeam();
  const removeLeague = useRemoveFavoriteLeague();
  const navigate = useNavigate();

  const loading = teamsQuery.isLoading && leaguesQuery.isLoading;
  const isEmpty = (teamsQuery.data?.length ?? 0) === 0 && (leaguesQuery.data?.length ?? 0) === 0;

  const openFixture = (f: Fixture) => navigate(AppRoutes.matchDetails(f.id), { state: { fixture: f } });

  return (
    <div className="pb-4">
      <h1 className="px-4 pt-4 pb-2 text-lg font-extrabold text-text-primary">Favorites</h1>

      {loading && <HomeFeedSkeleton />}

      {!loading && isEmpty && (
        <AppStateEmpty
          icon={<span className="text-4xl">⭐</span>}
          message={"You haven't favorited any teams or leagues yet.\nAdd some from Profile."}
        />
      )}

      {!loading && !isEmpty && (
        <div className="flex flex-col gap-6 px-4">
          {teamsQuery.data && teamsQuery.data.length > 0 && (
            <section>
              <h2 className="mb-2 text-sm font-bold text-text-primary">My Teams</h2>
              <div className="flex flex-col gap-2">
                {teamsQuery.data.map((fav) => (
                  <FavoriteRow
                    key={fav.id}
                    name={fav.teamName ?? `Team #${fav.teamId}`}
                    logo={fav.teamLogo}
                    onRemove={() => removeTeam.mutate(fav.id)}
                  />
                ))}
              </div>
            </section>
          )}

          {leaguesQuery.data && leaguesQuery.data.length > 0 && (
            <section>
              <h2 className="mb-2 text-sm font-bold text-text-primary">My Leagues</h2>
              <div className="flex flex-col gap-2">
                {leaguesQuery.data.map((fav) => (
                  <FavoriteRow
                    key={fav.id}
                    name={fav.leagueName ?? `League #${fav.leagueId}`}
                    logo={fav.leagueLogo}
                    onRemove={() => removeLeague.mutate(fav.id)}
                  />
                ))}
              </div>
            </section>
          )}

          {activity.upcoming.length > 0 && (
            <section>
              <h2 className="mb-2 text-sm font-bold text-text-primary">Upcoming</h2>
              <div className="flex flex-col gap-2">
                {activity.upcoming.map((f) => (
                  <FixtureCard key={f.id} fixture={f} onClick={() => openFixture(f)} />
                ))}
              </div>
            </section>
          )}

          {activity.recentResults.length > 0 && (
            <section>
              <h2 className="mb-2 text-sm font-bold text-text-primary">Recent Results</h2>
              <div className="flex flex-col gap-2">
                {activity.recentResults.map((f) => (
                  <FixtureCard key={f.id} fixture={f} onClick={() => openFixture(f)} />
                ))}
              </div>
            </section>
          )}
        </div>
      )}
    </div>
  );
}

function FavoriteRow({ name, logo, onRemove }: { name: string; logo: string | null; onRemove: () => void }) {
  return (
    <div className="flex items-center gap-3 rounded-[16px] border border-divider bg-surface-card p-3">
      {logo ? <img src={logo} alt="" className="h-7 w-7 shrink-0" /> : <span className="text-xl">🛡️</span>}
      <span className="flex-1 truncate text-sm text-text-primary">{name}</span>
      <button onClick={onRemove} className="text-text-muted">
        ✕
      </button>
    </div>
  );
}
