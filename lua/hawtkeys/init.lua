M = {}
function M.setup(config)
    M.leader = config.leader or " "
    M.homerow = config.homerow or 2
    M.powerFingers = config.powerFingers or { 2, 3, 6, 7 }
    M.keyboardLayout = config.keyboardLayout or "qwerty"
    M.keymap = config.keymap or "<leader>hwt"
    vim.api.nvim_set_keymap('n', M.keymap, ':lua require("hawtkeys.ui").show()<CR>',
        { noremap = true, silent = true })
end

return M
