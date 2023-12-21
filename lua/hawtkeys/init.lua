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

M.defaultConfig = {
    leader = " ",
    homerow = 2,
    powerFingers = { 2, 3, 6, 7 },
    keyboardLayout = "qwerty",
    keyMapSet = _defaultSet,
    highlights = {
        HawtkeysMatchGreat = { link = "DiagnosticOk", underline = true },
        HawtkeysMatchGood = { link = "DiagnosticOk" },
        HawtkeysMatchOk = { link = "DiagnosticWarn" },
        HawtkeysMatchBad = { link = "DiagnosticError" },
    },
}

---@param config HawtKeyPartialConfig
function M.setup(config)
    config = vim.tbl_deep_extend("force", M.defaultConfig, config or {})

    config.keyMapSet =
        vim.tbl_deep_extend("force", _defaultSet, config.customMaps or {})
    config.customMaps = nil
    local appliedHighlights = {}
    for name, props in pairs(config.highlights) do
        local styleConfig =
            vim.api.nvim_get_hl(0, { name = props.link, link = false })
        for k, v in pairs(props) do
            if k == "link" then
                break
            end
            styleConfig[k] = v
        end
        appliedHighlights[name] = styleConfig
    end

    M.config = config

    for name, hl in pairs(appliedHighlights) do
        vim.api.nvim_set_hl(0, name, hl)
    end

    vim.api.nvim_create_autocmd("ColorScheme", {
        callback = function()
            for name, hl in pairs(appliedHighlights) do
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
