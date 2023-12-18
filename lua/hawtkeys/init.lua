local M = {}
function M.setup(config)
    config = config or {}
    M.leader = config.leader or " "
    M.homerow = config.homerow or 2
    M.powerFingers = config.powerFingers or { 2, 3, 6, 7 }
    M.keyboardLayout = config.keyboardLayout or "qwerty"
    vim.api.nvim_create_user_command(
        "Hawtkeys",
        "lua require('hawtkeys.ui').show()",
        {}
    )
    vim.api.nvim_create_user_command(
        "HawtkeysAll",
        "lua require('hawtkeys.ui').show_all()",
        {}
    )
    vim.api.nvim_create_user_command(
        "HawtkeysDupes",
        "lua require('hawtkeys.ui').show_dupes()",
        {}
    )
end

return M
