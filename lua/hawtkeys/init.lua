local M = {}

---@class HawtKeyConfig
---@field leader string
---@field homerow number
---@field powerFingers number[]
---@field keyboardLayout string
---@field customMaps { [string] : TSKeyMapArgs | WhichKeyMapargs } | nil

---@type { [string] : TSKeyMapArgs | WhichKeyMapargs }---
local defaultSet = {
    ["vim.keymap.set"] = {
        modeIndex = 1,
        lhsIndex = 2,
        rhsIndex = 3,
        optsIndex = 4,
        method = "dot_index_expression",
    }, --method 1
    ["vim.api.nvim_set_keymap"] = {
        modeIndex = 1,
        lhsIndex = 2,
        rhsIndex = 3,
        optsIndex = 4,
        method = "dot_index_expression",
    }, --method 2
    ["whichkey.register"] = {
        method = "which_key",
    }, -- method 6
}

function M.setup(config)
    config = config or {}
    M.leader = config.leader or " "
    M.homerow = config.homerow or 2
    M.powerFingers = config.powerFingers or { 2, 3, 6, 7 }
    M.keyboardLayout = config.keyboardLayout or "qwerty"
    M.keyMapSet = defaultSet
end

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

return M
