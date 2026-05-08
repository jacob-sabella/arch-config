-- Environment variables exported to apps Hyprland spawns.

hl.env("XCURSOR_SIZE",      "24")
hl.env("HYPRCURSOR_SIZE",   "24")
hl.env("XCURSOR_THEME",     "XCursor-Pro-Dark")
hl.env("HYPRCURSOR_THEME",  "XCursor-Pro-Dark-Hyprcursor")

-- HLDE flags previously set in custom.d/regular/env.conf.
-- These were consumed by HLDE's hyprlang `if !HLDE_*` blocks. Keeping the env
-- vars exported means external scripts/HLDE-aware tools still see them; the
-- conditional behavior is now expressed inline in this Lua config.
hl.env("HLDE_HYPRIDLE_CUSTOM", "1")
hl.env("HLDE_NO_HYPRPAPER",    "1")
