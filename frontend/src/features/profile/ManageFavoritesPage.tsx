import { useState } from "react";
import { useNavigate, useParams } from "react-router-dom";

import {
  useAddFavoriteLeague,
  useAddFavoriteTeam,
  useFavoriteLeagues,
  useFavoriteTeams,
  useRemoveFavoriteLeague,
  useRemoveFavoriteTeam,
} from "@/hooks/useFavorites";
import { useLeagueSearch, useTeamSearch } from "@/hooks/useFootball";

type Kind = "teams" | "leagues";

export default function ManageFavoritesPage() {
  const { kind } = useParams<{ kind: string }>();
  const isTeams = kind !== "leagues";
  return isTeams ? <ManageFavorites kind="teams" /> : <ManageFavorites kind="leagues" />;
}

function ManageFavorites({ kind }: { kind: Kind }) {
  const navigate = useNavigate();
  const [query, setQuery] = useState("");
  const isTeams = kind === "teams";

  const teamsQuery = useFavoriteTeams();
  const leaguesQuery = useFavoriteLeagues();
  const addTeam = useAddFavoriteTeam();
  const removeTeam = useRemoveFavoriteTeam();
  const addLeague = useAddFavoriteLeague();
  const removeLeague = useRemoveFavoriteLeague();
  const teamSearch = useTeamSearch(query);
  const leagueSearch = useLeagueSearch(query);

  return (
    <div className="min-h-dvh pb-4">
      <div className="flex items-center gap-2 px-4 py-3">
        <button onClick={() => navigate(-1)} className="text-xl text-text-primary">
          ‹
        </button>
        <h1 className="text-base font-bold text-text-primary">{isTeams ? "Favorite Teams" : "Favorite Leagues"}</h1>
      </div>

      <div className="px-4">
        <input
          value={query}
          onChange={(e) => setQuery(e.target.value)}
          placeholder={isTeams ? "Search teams" : "Search leagues"}
          className="h-[52px] w-full rounded-[12px] border border-divider bg-surface-elevated px-4 text-sm text-text-primary outline-none placeholder:text-text-muted focus:border-brand-green-bright"
        />

        {isTeams && teamsQuery.data && teamsQuery.data.length > 0 && (
          <div className="mt-4">
            <p className="mb-2 text-sm font-bold text-text-primary">Currently favorited</p>
            <div className="flex flex-col gap-2">
              {teamsQuery.data.map((fav) => (
                <Row
                  key={fav.id}
                  name={fav.teamName ?? "—"}
                  logo={fav.teamLogo}
                  trailingIcon="✓"
                  onClick={() => removeTeam.mutate(fav.id)}
                />
              ))}
            </div>
          </div>
        )}

        {!isTeams && leaguesQuery.data && leaguesQuery.data.length > 0 && (
          <div className="mt-4">
            <p className="mb-2 text-sm font-bold text-text-primary">Currently favorited</p>
            <div className="flex flex-col gap-2">
              {leaguesQuery.data.map((fav) => (
                <Row
                  key={fav.id}
                  name={fav.leagueName ?? "—"}
                  logo={fav.leagueLogo}
                  trailingIcon="✓"
                  onClick={() => removeLeague.mutate(fav.id)}
                />
              ))}
            </div>
          </div>
        )}

        <div className="mt-4 flex flex-col gap-2">
          {isTeams &&
            teamSearch.data?.map((team) => (
              <Row
                key={team.id}
                name={team.name}
                logo={team.logo}
                trailingIcon="+"
                onClick={() => addTeam.mutate({ id: team.id, name: team.name, logo: team.logo })}
              />
            ))}
          {!isTeams &&
            leagueSearch.data?.map((league) => (
              <Row
                key={league.id}
                name={league.name}
                logo={league.logo}
                trailingIcon="+"
                onClick={() =>
                  addLeague.mutate({ id: league.id, name: league.name, logo: league.logo, country: league.country })
                }
              />
            ))}
        </div>
      </div>
    </div>
  );
}

function Row({
  name,
  logo,
  trailingIcon,
  onClick,
}: {
  name: string;
  logo: string | null;
  trailingIcon: string;
  onClick: () => void;
}) {
  return (
    <div className="flex items-center gap-3 rounded-[12px] border border-divider bg-surface-card p-2">
      {logo ? <img src={logo} alt="" className="h-7 w-7 shrink-0" /> : <span className="text-lg">🛡️</span>}
      <span className="min-w-0 flex-1 truncate text-sm text-text-primary">{name}</span>
      <button onClick={onClick} className="text-text-muted">
        {trailingIcon}
      </button>
    </div>
  );
}
