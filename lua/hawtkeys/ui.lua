M = {}
Hawtkeys = require('hawtkeys.score')
M.search = function(text)
  --remove % from start of text
  text = string.gsub(text, "^%%", "")
-- vim.api.nvim_buf_set_lines(ResultBuf, 0, -1, false, Hawtkeys.ScoreTable(text))
ok, msg = pcall(vim.api.nvim_buf_set_lines, ResultBuf, 0, -1, false, Hawtkeys.ScoreTable(text))
end

M.show = function()
  ResultBuf = vim.api.nvim_create_buf(false, true)
  local ui = vim.api.nvim_list_uis()[1]
  local width = 100
  local height = 30
 ResultWin =  vim.api.nvim_open_win(ResultBuf, true, {
    relative = "editor",
    width = width,
    height = height,
    col = (ui.width/2) - (width/2),
    row = (ui.height/2) - (height/2),
    anchor = "NW",
    footer = "Suggested Keybindings",
    footer_pos = "center",
    border = "single",
    noautocmd = true,
  })
  local searchBuf = vim.api.nvim_create_buf(false, true)
  SearchWin = vim.api.nvim_open_win(searchBuf, true, {
    relative = "editor",
    width = width,
    height = 1,
    col = (ui.width/2) - (width/2),
    row = (ui.height/2) - (height/2) - 2,
    anchor = "NW",
    border = "single",
    style = "minimal",
    title = "Enter Command Description",
    title_pos = "center",

  })
--vim.api.nvim_set_option_value("buftype", "prompt", {buf = searchBuf})
  -- when text is entered set the same value in the results buffer 
-- set escape to close the window 
vim.api.nvim_buf_set_keymap(searchBuf, "i", "<esc>", "<cmd>lua require('hawtkeys.ui').hide()<cr>", {noremap = true, silent = true})
vim.api.nvim_buf_set_keymap(searchBuf, "n", "<esc>", "<cmd>lua require('hawtkeys.ui').hide()<cr>", {noremap = true, silent = true})
-- set enter to go to normal modes
 vim.api.nvim_buf_set_keymap(searchBuf, "i", "<cr>", "<cmd>lua require('hawtkeys.ui').search(vim.api.nvim_buf_get_lines("..searchBuf..", 0, 1, false)[1])<cr>", {noremap = true, silent = true})
-- subscribe to changed text in searchBuf
vim.api.nvim_buf_attach(searchBuf, false, {
  on_lines = function()
  end
})
--
vim.api.nvim_set_current_win(SearchWin)
vim.cmd("startinsert")
end

M.hide = function()
  vim.api.nvim_win_close(ResultWin, true)
  vim.api.nvim_win_close(SearchWin, true)
end

return M
