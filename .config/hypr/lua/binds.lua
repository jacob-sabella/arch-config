-- Keybindings. Combined HLDE defaults + custom overrides from
-- conf.d/regular/binds.conf and custom.d/regular/binds.conf.
-- Custom-overridden bindings only appear in their final form here
-- (no unbind/rebind dance like the old hyprlang config required).

local mod   = "SUPER"
local modS  = "SUPER + SHIFT"
local modC  = "SUPER + CTRL"
local modA  = "SUPER + ALT"
local modCS = "SUPER + CTRL + SHIFT"

local terminal   = "ghostty"   -- custom override of HLDE default `kitty`
local lockscreen = "hyprlock"
local screenshot = "grimblast --freeze --notify copysave area"

-- Plugin dispatchers (hyprexpo, etc.). hl.dsp.global returns a Dispatcher
-- but stored-and-invoked-on-keypress behavior was unreliable for plugin
-- dispatchers — wrap in a function so each press calls hl.dispatch fresh.
local function plugin_dsp(name, ...)
  local args = {...}
  return function()
    hl.dispatch(hl.dsp.global(name, table.unpack(args)))
  end
end

-----------------------------------------------------------------------
-- Core window/session controls
-----------------------------------------------------------------------
hl.bind(mod  .. " + Q",     hl.dsp.exec_cmd(terminal))
hl.bind(mod  .. " + C",     hl.dsp.window.close())
hl.bind(mod  .. " + M",     hl.dsp.exit())
hl.bind(mod  .. " + E",     hl.dsp.exec_cmd("dolphin"))
hl.bind(mod  .. " + R",     hl.dsp.exec_cmd("hyprlauncher"))
hl.bind(mod  .. " + P",     hl.dsp.window.pin())                                -- custom: pin (override HLDE pseudo)
hl.bind(mod  .. " + J",     hl.dsp.layout("togglesplit"))
hl.bind(mod  .. " + L",     hl.dsp.exec_cmd(lockscreen))
hl.bind(mod  .. " + F",     hl.dsp.window.fullscreen())
hl.bind(modS .. " + F",     hl.dsp.window.float({ action = "toggle" }))         -- custom: was fullscreen 1
hl.bind(modC .. " + F",     hl.dsp.window.fullscreen({ mode = "maximized" }))   -- custom: maximize
hl.bind("Print",            hl.dsp.exec_cmd(screenshot))

-- Custom-only floating control extras (custom.d/regular/binds.conf).
hl.bind(mod  .. " + V",     hl.dsp.exec_cmd("alacritty -e pulsemixer"))         -- custom: pulsemixer (was togglefloating)

-----------------------------------------------------------------------
-- Focus movement (left/right routed through sidepanels for slot-aware
-- traversal: left-slot → middle → right-slot; up/down use default).
-----------------------------------------------------------------------
hl.bind(mod .. " + left",   function() sidepanels.focus_dir("left")  end)
hl.bind(mod .. " + right",  function() sidepanels.focus_dir("right") end)
hl.bind(mod .. " + up",     hl.dsp.focus({ direction = "up"    }))
hl.bind(mod .. " + down",   hl.dsp.focus({ direction = "down"  }))

-----------------------------------------------------------------------
-- Workspaces 1-10
-----------------------------------------------------------------------
for i = 1, 10 do
  local key = (i % 10)   -- 10 maps to 0
  hl.bind(mod  .. " + " .. key, hl.dsp.focus({ workspace = i }))
  hl.bind(modS .. " + " .. key, hl.dsp.window.move({ workspace = i, silent = true }))
end

-- Special workspace "first" (HLDE default).
hl.bind(mod  .. " + S", hl.dsp.workspace.toggle_special("first"))
-- Custom override: SUPER+SHIFT+S → toggle pyprland spotify scratchpad
-- (HLDE default was movetoworkspacesilent special:first; user replaced.)
hl.bind(modS .. " + S", hl.dsp.exec_cmd("pypr toggle spotify"))

-- Scroll between workspaces.
hl.bind(mod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mod .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }))

-- Mouse drag move/resize.
hl.bind(mod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })
-- On SUPER+LMB release: snap floating window into nearest slot if it ended
-- in a gutter zone. (Drag continues until release; this fires after.)
hl.bind(mod .. " + mouse:272", function() sidepanels.snap_active() end, { mouse = true, release = true })

-----------------------------------------------------------------------
-- Audio + brightness (custom: pamixer instead of wpctl, qs msg brightness)
-----------------------------------------------------------------------
hl.bind("XF86AudioRaiseVolume",   hl.dsp.exec_cmd("pamixer --increase 5 --allow-boost false"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume",   hl.dsp.exec_cmd("pamixer --decrease 5"),                     { locked = true, repeating = true })
hl.bind("XF86AudioMute",          hl.dsp.exec_cmd("pamixer --toggle-mute"),                    { locked = true })
hl.bind("XF86AudioMicMute",       hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"), { locked = true })
hl.bind("XF86AudioPlay",          hl.dsp.exec_cmd("playerctl play-pause"),                     { locked = true })
hl.bind("XF86AudioNext",          hl.dsp.exec_cmd("playerctl next"),                           { locked = true })
hl.bind("XF86AudioPause",         hl.dsp.exec_cmd("playerctl play-pause"),                     { locked = true })
hl.bind("XF86AudioPrev",          hl.dsp.exec_cmd("playerctl previous"),                       { locked = true })

-- Brightness — custom script overrides qs msg.
hl.bind("XF86MonBrightnessUp",    hl.dsp.exec_cmd(os.getenv("HOME") .. "/.local/bin/adjust_brightness up"))
hl.bind("XF86MonBrightnessDown",  hl.dsp.exec_cmd(os.getenv("HOME") .. "/.local/bin/adjust_brightness down"))

-----------------------------------------------------------------------
-- Custom binds (custom.d/regular/binds.conf)
-----------------------------------------------------------------------

-- ani-tui (anime browser via fzf + ani-cli + AniList).
hl.bind(mod  .. " + A", hl.dsp.exec_cmd("ghostty --class=ani-tui --title=ani-tui --font-size=12 -e " .. os.getenv("HOME") .. "/.local/bin/ani-tui"))
hl.bind(modS .. " + A", hl.dsp.exec_cmd("qs -p " .. os.getenv("HOME") .. "/.config/quickshell/anitui/shell.qml ipc call anitui toggle"))

-- Edit config (kept; was opening hyprland.conf, now opens this lua dir).
hl.bind(modS .. " + H", hl.dsp.exec_cmd("alacritty -e nano " .. os.getenv("HOME") .. "/.config/hypr-lua-staging/hyprland.lua"))

-- Phone (scrcpy).
hl.bind(modS .. " + P", hl.dsp.exec_cmd(os.getenv("HOME") .. "/.local/bin/start_scrcpy"))

-- Dev env menu.
hl.bind(modS .. " + D", hl.dsp.exec_cmd(os.getenv("HOME") .. "/.local/bin/devenv_select"))

-- Chrome.
hl.bind(modS .. " + B", hl.dsp.exec_cmd("google-chrome-stable"))

-- Screenshots (hyprshot variants).
hl.bind(mod  .. " + Print",          hl.dsp.exec_cmd("hyprshot -m window --clipboard-only"))
hl.bind("Print",                     hl.dsp.exec_cmd("hyprshot -m output --clipboard-only")) -- override default
hl.bind(modS .. " + Print",          hl.dsp.exec_cmd("hyprshot -m region --clipboard-only"))
hl.bind(modCS .. " + Print",         hl.dsp.exec_cmd("hyprshot -m output -o " .. os.getenv("HOME") .. "/Pictures"))
hl.bind(modA .. " + Print",          hl.dsp.exec_cmd("hyprshot -m region -o " .. os.getenv("HOME") .. "/Pictures"))
hl.bind(modC .. " + Print",          hl.dsp.exec_cmd(os.getenv("HOME") .. "/.local/bin/hypr-record-select"))

-- Wallpaper controls.
hl.bind(modS  .. " + W", hl.dsp.exec_cmd("qs msg wallpaper toggle"))
hl.bind(modC  .. " + W", hl.dsp.exec_cmd(os.getenv("HOME") .. "/.local/bin/generate-wallpaper"))
hl.bind(modCS .. " + W", hl.dsp.exec_cmd(os.getenv("HOME") .. "/.local/bin/generate-anime-wallpaper"))

-- Screen shader / filter.
hl.bind(modA  .. " + S", hl.dsp.exec_cmd(os.getenv("HOME") .. "/.local/bin/hyprshade-rofi"))

-- Suppress / enable Hyprland error overlay.
hl.bind(modS .. " + E",  hl.dsp.exec_cmd(os.getenv("HOME") .. "/.local/bin/hypr-suppress-errors"))
hl.bind(modC .. " + E",  hl.dsp.exec_cmd(os.getenv("HOME") .. "/.local/bin/hypr-enable-errors"))

-- Pyprland scratchpads.
hl.bind(modS .. " + backslash", hl.dsp.exec_cmd("pypr toggle term"))
hl.bind(modS .. " + T",         hl.dsp.exec_cmd("pypr toggle tron"))

-- Pyprland zoom.
hl.bind(mod  .. " + Z",     hl.dsp.exec_cmd("pypr zoom"))
hl.bind(mod  .. " + equal", hl.dsp.exec_cmd("pypr zoom ++"))
hl.bind(mod  .. " + minus", hl.dsp.exec_cmd("pypr zoom --"))

-- Hyprexpo overview (plugin dispatcher via hl.dsp.global). Diagnostic logging
-- left in until expo confirmed working.
hl.bind(mod .. " + TAB", hl.dsp.global("hyprexpo:expo", "toggle"))

-- Rofi launchers.
hl.bind(mod  .. " + SPACE", hl.dsp.exec_cmd("rofi -show drun -dpi 1"))
hl.bind(mod  .. " + SLASH", hl.dsp.exec_cmd("rofi -show drun -dpi 1"))
hl.bind("ALT + TAB",         hl.dsp.exec_cmd("rofi -show window"))

-----------------------------------------------------------------------
-- Side panels: assign focused window to a slot (custom Lua module).
-----------------------------------------------------------------------
hl.bind(modA .. " + left",  function()
  local f = io.open("/tmp/sidepanels.log","a")
  if f then f:write("[bind] SUPER+ALT+left fired; sidepanels=" .. tostring(sidepanels) .. "\n"); f:close() end
  if sidepanels then sidepanels.assign("left") end
end)
hl.bind(modA .. " + right", function()
  local f = io.open("/tmp/sidepanels.log","a")
  if f then f:write("[bind] SUPER+ALT+right fired\n"); f:close() end
  if sidepanels then sidepanels.assign("right") end
end)
hl.bind(modA .. " + 0",     function() sidepanels.clear_all()     end)

-- Aspect ratio presets for the middle area, ordered narrowest → widest:
--   1 = 16:10  (1728 middle, 1056 gutter)
--   2 = 16:9   (1920 middle, 960 gutter)
--   3 = 21:9   (2520 middle, 660 gutter)
--   4 = panel  (3040 middle, 400 gutter — default sidebar mode)
--   5 = full   (3840 middle, no gutter, releases slots)
hl.bind(modA .. " + 1", function() sidepanels.set_aspect("16:10") end)
hl.bind(modA .. " + 2", function() sidepanels.set_aspect("16:9")  end)
hl.bind(modA .. " + 3", function() sidepanels.set_aspect("21:9")  end)
hl.bind(modA .. " + 4", function() sidepanels.set_aspect("panel") end)
hl.bind(modA .. " + 5", function() sidepanels.set_aspect("full")  end)
