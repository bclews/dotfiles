-- Force transparency for snacks_picker_input buffers
vim.api.nvim_create_autocmd("FileType", {
  pattern = "snacks_picker_input",
  callback = function()
    local win = vim.api.nvim_get_current_win()
    -- Force transparent background for this specific window
    vim.api.nvim_win_set_option(win, "winhl", "Normal:Normal,NormalNC:Normal,CursorLine:CursorLine")
    
    -- Also set the highlight groups for this buffer
    vim.api.nvim_set_hl(0, "SnacksPickerInput", { bg = "NONE" })
    vim.api.nvim_set_hl(0, "SnacksPickerInputBorder", { bg = "NONE" })
  end,
})

-- Same for the list
vim.api.nvim_create_autocmd("FileType", {
  pattern = "snacks_picker_list",
  callback = function()
    local win = vim.api.nvim_get_current_win()
    vim.api.nvim_win_set_option(win, "winhl", "Normal:Normal,NormalNC:Normal")
  end,
})

-- Handle Explorer title transparency
vim.api.nvim_create_autocmd({"FileType", "BufWinEnter"}, {
  pattern = {"snacks_picker_input", "snacks_picker_list"},
  callback = function()
    local win = vim.api.nvim_get_current_win()
    
    -- Force transparent title/winbar
    vim.api.nvim_win_set_option(win, "winhl", 
      "Normal:Normal,NormalNC:Normal,WinBar:Normal,Title:Normal,FloatTitle:Normal")
    
    -- Make title-related highlight groups transparent
    vim.api.nvim_set_hl(0, "FloatTitle", { bg = "NONE" })
    vim.api.nvim_set_hl(0, "WinBar", { bg = "NONE" })
    vim.api.nvim_set_hl(0, "WinBarNC", { bg = "NONE" })
  end,
})
