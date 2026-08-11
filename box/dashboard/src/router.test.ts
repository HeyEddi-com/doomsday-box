import { beforeEach, describe, expect, it, vi } from "vitest";
import type { BoxStatus } from "./api";

const fetchStatus = vi.fn<[], Promise<BoxStatus>>();

vi.mock("./api", () => ({
  fetchStatus: () => fetchStatus(),
}));

import { router } from "./router";

function baseStatus(overrides: Partial<BoxStatus> = {}): BoxStatus {
  return {
    product: "HeyEddi Doomsday Box",
    version: "0.2.0",
    arch: "amd64",
    setup_complete: false,
    setup_open: true,
    claim_required: true,
    authenticated: false,
    auth_required: false,
    hostnames: ["box.local"],
    skin: "hub",
    ...overrides,
  };
}

describe("router guards", () => {
  beforeEach(async () => {
    fetchStatus.mockReset();
    await router.replace("/login");
    await router.isReady();
  });

  it("redirects home to setup when unclaimed", async () => {
    fetchStatus.mockResolvedValue(baseStatus());
    await router.push("/");
    await router.isReady();
    expect(router.currentRoute.value.name).toBe("setup");
  });

  it("redirects protected routes to login when claimed but unauthenticated", async () => {
    fetchStatus.mockResolvedValue(
      baseStatus({
        setup_complete: true,
        setup_open: false,
        auth_required: true,
        authenticated: false,
      }),
    );
    await router.push("/settings");
    await router.isReady();
    expect(router.currentRoute.value.name).toBe("login");
  });

  it("allows setup route while unclaimed", async () => {
    fetchStatus.mockResolvedValue(baseStatus());
    await router.push("/setup");
    await router.isReady();
    expect(router.currentRoute.value.name).toBe("setup");
  });

  it("allows home when claimed and authenticated", async () => {
    fetchStatus.mockResolvedValue(
      baseStatus({
        setup_complete: true,
        setup_open: false,
        auth_required: true,
        authenticated: true,
      }),
    );
    await router.push("/");
    await router.isReady();
    expect(router.currentRoute.value.name).toBe("home");
  });
});
