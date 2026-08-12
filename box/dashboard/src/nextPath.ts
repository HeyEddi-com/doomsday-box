/** Same-origin relative path only (blocks //evil.com open redirects). */
export function safeNextPath(raw: unknown): string | null {
  if (typeof raw !== "string") return null;
  if (!raw.startsWith("/") || raw.startsWith("//")) return null;
  return raw;
}
