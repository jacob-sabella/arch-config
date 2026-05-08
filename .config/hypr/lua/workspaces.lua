-- Workspace pinning + per-workspace rules.

-- HLDE default: workspace f[1] (first floating-only) gets no gaps/border/round.
if os.getenv("HLDE_NO_MAXIMIZED") == nil then
  -- `rounding` not a valid workspace_rule field in 0.55+; gaps + border only.
  hl.workspace_rule({ workspace = "f[1]", gaps_out = 0, border_size = 0 })
end

-- Workspace 9 = AOC portrait monitor (jubeat). Persistent + default for that monitor.
hl.workspace_rule({
  workspace  = "9",
  monitor    = "desc:AOC 2770G4 GCHG3HA010127",
  persistent = true,
  default    = true,
})

-- All other regular workspaces hard-pinned to the Samsung Odyssey ultrawide.
local SAMSUNG = "desc:Samsung Electric Company Odyssey G95NC HNTX300255"
hl.workspace_rule({ workspace = "1",  monitor = SAMSUNG, default = true })
hl.workspace_rule({ workspace = "2",  monitor = SAMSUNG })
hl.workspace_rule({ workspace = "3",  monitor = SAMSUNG })
hl.workspace_rule({ workspace = "4",  monitor = SAMSUNG })
hl.workspace_rule({ workspace = "5",  monitor = SAMSUNG })
hl.workspace_rule({ workspace = "6",  monitor = SAMSUNG })
hl.workspace_rule({ workspace = "7",  monitor = SAMSUNG })
hl.workspace_rule({ workspace = "8",  monitor = SAMSUNG })
hl.workspace_rule({ workspace = "10", monitor = SAMSUNG })
