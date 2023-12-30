local normalMap = function(lhs, rhs)
    vim.api.nvim_set_keymap("n", lhs, rhs, { noremap = true, silent = true })
end
normalMap("<leader>5", ':echo "hello"<CR>')
