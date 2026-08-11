export type Skin = "hub" | "doomsday";

export function detectSkin(hostname = window.location.hostname): Skin {
  const h = hostname.toLowerCase();
  if (h.includes("doomsday")) return "doomsday";
  return "hub";
}

export function skinClass(skin: Skin): string {
  return skin === "doomsday" ? "skin-doomsday" : "skin-hub";
}
