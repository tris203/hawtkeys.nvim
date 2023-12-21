local M = {}

---@alias SupportedKeyboardLayouts "qwerty" | "dvorak"

---@class HawtKeyConfig
---@field leader string
---@field homerow number
---@field powerFingers number[]
---@field keyboardLayout SupportedKeyboardLayouts
---@field customMaps { [string] : TSKeyMapArgs | WhichKeyMapargs } | nil

---@class HawtKeyHighlights
---@field HawtkeysMatchGreat vim.api.keyset.highlight | nil
---@field HawtkeysMatchGood vim.api.keyset.highlight | nil
---@field HawtkeysMatchOk vim.api.keyset.highlight | nil
---@field HawtkeysMatchBad vim.api.keyset.highlight | nil

---@class HawtKeyPartialConfig
---@field leader string | nil
---@field homerow number | nil
---@field powerFingers number[] | nil
---@field keyboardLayout SupportedKeyboardLayouts | nil
---@field customMaps { [string] : TSKeyMapArgs | WhichKeyMapargs } | nil
---@field highlights HawtKeyHighlights | nil
---

---@type { [string] : TSKeyMapArgs | WhichKeyMapargs }---

local _defaultSet = {
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

---@param config HawtKeyPartialConfig
function M.setup(config)
    config = config or {}
    M.leader = config.leader or " "
    M.homerow = config.homerow or 2
    M.powerFingers = config.powerFingers or { 2, 3, 6, 7 }
    M.keyboardLayout = config.keyboardLayout or "qwerty"
    M.keyMapSet = vim.tbl_extend("force", _defaultSet, config.customMaps or {})

    local default_match_great
    if not config.highlights or not config.highlights.HawtkeysMatchGreat then
        default_match_great =
            vim.api.nvim_get_hl(0, { name = "DiagnosticOk", link = false })
        default_match_great.underline = true
    end
    M.highlights = vim.tbl_extend("keep", config.highlights or {}, {
        HawtkeysMatchGreat = default_match_great,
        HawtkeysMatchGood = {
            link = "DiagnosticOk",
        },
        HawtkeysMatchOk = {
            link = "DiagnosticWarn",
        },
        HawtkeysMatchBad = {
            link = "DiagnosticError",
        },
    })

    for name, hl in pairs(M.highlights) do
        vim.api.nvim_set_hl(0, name, hl)
    end

    vim.api.nvim_create_autocmd("ColorScheme", {
        callback = function()
            if default_match_great then
                for k, v in
                    pairs(
                        vim.api.nvim_get_hl(
                            0,
                            { name = "DiagnosticOk", link = false }
                        )
                    )
                do
                    default_match_great[k] = v
                end
                default_match_great.underline = true
            end

            for name, hl in pairs(M.highlights) do
                vim.api.nvim_set_hl(0, name, hl)
            end
        end,
    })

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
