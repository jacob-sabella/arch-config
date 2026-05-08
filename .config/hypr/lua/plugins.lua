-- Plugin-specific config. hyprexpo loaded via `hyprpm reload -n` in autostart.
-- Plugin keys aren't known to Hyprland until the plugin loads, so set them
-- AFTER hyprpm load via `hyprctl eval` (the Lua-era replacement for the now-
-- defunct `hyprctl keyword`).
--
-- KNOWN ISSUE on Hyprland master @ 2026-05-07: hyprexpo dispatcher accepts
-- `hyprexpo:expo toggle` but renders nothing. Plugin loads, config applies,
-- but the overlay never paints. Likely regression in plugin or plugin host
-- in this commit. SUPER+TAB will silently no-op until fixed upstream.

hl.on("hyprland.start", function()
  hl.exec_cmd([[
    bash -c '
      sleep 1
      hyprctl eval "hl.config({plugin = {hyprexpo = {columns = 3, gap_size = 20, bg_col = \"rgb(111111)\", workspace_method = \"center current\", skip_empty = true}}})"
    '
  ]])
end)
