local Util = require("lazyvim.util")

return {
  {
    "nvim-neo-tree/neo-tree.nvim",
    keys = {
      {
        "<leader>fe",
        function()
          require("neo-tree.command").execute({
            toggle = true,
            dir = Util.root(),
            reveal = true,
          })
        end,
        desc = "Explorer NeoTree (root dir)",
      },
    },
    opts = {
      filesystem = {
        filtered_items = {
          visible = true, -- This is what you want: If you set this to `true`, all "hide" just mean "dimmed out"
          hide_dotfiles = false,
          hide_gitignored = true,
        },
      },
      window = {
        position = "current",
      },
    },
  },
  {
    "almo7aya/openingh.nvim",
  },
}
