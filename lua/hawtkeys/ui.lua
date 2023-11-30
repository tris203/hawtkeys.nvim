M = {}
Hawtkeys = require('hawtkeys.score')
M.search = function(text)
  vim.api.nvim_buf_set_lines(ResultBuf, 0, -1, false, Hawtkeys.ScoreTable(text))
end

M.show = function()
  ResultBuf = vim.api.nvim_create_buf(false, true)
  local ui = vim.api.nvim_list_uis()[1]
  local width = 100
  local height = 30
  ResultWin = vim.api.nvim_open_win(ResultBuf, true, {
    relative = "editor",
    width = width,
    height = height,
    col = (ui.width / 2) - (width / 2),
    row = (ui.height / 2) - (height / 2),
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
    col = (ui.width / 2) - (width / 2),
    row = (ui.height / 2) - (height / 2) - 2,
    anchor = "NW",
    border = "single",
    style = "minimal",
    title = "Enter Command Description",
    title_pos = "center",
    noautocmd = true,

  })
  vim.api.nvim_buf_set_keymap(searchBuf, "i", "<esc>", "<cmd>lua require('hawtkeys.ui').hide()<cr>",
    { noremap = true, silent = true })
  vim.api.nvim_buf_set_keymap(searchBuf, "n", "<esc>", "<cmd>lua require('hawtkeys.ui').hide()<cr>",
    { noremap = true, silent = true })
  --disallow new lines in searchBuf
  vim.api.nvim_buf_set_keymap(searchBuf, "i", "<cr>", "<nop>", { noremap = true, silent = true })
  -- subscribe to changed text in searchBuf
  vim.api.nvim_buf_attach(searchBuf, false, {
    on_lines = function()
      vim.schedule(function()
        M.search(vim.api.nvim_buf_get_lines(searchBuf, 0, 1, false)[1])
      end)
    end
  })
  --
  vim.api.nvim_set_current_buf(searchBuf)
  vim.api.nvim_command("startinsert")
end

M.hide = function()
  vim.api.nvim_win_close(ResultWin, true)
  vim.api.nvim_win_close(SearchWin, true)
  vim.api.nvim_command("stopinsert")
end

return M
