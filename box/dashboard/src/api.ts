export type BoxStatus = {
  product: string;
  version: string;
  arch: string;
  setup_complete: boolean;
  setup_open: boolean;
  claim_required: boolean;
  authenticated?: boolean;
  auth_required?: boolean;
  hostnames: string[];
  skin: string;
};

export type OperatorStatus = {
  remote_admin_enabled: boolean;
  maker_user: string;
  notes: string[];
  factory_reset_via_api: boolean;
  claim_pin_via_api: boolean;
};

async function readError(res: Response): Promise<string> {
  let detail = `${res.status}`;
  try {
    const data = (await res.json()) as { detail?: unknown };
    if (typeof data.detail === "string") detail = data.detail;
  } catch {
    /* ignore */
  }
  return detail;
}

export async function fetchStatus(): Promise<BoxStatus> {
  const res = await fetch("/api/status", { credentials: "include" });
  if (!res.ok) throw new Error(`status ${res.status}`);
  return res.json() as Promise<BoxStatus>;
}

export async function postSetup(body: {
  claim_code: string;
  admin_password: string;
  network_mode: string;
}): Promise<{ ok: boolean; message: string }> {
  const res = await fetch("/api/setup", {
    method: "POST",
    credentials: "include",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(body),
  });
  if (!res.ok) throw new Error(await readError(res));
  return res.json() as Promise<{ ok: boolean; message: string }>;
}

export async function postLogin(password: string): Promise<{ ok: boolean; message: string }> {
  const res = await fetch("/api/login", {
    method: "POST",
    credentials: "include",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ password }),
  });
  if (!res.ok) throw new Error(await readError(res));
  return res.json() as Promise<{ ok: boolean; message: string }>;
}

export async function postLogout(): Promise<void> {
  await fetch("/api/logout", { method: "POST", credentials: "include" });
}

export async function fetchOperatorStatus(): Promise<OperatorStatus> {
  const res = await fetch("/api/operator-status", { credentials: "include" });
  if (!res.ok) throw new Error(await readError(res));
  return res.json() as Promise<OperatorStatus>;
}
