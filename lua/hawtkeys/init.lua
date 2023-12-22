---@class Hawtkeys
---@field config HawtKeyConfig
---@field package defaultConfig HawtKeyConfig
local M = {}

---@alias HawtKeySupportedKeyboardLayouts "qwerty" | "dvorak"

---@class HawtKeyConfig
---@field leader string
---@field homerow number
---@field powerFingers number[]
---@field keyboardLayout HawtKeySupportedKeyboardLayouts
---@field keyMapSet { [string] : TSKeyMapArgs | WhichKeyMapargs | LazyKeyMapArgs }
---@field customMaps { [string] : TSKeyMapArgs | WhichKeyMapargs | LazyKeyMapArgs } | nil
---@field highlights HawtKeyHighlights
---@field lhsBlacklist string[]

---@class HawtKeyHighlights
---@field HawtkeysMatchGreat vim.api.keyset.highlight | nil
---@field HawtkeysMatchGood vim.api.keyset.highlight | nil
---@field HawtkeysMatchOk vim.api.keyset.highlight | nil
---@field HawtkeysMatchBad vim.api.keyset.highlight | nil

---@class HawtKeyPartialConfig
---@field leader string | nil
---@field homerow number | nil
---@field powerFingers number[] | nil
---@field keyboardLayout HawtKeySupportedKeyboardLayouts | nil
---@field customMaps { [string] : TSKeyMapArgs | WhichKeyMapargs | LazyKeyMapArgs } | nil
---@field highlights HawtKeyHighlights | nil
---@field lhsBlacklist string[] | nil

---@type { [string] : TSKeyMapArgs | WhichKeyMapargs | LazyKeyMapArgs }
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

---@type HawtKeyConfig
local defaultConfig = {
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
    --[[
<plug> is used internally by vim to map keys to functions
Þ is used internally by whickkey to map NOP functions for menu popup timeout
]]
    lhsBlacklist = { "<plug>", "Þ" },
}

local function apply_highlights()
    for name, props in pairs(M.config.highlights) do
        local styleConfig
        if props.link then
            styleConfig = vim.api.nvim_get_hl(0, {
                name = props.link,
                link = false,
            })
        else
            styleConfig = {}
        end

        for k, v in pairs(props) do
            if k ~= "link" then
                styleConfig[k] = v
            end
        end
        vim.api.nvim_set_hl(0, name, styleConfig)
    end
end

---@param config HawtKeyPartialConfig
function M.setup(config)
    M.config = M.config or {}
    for k, default in pairs(defaultConfig) do
        local v = config[k]
        if k == "highlights" then
            -- shallow merge to preserve highlight values
            M.config[k] =
                vim.tbl_extend("force", defaultConfig.highlights, v or {})
        elseif k == "keyMapSet" then
            M.config[k] = vim.tbl_deep_extend(
                "force",
                defaultConfig.keyMapSet,
                config.customMaps or {}
            )
        elseif type(default) == "table" then
            M.config[k] = vim.tbl_deep_extend("force", default, v or {})
        else
            M.config[k] = v or default
        end
    end

    apply_highlights()

    vim.api.nvim_create_autocmd("ColorScheme", {
        callback = apply_highlights,
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

setmetatable(M, {
    __index = function(_, k)
        if k == "defaultConfig" then
            return vim.deepcopy(defaultConfig)
        end
    end,
})

return M
