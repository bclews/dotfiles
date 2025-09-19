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
        snacks = true,
      },
    },
    config = function(_, opts)
      require("catppuccin").setup(opts)
      
      -- Fix for the bufferline issue
      local module = require("catppuccin.groups.integrations.bufferline")
      if module then
        module.get = module.get_theme
      end

      vim.cmd.colorscheme("catppuccin-macchiato")
      
      -- Force transparency
      local function make_transparent()
        vim.api.nvim_set_hl(0, "Normal", { bg = "NONE" })
        vim.api.nvim_set_hl(0, "NormalNC", { bg = "NONE" })
        
        -- Target all Snacks-related groups
        local snacks_groups = {
          "SnacksPickerInput",
          "SnacksPickerInputBorder",
          "SnacksPickerInputNormal",
          "SnacksPickerList",
          "SnacksPickerListNormal", 
          "SnacksPickerNormal",
          "SnacksPickerBorder",
          "SnacksExplorerNormal",
          "SnacksExplorerInput",
          "SnacksNormal",
        }
        
        for _, group in ipairs(snacks_groups) do
          vim.api.nvim_set_hl(0, group, { bg = "NONE" })
        end
      end
      
      make_transparent()
      
      vim.api.nvim_create_autocmd({"ColorScheme", "VimEnter", "BufEnter", "WinEnter"}, {
        callback = make_transparent,
      })
    end,
  },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "catppuccin-macchiato",
    },
  },
}
