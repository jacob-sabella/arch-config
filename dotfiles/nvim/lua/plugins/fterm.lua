-- ~/.config/nvim/lua/plugins/fterm.lua
return {
  "numToStr/FTerm.nvim",
  config = function()
    require("FTerm").setup({
      -- Optional configuration parameters
      border = "double",
      dimensions = {
        height = 0.9,
        width = 0.9,
      },
    })
  end,
}
