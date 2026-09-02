/// Leagues the app filters fixtures down to. Ported verbatim from the
/// v1 `functions.dart` — same league IDs the API-Sports account/plan
/// was already scoped to. Don't add league IDs the API key isn't
/// entitled to without checking with API-Sports first.
final trackedLeagueIds = <int>[
  for (int i = 1; i < 10; i++) i,
  for (int i = 12; i < 21; i++) i,
  for (int i = 29; i < 41; i++) i,
  45,
  61,
  66,
  71,
  78,
  88,
  94,
  106,
  113,
  128,
  140,
  143,
  556,
  135,
  137,
  547,
];

/// Display metadata for browsable competitions (Competitions tab).
/// Ported from v1 `data.dart`.
final featuredLeagues = <Map<String, Object>>[
  {"id": 39, "name": "Premier League", "country": "England", "logo": "https://media.api-sports.io/football/leagues/39.png"},
  {"id": 140, "name": "La Liga", "country": "Spain", "logo": "https://media.api-sports.io/football/leagues/140.png"},
  {"id": 135, "name": "Serie A", "country": "Italy", "logo": "https://media.api-sports.io/football/leagues/135.png"},
  {"id": 78, "name": "Bundesliga", "country": "Germany", "logo": "https://media.api-sports.io/football/leagues/78.png"},
  {"id": 61, "name": "Ligue 1", "country": "France", "logo": "https://media.api-sports.io/football/leagues/61.png"},
  {"id": 94, "name": "Primeira Liga", "country": "Portugal", "logo": "https://media.api-sports.io/football/leagues/94.png"},
  {"id": 144, "name": "Jupiler Pro League", "country": "Belgium", "logo": "https://media.api-sports.io/football/leagues/144.png"},
  {"id": 88, "name": "Eredivisie", "country": "Netherlands", "logo": "https://media.api-sports.io/football/leagues/88.png"},
  {"id": 253, "name": "Major League Soccer", "country": "USA", "logo": "https://media.api-sports.io/football/leagues/253.png"},
  {"id": 203, "name": "Süper Lig", "country": "Turkey", "logo": "https://media.api-sports.io/football/leagues/203.png"},
  {"id": 262, "name": "Liga MX", "country": "Mexico", "logo": "https://media.api-sports.io/football/leagues/262.png"},
  {"id": 71, "name": "Serie A", "country": "Brazil", "logo": "https://media.api-sports.io/football/leagues/71.png"},
];
