-- Window + layer rules. Mirror of conf.d/regular/rules.conf and
-- custom.d/regular/rules.conf, plus the deprecated `dwindle.pseudotile`
-- replaced by per-window `pseudo` rule.

-- Suppress maximize events from all clients (HLDE default behavior).
hl.window_rule({
  name           = "suppress-maximize",
  match          = { class = ".*" },
  suppress_event = "maximize",
})

-- Suppress fullscreen requests from clients (apps can't auto-fullscreen).
-- Manual SUPER+F / SUPER+CTRL+F still work.
hl.window_rule({
  name           = "suppress-fullscreen",
  match          = { class = ".*" },
  suppress_event = "fullscreen",
})

-- XWayland drag fix.
hl.window_rule({
  name  = "fix-xwayland-drags",
  match = {
    class      = "^$",
    title      = "^$",
    xwayland   = true,
    float      = true,
    fullscreen = false,
    pin        = false,
  },
  no_focus = true,
})

-- Layer rules: blur the bar, walker, notif areas.
hl.layer_rule({ name = "walker-blur",         match = { namespace = "walker"                 }, blur          = true })
hl.layer_rule({ name = "walker-alpha",        match = { namespace = "walker"                 }, ignore_alpha  = 0.41 })
hl.layer_rule({ name = "bar-blur",            match = { namespace = "hyprland-shell:bar"     }, blur          = true })
hl.layer_rule({ name = "bar-blur-popups",     match = { namespace = "hyprland-shell:bar"     }, blur_popups   = true })
hl.layer_rule({ name = "bar-alpha",           match = { namespace = "hyprland-shell:bar"     }, ignore_alpha  = 0.41 })
hl.layer_rule({ name = "notifs-blur",         match = { namespace = "hyprland-shell:notifs"  }, blur          = true })
hl.layer_rule({ name = "notifs-alpha",        match = { namespace = "hyprland-shell:notifs"  }, ignore_alpha  = 0.41 })
hl.layer_rule({ name = "notifs-no-anim",      match = { namespace = "hyprland-shell:notifs"  }, no_anim       = true })

-- Transparency window rules. Skipped if HLDE_NO_TRANSPARENT set.
if os.getenv("HLDE_NO_TRANSPARENT") == nil then
  hl.window_rule({ name = "opacity-non-fs",       match = { fullscreen = false                  }, opacity = 0.95 })
  hl.window_rule({ name = "opacity-dolphin",      match = { class = "org\\.kde\\.dolphin"       }, opacity = 0.95 })
  hl.window_rule({ name = "opacity-kitty-solid",  match = { class = "kitty"                     }, opacity = 1    })
end

-- XDG portal share-picker float.
hl.window_rule({
  name  = "share-picker-float",
  match = { class = "hyprland-share-picker" },
  float = true,
})

-- Pseudotile (replacement for the removed dwindle.pseudotile=true global).
-- Apply to all dwindle-tiled windows by default. Toggle via SUPER+P bind.
-- (No global option exists anymore; pseudo is per-window via dispatcher.)

-- WoW / Battle.net pinned to workspace 10.
hl.window_rule({ name = "wow-bnet",         match = { class = "^(steam_app_default)$", title = "^(Battle\\.net)$"        }, workspace = "10 silent" })
hl.window_rule({ name = "wow-blank",        match = { class = "^(steam_app_default)$", title = "^$"                       }, workspace = "10 silent" })
hl.window_rule({ name = "wow-game",         match = { class = "^(steam_app_default)$", title = "^(World of Warcraft)$"   }, workspace = "10 silent" })
-- WoW fullscreen-on-launch — `fullscreen=N` mode-int field doesn't exist in
-- 0.55+ Lua window_rule schema. Use a one-shot dispatch on window.open instead.
hl.on("window.open", function(w)
  if w and w.class == "steam_app_default" and w.title == "World of Warcraft" then
    hl.dispatch(hl.dsp.window.fullscreen({ mode = "maximized" }))
  end
end)

-- Scratchpad / always-floating windows.
hl.window_rule({ name = "float-dropterm",   match = { class = "^(kitty-dropterm)$"      }, float = true })
hl.window_rule({ name = "float-spotify",    match = { class = "^(spotify)$"             }, float = true })
hl.window_rule({ name = "float-tron",       match = { class = "^(Armagetron Advanced)$" }, float = true })
hl.window_rule({ name = "float-kitty-anime",match = { class = "^(kitty-anime)$"         }, float = true })
hl.window_rule({ name = "float-ani-tui",    match = { class = "^(ani-tui)$"             }, float = true })
hl.window_rule({ name = "size-ani-tui",     match = { class = "^(ani-tui)$"             }, size  = "1400 850" })
