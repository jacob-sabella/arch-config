-- Hyprland Lua config — Jacob Sabella
-- Ported from hyprlang (HLDE flavor) to Lua per 0.55+ migration.
--
-- Modular: each require() runs in its own scope; errors don't cascade.
-- All modules live in this dir (~/.config/hypr/lua/).
-- Activated via ~/.config/hypr/hyprland.lua → this file.

-- Local lookup path so require("foo") finds ./foo.lua.
package.path = os.getenv("HOME") .. "/.config/hypr/lua/?.lua;" .. package.path

require("colors")
require("env")
require("monitors")
require("settings")
require("animations")
require("rules")
require("workspaces")
require("binds")
require("autostart")
require("plugins")
sidepanels = require("sidepanels")  -- global so binds.lua can call sidepanels.assign()
