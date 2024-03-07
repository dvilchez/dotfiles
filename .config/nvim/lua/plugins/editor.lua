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
      window = {
        position = "current",
      },
    },
  },
}
