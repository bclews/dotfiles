return {
  {
    "catppuccin/nvim",
    name = "catppuccin",
    lazy = false,
    priority = 1000,
    opts = {
      transparent_background = true,
      transparent_sidebar = true,
      transparent_float = true,
      integrations = {
        bufferline = true,
        neotree = true, -- Make sure neotree integration is enabled
      },
    },
    config = function(_, opts)
      -- Actually use the opts by passing them to setup
      require("catppuccin").setup(opts)

      -- Fix for the bufferline issue
      local module = require("catppuccin.groups.integrations.bufferline")
      if module then
        module.get = module.get_theme
      end

      -- Set the colorscheme after setup
      vim.cmd.colorscheme("catppuccin-macchiato")

      -- Force transparency for sidebar elements
      vim.api.nvim_create_autocmd("ColorScheme", {
        pattern = "*",
        callback = function()
          local transparent_groups = {
            "NeoTreeNormal",
            "NeoTreeNormalNC",
            "NeoTreeEndOfBuffer",
            "NeoTreeWinSeparator",
            "NeoTreeRootName",
            "NeoTreeDirectoryName",
            "NeoTreeFileName",
            "NeoTreeFileNameOpened",
            "NeoTreeIndentMarker",
            "NeoTreeExpander",
            "NeoTreeFloatBorder",
            "NeoTreeFloatTitle",
            "NeoTreeTitleBar",
            "NeoTreeTabActive",
            "NeoTreeTabInactive",
            "NeoTreeTabSeparatorActive",
            "NeoTreeTabSeparatorInactive",
          }
          for _, group in pairs(transparent_groups) do
            vim.api.nvim_set_hl(0, group, { bg = "NONE" })
          end
        end,
      })

      -- Apply immediately as well
      local transparent_groups = {
        "NeoTreeNormal",
        "NeoTreeNormalNC",
        "NeoTreeEndOfBuffer",
        "NeoTreeWinSeparator",
      }
      for _, group in pairs(transparent_groups) do
        vim.api.nvim_set_hl(0, group, { bg = "NONE" })
      end
    end,
  },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "catppuccin-macchiato",
    },
  },
}
