M = {}

vim.api.nvim_set_keymap("n", "<Plug>Test", "", {})
vim.api.nvim_set_keymap("n", "<leader>abÞ", "", {})

M.reset = function()
    vim.api.nvim_del_keymap("n", "<Plug>Test")
    vim.api.nvim_del_keymap("n", "<leader>abÞ")
end

return M
