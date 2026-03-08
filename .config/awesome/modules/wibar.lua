local awful = require("awful")
local wibox = require("wibox")
local gears = require("gears")
local beautiful = require("beautiful")
local menu = require("modules.menu")
local volume_widget = require('awesome-wm-widgets.volume-widget.volume')
local logout_menu_widget = require("awesome-wm-widgets.logout-menu-widget.logout-menu")
local wibar = {}

wibar.setup = function(s)
    -- Create a promptbox for each screen
    s.mypromptbox = awful.widget.prompt()

    -- Create an imagebox widget for layout indicator
    s.mylayoutbox = awful.widget.layoutbox(s)
    s.mylayoutbox:buttons(gears.table.join(
        awful.button({ }, 1, function () awful.layout.inc( 1) end),
        awful.button({ }, 3, function () awful.layout.inc(-1) end),
        awful.button({ }, 4, function () awful.layout.inc( 1) end),
        awful.button({ }, 5, function () awful.layout.inc(-1) end)
    ))

    -- Create a taglist widget
    s.mytaglist = awful.widget.taglist {
        screen  = s,
        filter  = awful.widget.taglist.filter.all,
        buttons = gears.table.join(
            awful.button({ }, 1, function(t) t:view_only() end),
            awful.button({ "Mod4" }, 1, function(t)
                if client.focus then
                    client.focus:move_to_tag(t)
                end
            end),
            awful.button({ }, 3, awful.tag.viewtoggle),
            awful.button({ "Mod4" }, 3, function(t)
                if client.focus then
                    client.focus:toggle_tag(t)
                end
            end),
            awful.button({ }, 4, function(t) awful.tag.viewnext(t.screen) end),
            awful.button({ }, 5, function(t) awful.tag.viewprev(t.screen) end)
        )
    }

    -- Create a tasklist widget
    s.mytasklist = awful.widget.tasklist {
        screen  = s,
        filter  = awful.widget.tasklist.filter.currenttags,
        buttons = gears.table.join(
            awful.button({ }, 1, function (c)
                if c == client.focus then
                    c.minimized = true
                else
                    c:emit_signal("request::activate", "tasklist", {raise = true})
                end
            end),
            awful.button({ }, 3, function()
                awful.menu.client_list({ theme = { width = 250 } })
            end),
            awful.button({ }, 4, function ()
                awful.client.focus.byidx(1)
            end),
            awful.button({ }, 5, function ()
                awful.client.focus.byidx(-1)
            end)
        )
    }

    -- Create a textclock widget
    local mytextclock = wibox.widget.textclock()

    -- Create a keyboard layout widget
    local mykeyboardlayout = awful.widget.keyboardlayout()

    -- Define icon size for scaling
    local icon_size = 16  -- Smaller icon size for better aesthetics

    -- Create media control widgets with scaling
    local media_prev = wibox.widget {
        widget = wibox.widget.textbox,
        font = "sans " .. icon_size,
        text = "⏮",
        buttons = gears.table.join(
            awful.button({}, 1, function() awful.spawn("playerctl previous") end)
        )
    }

    local media_play_pause = wibox.widget {
        widget = wibox.widget.textbox,
        font = "sans " .. icon_size,
        text = "⏯",
        buttons = gears.table.join(
            awful.button({}, 1, function() awful.spawn("playerctl play-pause") end)
        )
    }

    local media_next = wibox.widget {
        widget = wibox.widget.textbox,
        font = "sans " .. icon_size,
        text = "⏭",
        buttons = gears.table.join(
            awful.button({}, 1, function() awful.spawn("playerctl next") end)
        )
    }

    -- Create widget to display the current playing song
    local song_widget = awful.widget.watch('playerctl metadata --format "{{ title }} - {{ artist }}"', 5)

    -- Create the wibox with margin and subtle vaporwave background color
    s.mywibox = awful.wibar({
        position = "top",
        screen = s,
        bg = "#202040", -- Subtle dark purple background
        fg = "#8ae9c1", -- Soft cyan text color
        height = 30,    -- Increase the height for better spacing
    })

    -- Add widgets to the wibox
    s.mywibox:setup {
        {
            layout = wibox.layout.align.horizontal,
            { -- Left widgets
                layout = wibox.layout.fixed.horizontal,
                menu.mylauncher,
                s.mytaglist,
                s.mypromptbox,
            },
            s.mytasklist, -- Middle widget
            { -- Right widgets
                layout = wibox.layout.fixed.horizontal,
                media_prev,
                media_play_pause,
                media_next,
                song_widget,      -- Display current song
                volume_widget({widget_type = "arc"}),
		logout_menu_widget(),
                mykeyboardlayout,
                wibox.widget.systray(),
                mytextclock,
                s.mylayoutbox,
            },
        },
        left = 10,   -- Margin on the left side
        right = 10,  -- Margin on the right side
        top = 5,     -- Margin on the top
        bottom = 5,  -- Margin on the bottom
        widget = wibox.container.margin
    }
end

return wibar

