-- ~/.config/awesome/modules/signals.lua
local awful = require("awful")
local gears = require("gears")
local beautiful = require("beautiful")

local signals = {}

signals.setup = function()
    client.connect_signal("manage", function (c)
        if awesome.startup
          and not c.size_hints.user_position
          and not c.size_hints.program_position then
            awful.placement.no_offscreen(c)
        end

        if c.floating then
            c.ontop = true
            c:raise()
        end
    end)

    client.connect_signal("focus", function(c)
        c.border_color = beautiful.border_focus
        if c.floating then
            c.ontop = true
            c:raise()
        end
    end)

    client.connect_signal("unfocus", function(c)
        c.border_color = beautiful.border_normal
    end)

    client.connect_signal("button::press", function(c)
        c:emit_signal("request::activate", "mouse_click", {raise = true})
        if c.floating then
            c.ontop = true
            c:raise()
        end
    end)

    client.connect_signal("mouse::enter", function(c)
        c:emit_signal("request::activate", "mouse_enter", {raise = true})
        if c.floating then
            c.ontop = true
            c:raise()
        end
    end)
end

return signals

