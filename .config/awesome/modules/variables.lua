-- ~/.config/awesome/modules/variables.lua
local variables = {}

variables.terminal = "alacritty"
variables.editor = os.getenv("EDITOR") or "nano"
variables.editor_cmd = variables.terminal .. " -e " .. variables.editor
variables.modkey = "Mod4"

return variables

