-- ~/.config/awesome/modules/bindings.lua

local awful = require("awful")
local gears = require("gears")
local hotkeys_popup = require("awful.hotkeys_popup")
local variables = require("modules.variables")
local menubar = require("menubar")

local bindings = {}

-- Function to move focus and mouse pointer across screens
local function focus_window_and_move_mouse(direction)
    local focused = client.focus
    if not focused then
        return
    end

    -- Attempt to focus in the given direction
    awful.client.focus.bydirection(direction)

    -- If the focus hasn't changed, switch to the appropriate monitor
    if client.focus == focused then
        -- Determine the next screen to focus on
        awful.screen.focus_bydirection(direction)

        -- After switching to a new screen, try focusing on the first client in the new screen
        local screen = awful.screen.focused()
        if screen then
            local new_focused = awful.client.focus.history.get(screen, 0)
            if new_focused then
                client.focus = new_focused
                new_focused:raise()
            end
        end
    end

    -- Move the mouse to the center of the focused client
   if client.focus then
    	client.focus:raise()
    	local geometry = client.focus:geometry()
    	local x = geometry.x + geometry.width / 2
    	local y = geometry.y + geometry.height / 2
	mouse.coords({x = x, y = y})
   end
end

-- Global keybindings
bindings.globalkeys =
    gears.table.join(
    -- Awesome WM specific keybindings
    awful.key({variables.modkey}, "s", hotkeys_popup.show_help, {description = "show help", group = "awesome"}),
    awful.key({variables.modkey}, "Escape", awful.tag.history.restore, {description = "go back", group = "tag"}),
    -- Focus navigation
    awful.key(
        {variables.modkey},
        "j",
        function()
            awful.client.focus.byidx(1)
        end,
        {description = "focus next by index", group = "client"}
    ),
    awful.key(
        {variables.modkey},
        "k",
        function()
            awful.client.focus.byidx(-1)
        end,
        {description = "focus previous by index", group = "client"}
    ),
    awful.key(
        {variables.modkey},
        "w",
        function()
            menu:show()
        end,
        {description = "show main menu", group = "awesome"}
    ),
    -- Layout manipulation
    awful.key(
        {variables.modkey, "Shift"},
        "j",
        function()
            awful.client.swap.byidx(1)
        end,
        {description = "swap with next client by index", group = "client"}
    ),
    awful.key(
        {variables.modkey, "Shift"},
        "k",
        function()
            awful.client.swap.byidx(-1)
        end,
        {description = "swap with previous client by index", group = "client"}
    ),
    awful.key(
        {variables.modkey, "Control"},
        "j",
        function()
            awful.screen.focus_relative(1)
        end,
        {description = "focus the next screen", group = "screen"}
    ),
    awful.key(
        {variables.modkey, "Control"},
        "k",
        function()
            awful.screen.focus_relative(-1)
        end,
        {description = "focus the previous screen", group = "screen"}
    ),
    awful.key(
        {variables.modkey},
        "u",
        awful.client.urgent.jumpto,
        {description = "jump to urgent client", group = "client"}
    ),
    awful.key(
        {variables.modkey},
        "Tab",
        function()
            awful.client.focus.history.previous()
            if client.focus then
                client.focus:raise()
            end
        end,
        {description = "go back", group = "client"}
    ),
    -- Navigate between tiles using SUPER + Arrow keys and move mouse
    awful.key(
        {variables.modkey},
        "Left",
        function()
            focus_window_and_move_mouse("left")
        end,
        {description = "focus left window", group = "client"}
    ),
    awful.key(
        {variables.modkey},
        "Right",
        function()
            focus_window_and_move_mouse("right")
        end,
        {description = "focus right window", group = "client"}
    ),
    awful.key(
        {variables.modkey},
        "Up",
        function()
            focus_window_and_move_mouse("up")
        end,
        {description = "focus upper window", group = "client"}
    ),
    awful.key(
        {variables.modkey},
        "Down",
        function()
            focus_window_and_move_mouse("down")
        end,
        {description = "focus lower window", group = "client"}
    ),
    -- Standard program
    awful.key(
        {variables.modkey},
        "Return",
        function()
            awful.spawn(variables.terminal)
        end,
        {description = "open a terminal", group = "launcher"}
    ),
    awful.key({variables.modkey, "Control"}, "r", awesome.restart, {description = "reload awesome", group = "awesome"}),
    awful.key({variables.modkey, "Shift"}, "q", awesome.quit, {description = "quit awesome", group = "awesome"}),
    -- Layout adjustment
    awful.key(
        {variables.modkey},
        "l",
        function()
            awful.tag.incmwfact(0.05)
        end,
        {description = "increase master width factor", group = "layout"}
    ),
    awful.key(
        {variables.modkey},
        "h",
        function()
            awful.tag.incmwfact(-0.05)
        end,
        {description = "decrease master width factor", group = "layout"}
    ),
    awful.key(
        {variables.modkey, "Shift"},
        "h",
        function()
            awful.tag.incnmaster(1, nil, true)
        end,
        {description = "increase the number of master clients", group = "layout"}
    ),
    awful.key(
        {variables.modkey, "Shift"},
        "l",
        function()
            awful.tag.incnmaster(-1, nil, true)
        end,
        {description = "decrease the number of master clients", group = "layout"}
    ),
    awful.key(
        {variables.modkey, "Control"},
        "h",
        function()
            awful.tag.incncol(1, nil, true)
        end,
        {description = "increase the number of columns", group = "layout"}
    ),
    awful.key(
        {variables.modkey, "Control"},
        "l",
        function()
            awful.tag.incncol(-1, nil, true)
        end,
        {description = "decrease the number of columns", group = "layout"}
    ),
    awful.key(
        {variables.modkey},
        "space",
        function()
            awful.layout.inc(1)
        end,
        {description = "select next", group = "layout"}
    ),
    awful.key(
        {variables.modkey, "Shift"},
        "space",
        function()
            awful.layout.inc(-1)
        end,
        {description = "select previous", group = "layout"}
    ),
    -- Restore minimized
    awful.key(
        {variables.modkey, "Control"},
        "n",
        function()
            local c = awful.client.restore()
            if c then
                c:emit_signal("request::activate", "key.unminimize", {raise = true})
            end
        end,
        {description = "restore minimized", group = "client"}
    ),
    -- Lua prompt
    awful.key(
        {variables.modkey},
        "x",
        function()
            awful.prompt.run {
                prompt = "Run Lua code: ",
                textbox = awful.screen.focused().mypromptbox.widget,
                exe_callback = awful.util.eval,
                history_path = awful.util.get_cache_dir() .. "/history_eval"
            }
        end,
        {description = "lua execute prompt", group = "awesome"}
    ),
    -- Menubar
    awful.key(
        {variables.modkey},
        "p",
        function()
            menubar.show()
        end,
        {description = "show the menubar", group = "launcher"}
    ),
    -- Additional key bindings ported from Hyprland
    awful.key(
        {variables.modkey},
        "q",
        function()
            awful.spawn("alacritty")
        end,
        {description = "launch alacritty", group = "launcher"}
    ),
    awful.key(
        {variables.modkey},
        "c",
        function()
            if client.focus then
                client.focus:kill()
            end
        end,
        {description = "close focused client", group = "client"}
    ),
    awful.key(
        {variables.modkey},
        "m",
        function()
            awesome.quit()
        end,
        {description = "quit awesome", group = "awesome"}
    ),
    awful.key(
        {variables.modkey},
        "e",
        function()
            awful.spawn("dolphin")
        end,
        {description = "launch dolphin", group = "launcher"}
    ),
    awful.key(
	{variables.modkey},
	"f",
	function(c)
        	c.floating = not c.floating
        	c:raise()
	end,
	{description = "toggle floating", group = "client"}
    ),
    awful.key(
        {variables.modkey},
        "r",
        function()
            awful.spawn("rofi -show drun")
        end,
        {description = "run rofi", group = "launcher"}
    ),
    awful.key(
        {variables.modkey, "Shift"},
        "d",
        function()
            awful.spawn("/home/jsabella/.local/bin/devenv_select")
        end,
        {description = "run custom dev menu script", group = "launcher"}
    ), 
    awful.key(
        {"Mod1"},
        "Tab",
        function()
            awful.spawn("rofi -show window")
        end,
        {description = "run rofi window switcher", group = "launcher"}
    ),
    -- Monitor focus
    awful.key(
        {variables.modkey, "Shift"},
        "Left",
        function()
            awful.screen.focus_bydirection("left")
        end,
        {description = "focus left monitor", group = "screen"}
    ),
    awful.key(
        {variables.modkey, "Shift"},
        "Right",
        function()
            awful.screen.focus_bydirection("right")
        end,
        {description = "focus right monitor", group = "screen"}
    ),
    -- Screenshot
    awful.key(
        {},
        "Print",
        function()
            awful.spawn('grim -g "$(slurp)"')
        end,
        {description = "take a screenshot", group = "launcher"}
    ),
    -- Brightness control
    awful.key(
        {},
        "XF86MonBrightnessUp",
        function()
            awful.spawn.with_shell("$HOME/.local/bin/adjust_brightness up")
        end,
        {description = "increase brightness", group = "launcher"}
    ),
    awful.key(
        {},
        "XF86MonBrightnessDown",
        function()
            awful.spawn.with_shell("$HOME/.local/bin/adjust_brightness down")
        end,
        {description = "decrease brightness", group = "launcher"}
    ),
    -- Audio control
    awful.key(
        {},
        "XF86AudioRaiseVolume",
        function()
            awful.spawn("pamixer --increase 5 --allow-boost false")
        end,
        {description = "raise volume", group = "launcher"}
    ),
    awful.key(
        {},
        "XF86AudioLowerVolume",
        function()
            awful.spawn("pamixer --decrease 5")
        end,
        {description = "lower volume", group = "launcher"}
    ),
    awful.key(
        {},
        "XF86AudioMute",
        function()
            awful.spawn("pamixer --toggle-mute")
        end,
        {description = "mute/unmute audio", group = "launcher"}
    ),
    awful.key(
        {},
        "XF86AudioPlay",
        function()
            awful.spawn("playerctl play-pause")
        end,
        {description = "play/pause audio", group = "launcher"}
    )
)

-- Client keybindings
bindings.clientkeys =
    gears.table.join(
    awful.key(
        {variables.modkey},
        "f",
        function(c)
            c.fullscreen = not c.fullscreen
            c:raise()
        end,
        {description = "toggle fullscreen", group = "client"}
    ),
    awful.key(
        {variables.modkey, "Shift"},
        "c",
        function(c)
            c:kill()
        end,
        {description = "close", group = "client"}
    ),
    awful.key(
        {variables.modkey, "Control"},
        "space",
        awful.client.floating.toggle,
        {description = "toggle floating", group = "client"}
    ),
    awful.key(
        {variables.modkey, "Control"},
        "Return",
        function(c)
            c:swap(awful.client.getmaster())
        end,
        {description = "move to master", group = "client"}
    ),
    awful.key(
        {variables.modkey},
        "o",
        function(c)
            c:move_to_screen()
        end,
        {description = "move to screen", group = "client"}
    ),
    awful.key(
        {variables.modkey},
        "t",
        function(c)
            c.ontop = not c.ontop
        end,
        {description = "toggle keep on top", group = "client"}
    ),
    awful.key(
        {variables.modkey},
        "n",
        function(c)
            c.minimized = true
        end,
        {description = "minimize", group = "client"}
    ),
    awful.key(
        {variables.modkey},
        "m",
        function(c)
            c.maximized = not c.maximized
            c:raise()
        end,
        {description = "(un)maximize", group = "client"}
    ),
    awful.key(
        {variables.modkey, "Control"},
        "m",
        function(c)
            c.maximized_vertical = not c.maximized_vertical
            c:raise()
        end,
        {description = "(un)maximize vertically", group = "client"}
    ),
    awful.key(
        {variables.modkey, "Shift"},
        "m",
        function(c)
            c.maximized_horizontal = not c.maximized_horizontal
            c:raise()
        end,
        {description = "(un)maximize horizontally", group = "client"}
    )
)


-- Function to move the focused window to another screen
local function move_window_to_screen_and_focus(direction)
    local focused = client.focus
    if not focused then
        return
    end

    -- Move the focused client to the screen in the specified direction
    awful.client.movetoscreen(focused, awful.screen.focus_bydirection(direction))

    -- Focus the screen in the given direction
    awful.screen.focus_bydirection(direction)

    -- Ensure the client is focused after moving
    client.focus = focused
    focused:raise()

    -- Move the mouse to the center of the focused client
    local geometry = focused:geometry()
    local x = geometry.x + geometry.width / 2
    local y = geometry.y + geometry.height / 2
    mouse.coords({x = x, y = y})
end

-- Keybindings to move the focused window and mouse to another screen
bindings.globalkeys = gears.table.join(
    bindings.globalkeys,
    awful.key(
        {variables.modkey, "Shift", "Control"},
        "Left",
        function()
            move_window_to_screen_and_focus("left")
        end,
        {description = "move window and focus to the left screen", group = "client"}
    ),
    awful.key(
        {variables.modkey, "Shift", "Control"},
        "Right",
        function()
            move_window_to_screen_and_focus("right")
        end,
        {description = "move window and focus to the right screen", group = "client"}
    ),
    awful.key(
        {variables.modkey, "Shift", "Control"},
        "Up",
        function()
            move_window_to_screen_and_focus("up")
        end,
        {description = "move window and focus to the upper screen", group = "client"}
    ),
    awful.key(
        {variables.modkey, "Shift", "Control"},
        "Down",
        function()
            move_window_to_screen_and_focus("down")
        end,
        {description = "move window and focus to the lower screen", group = "client"}
    ),
    awful.key(
    	{variables.modkey, "Shift"},
    	"v",
    	function()
        	awful.spawn("alacritty -e pulsemixer")
    	end,
    	{description = "open pulsemixer in alacritty", group = "launcher"}
    )
)

-- Workspace navigation
for i = 1, 9 do
    -- Determine the correct screen based on odd/even tag
    local screen_idx = (i % 2 == 0) and 2 or 1
    
    -- View tag only.
    bindings.globalkeys = gears.table.join(bindings.globalkeys,
        awful.key(
            { variables.modkey },
            "#" .. i + 9,
            function ()
                local screen = screen[screen_idx]
                local tag = screen.tags[math.ceil(i / 2)]
                if tag then
                    tag:view_only()
                end
            end,
            {description = "view tag " .. i, group = "tag"}
        )
    )
    
    -- Move client to tag.
    bindings.globalkeys = gears.table.join(bindings.globalkeys,
        awful.key(
            { variables.modkey, "Shift" },
            "#" .. i + 9,
            function ()
                if client.focus then
                    local tag = client.focus.screen.tags[math.ceil(i / 2)]
                    if tag then
                        client.focus:move_to_tag(tag)
                    end
                end
            end,
            {description = "move focused client to tag " .. i, group = "tag"}
        )
    )
end

return bindings

