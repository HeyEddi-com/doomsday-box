# Local AI engine: Nous Hermes 3 (`hermes3:8b`)

**Last updated:** 2026-08-13  
**Status:** Research / product target — **not shipped** on the appliance yet  
**Related:** `hardware-bom.md`, `gtm-positioning.md`, `box-architecture.md`

Replaces prior lean default note (`llama3.2:3b`) as the **flagship orchestrator** target for campaign and product narrative. Keep ARM64 DIY path compatible; embeddings (`all-minilm` or equivalent) remain useful for RAG when that stage lands.

## Model selection rationale

The Doomsday Box targets **Nous Hermes 3 (`hermes3:8b`)** as the primary local orchestrator: a full-parameter fine-tune of Meta Llama 3.1 weights aimed at **agentic workflows, reliable function calling, and neutral user alignment**.

**Hermes agents** (planned): natural-language → structured tool calls → Python hardware/system bridge → nftables / host services / RP2040 OLED & controls. Document as campaign target; do not claim live on golden image until implemented.

```
User input / dashboard command
        │
        ▼
Ollama API (hermes3:8b)     Q4_K_M ~4.9 GB · LPDDR5 bandwidth on IOTA
        │
        ▼
Native XML/JSON tool-call output
        │
        ▼
Python hardware bridge (/dev/ttyACM0 + host APIs)
        │                    │
        ▼                    ▼
Linux / nftables        RP2040 MCU · OLED & controls
```

## Capabilities (research targets)

| Metric / feature | Specification | Impact |
|------------------|---------------|--------|
| Base architecture | Llama 3.1 8B (Nous fine-tune) | x86_64 CPU/iGPU via llama.cpp / Ollama |
| Quantization | **Q4_K_M (~4.9 GB)** | Leaves >10 GB free for services on 16GB RAM |
| Context | 128k model; configure **16k–32k** locally | Long command / network logs |
| Function calling | Native XML/JSON structured output | Agentic system tasks |
| Alignment | Neutral / low-refusal posture | Network diagnostics, offline ops queries — market carefully; no illegal-use framing |

## Function-calling protocol (illustrative)

**User:** “Scan my network for untrusted devices, block IP 192.168.1.105, and update the front display.”

**Hermes structured payload (example):**

```json
{
  "tool_calls": [
    {
      "name": "network_scan",
      "parameters": { "target_range": "192.168.1.0/24" }
    },
    {
      "name": "firewall_block_ip",
      "parameters": { "ip": "192.168.1.105", "chain": "input" }
    },
    {
      "name": "update_oled_display",
      "parameters": { "line1": "BLOCKED: .105", "line2": "FIREWALL: ACTIVE" }
    }
  ]
}
```

**Backend (planned):** Python bridge validates and executes (e.g. nftables drop rule); status strings over `/dev/ttyACM0` to RP2040 for OLED. All tool execution must be **authenticated, allowlisted, and auditable** — never raw unconstrained shell from the model.

## Multi-model strategy (Ollama presets — planned)

| Role | Model | Footprint | Use |
|------|-------|-----------|-----|
| System orchestrator (default) | `hermes3:8b` | ~4.9 GB | Security management, agents, function calling |
| Code assistant | `qwen2.5-coder:7b` | ~4.7 GB | Local bash / Python / Compose scripts |
| Low-power / battery saver | `hermes3:3b` | ~2.2 GB | Snappier under UPS HAT power |

Pre-load of models on NVMe add-on: see `hardware-bom.md` BackerKit add-ons.

## Delivery honesty

| Claim | Status |
|-------|--------|
| Ollama + Hermes agents on golden flash | **Later** — not stage-1 |
| Browser remote desktop | **Shipped (software)** — separate from AI |
| OLED / RP2040 bridge | Tied to LattePanda IOTA hardware path |
| Uncensored marketing | Prefer “neutral alignment / local control” over “uncensored” on public landing if it invites abuse framing |
