import { describe, expect, it } from "vitest";
import { safeNextPath } from "./nextPath";

describe("safeNextPath", () => {
  it("allows hub and desktop relative paths", () => {
    expect(safeNextPath("/desktop/")).toBe("/desktop/");
    expect(safeNextPath("/settings")).toBe("/settings");
  });

  it("rejects open redirects", () => {
    expect(safeNextPath("//evil.example")).toBeNull();
    expect(safeNextPath("https://evil.example")).toBeNull();
    expect(safeNextPath("")).toBeNull();
  });
});
