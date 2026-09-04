import type { LeagueSummary } from "@/types/models";

/** Leagues the app filters fixtures down to — same API-Sports plan scope as Flutter. */
export const trackedLeagueIds: number[] = [
  ...Array.from({ length: 9 }, (_, i) => i + 1), // 1..9
  ...Array.from({ length: 9 }, (_, i) => i + 12), // 12..20
  ...Array.from({ length: 12 }, (_, i) => i + 29), // 29..40
  45, 61, 66, 71, 78, 88, 94, 106, 113, 128, 140, 143, 556, 135, 137, 547,
];

export const featuredLeagues: LeagueSummary[] = [
  { id: 39, name: "Premier League", country: "England", logo: "https://media.api-sports.io/football/leagues/39.png" },
  { id: 140, name: "La Liga", country: "Spain", logo: "https://media.api-sports.io/football/leagues/140.png" },
  { id: 135, name: "Serie A", country: "Italy", logo: "https://media.api-sports.io/football/leagues/135.png" },
  { id: 78, name: "Bundesliga", country: "Germany", logo: "https://media.api-sports.io/football/leagues/78.png" },
  { id: 61, name: "Ligue 1", country: "France", logo: "https://media.api-sports.io/football/leagues/61.png" },
  { id: 94, name: "Primeira Liga", country: "Portugal", logo: "https://media.api-sports.io/football/leagues/94.png" },
  { id: 144, name: "Jupiler Pro League", country: "Belgium", logo: "https://media.api-sports.io/football/leagues/144.png" },
  { id: 88, name: "Eredivisie", country: "Netherlands", logo: "https://media.api-sports.io/football/leagues/88.png" },
  { id: 253, name: "Major League Soccer", country: "USA", logo: "https://media.api-sports.io/football/leagues/253.png" },
  { id: 203, name: "Süper Lig", country: "Turkey", logo: "https://media.api-sports.io/football/leagues/203.png" },
  { id: 262, name: "Liga MX", country: "Mexico", logo: "https://media.api-sports.io/football/leagues/262.png" },
  { id: 71, name: "Serie A", country: "Brazil", logo: "https://media.api-sports.io/football/leagues/71.png" },
];
