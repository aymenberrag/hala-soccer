const WEEKDAY_NAMES = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"];

/**
 * Today / Tomorrow / Yesterday / a weekday name (within the next 6 days,
 * e.g. Friday) / or a plain d-M-yyyy date — ported from fixtureDateLabel()
 * in fixture_card.dart.
 */
export function fixtureDateLabel(kickoffIso: string, now: Date = new Date()): string {
  const kickoff = new Date(kickoffIso);
  const a = new Date(now.getFullYear(), now.getMonth(), now.getDate());
  const b = new Date(kickoff.getFullYear(), kickoff.getMonth(), kickoff.getDate());
  const diffDays = Math.round((b.getTime() - a.getTime()) / 86_400_000);

  if (diffDays === 0) return "Today";
  if (diffDays === 1) return "Tomorrow";
  if (diffDays === -1) return "Yesterday";
  if (diffDays > 1 && diffDays < 7) return WEEKDAY_NAMES[kickoff.getDay()];
  return `${kickoff.getDate()}-${kickoff.getMonth() + 1}-${kickoff.getFullYear()}`;
}

export function fixtureTimeLabel(kickoffIso: string): string {
  const d = new Date(kickoffIso);
  return `${String(d.getHours()).padStart(2, "0")}:${String(d.getMinutes()).padStart(2, "0")}`;
}
