vim.keymap.set("n", "<leader>t", ":term", {})

vim.api.nvim_set_keymap("n", "<leader>t", "<cmd>ToggleTerm<CR>", {})

vim.keymap.set("x", "<leader>f", ':echo "test"<CR>', {})

vim.api.nvim_set_keymap("x", "<leader>f", '<cmd>echo "test"<CR>', {})
