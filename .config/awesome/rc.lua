pcall(require, "luarocks.loader")


-- Standard awesome library
local gears = require("gears")
local awful = require("awful")
require("awful.autofocus")
local wibox = require("wibox")
local beautiful = require("beautiful")
local naughty = require("naughty")
local hotkeys_popup = require("awful.hotkeys_popup")
require("awful.hotkeys_popup.keys")

-- Load custom modules
require("modules.error_handling")
local variables = require("modules.variables")
local layout = require("modules.layout")
local menu = require("modules.menu")
local wibar = require("modules.wibar")
local bindings = require("modules.bindings")
local rules = require("modules.rules")
local signals = require("modules.signals")

-- Set keys
root.keys(bindings.globalkeys)

-- Set up monitors before setting up screens
layout.setup_monitors()

-- {{{ Set wallpaper
awful.screen.connect_for_each_screen(function(s)
    beautiful.init(gears.filesystem.get_themes_dir() .. "default/theme.lua")
    layout.set_wallpaper(s)
    layout.setup_screen(s)
end)
-- }}}

-- Set rules
awful.rules.rules = rules.create()

-- Set up signals
signals.setup()

client.connect_signal("request::titlebars", layout.setup_titlebar)

-- Restore background
awful.spawn.with_shell("nitrogen --restore")

-- Force initial layout
for s = 1, screen.count() do
    for _, t in ipairs(screen[s].tags) do
        t.layout = awful.layout.suit.spiral.dwindle
    end
end

