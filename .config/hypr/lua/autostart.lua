-- Autostart commands. Run once when Hyprland starts.

local function spawn(cmd)
  hl.exec_cmd(cmd)
end

hl.on("hyprland.start", function()
  -- HLDE defaults (gated by env, just like the old hyprlang `if !HLDE_*`).
  if os.getenv("HLDE_NO_HYPRPAPER") == nil then spawn("hyprpaper") end
  if os.getenv("HLDE_NO_HYPRIDLE")  == nil then spawn("hypridle")  end

  -- Quickshell (HLDE shell + bar).
  spawn("env QS_NO_RELOAD_POPUP=1 QML_DISABLE_DISK_CACHE=1 quickshell")

  -- Clipboard history (cliphist).
  spawn("wl-paste --watch cliphist store")

  -- hyprlauncher daemon.
  spawn("hyprlauncher -d")

  -- Custom autostart from custom.d/regular/autostart.conf:
  spawn("hyprpm reload -n")                                                                  -- load plugins (hyprexpo)
  spawn("pypr")                                                                              -- pyprland scratchpads + zoom
  spawn("qs -p /home/jsabella/.config/quickshell/anitui/shell.qml -d")                       -- ani-tui prewarm
  spawn("gsr-ui launch-hide-announce")                                                       -- ShadowPlay-style replay tray
  spawn("qs -p /home/jsabella/.config/quickshell/gutters/shell.qml -d")                      -- side-gutter visual backdrop
end)
