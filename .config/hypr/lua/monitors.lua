-- Monitor layout.
-- Three known monitors:
--   1. Samsung Odyssey G95NC ultrawide (HDMI-A-2): primary, 7680x2160@120, scale 2
--   2. AOC 2770G4 (DP-4): jubeat dance pad monitor, portrait, transform=1
--   3. VIZIO D43f-E2: TV, 1920x1080@60

-- Default for any monitor not explicitly named.
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = "auto" })

-- Primary ultrawide. Reserve 400px each side for the side-panel slots
-- (sidepanels.lua). Effective usable middle = 3040px wide for tiled windows.
hl.monitor({
  output        = "HDMI-A-2",
  mode          = "7680x2160@120",
  position      = "0x0",
  scale         = 2,
  reserved_area = { top = 0, bottom = 0, left = 400, right = 400 },
})

-- AOC portrait (jubeat). Mounted with controller on lower half: transform=1
-- (90° CCW). Logical = 1080w x 1920h after rotation.
hl.monitor({
  output    = "desc:AOC 2770G4 GCHG3HA010127",
  mode      = "preferred",
  position  = "3840x0",
  scale     = 1,
  transform = 1,
})

-- VIZIO TV.
hl.monitor({
  output   = "desc:VIZIO Inc D43f-E2",
  mode     = "1920x1080@60",
  position = "auto",
  scale    = 1,
})
