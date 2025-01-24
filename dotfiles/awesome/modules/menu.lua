-- ~/.config/awesome/modules/menu.lua
local awful = require("awful")
local beautiful = require("beautiful")
local variables = require("modules.variables")

local menu = {}

menu.myawesomemenu = {
   { "hotkeys", function() hotkeys_popup.show_help(nil, awful.screen.focused()) end },
   { "manual", variables.terminal .. " -e man awesome" },
   { "edit config", variables.editor_cmd .. " " .. awesome.conffile },
   { "restart", awesome.restart },
   { "quit", function() awesome.quit() end },
}

menu.mymainmenu = awful.menu({ items = { { "awesome", menu.myawesomemenu, beautiful.awesome_icon },
                                         { "open terminal", variables.terminal }
                                       }
                             })

menu.mylauncher = awful.widget.launcher({ image = beautiful.awesome_icon,
                                          menu = menu.mymainmenu })


return menu

