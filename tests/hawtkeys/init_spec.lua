local hawtkeys = require("hawtkeys")
---@diagnostic disable-next-line: undefined-field
local eq = assert.are.same
---@diagnostic disable-next-line: undefined-field
local falsy = assert.falsy
local userCommands = {
    ["Hawtkeys"] = "lua require('hawtkeys.ui').show()",
    ["HawtkeysAll"] = "lua require('hawtkeys.ui').show_all()",
    ["HawtkeysDupes"] = "lua require('hawtkeys.ui').show_dupes()",
}

describe("set up function", function()
    before_each(function()
        require("plenary.reload").reload_module("hawtkeys")
        for _, command in ipairs(userCommands) do
            vim.api.nvim_command("silent! delcommand " .. command)
        end
    end)
    it("should set up the default config", function()
        hawtkeys.setup({})
        ---@diagnostic disable-next-line: invisible
        eq(hawtkeys.defaultConfig, hawtkeys.config)
    end)

    it("should be able to override the default config", function()
        hawtkeys.setup({ leader = "," })
        eq(",", hawtkeys.config.leader)
    end)

    it("can set custom highlights", function()
        hawtkeys.setup({
            highlights = {
                HawtkeysMatchGreat = {
                    link = "DiagnosticSomethingElse",
                },
            },
        })
        eq(
            "DiagnosticSomethingElse",
            hawtkeys.config.highlights.HawtkeysMatchGreat.link
        )
        eq(
            ---@diagnostic disable-next-line: invisible
            hawtkeys.defaultConfig.highlights.HawtkeysMatchGood,
            hawtkeys.config.highlights.HawtkeysMatchGood
        )
    end)

    it("can pass in custom mapping definitions", function()
        hawtkeys.setup({
            customMaps = {
                ["custom.map"] = {
                    method = "dot_index_expression",
                    lhsIndex = 1,
                    rhsIndex = 2,
                    modeIndex = "n",
                    optsIndex = 3,
                },
            },
        })
        eq(
            "dot_index_expression",
            hawtkeys.config.keyMapSet["custom.map"].method
        )
        eq(1, hawtkeys.config.keyMapSet["custom.map"].lhsIndex)
        eq(2, hawtkeys.config.keyMapSet["custom.map"].rhsIndex)
        eq("n", hawtkeys.config.keyMapSet["custom.map"].modeIndex)
        eq(3, hawtkeys.config.keyMapSet["custom.map"].optsIndex)
    end)

    it("User commands should be available after setup", function()
        local commandspresetup = vim.api.nvim_get_commands({})
        hawtkeys.setup({})

        local commandsPostSetup = vim.api.nvim_get_commands({})
        -- Check that the commands are not present before setup
        for command, _ in ipairs(userCommands) do
            falsy(commandspresetup[command])
        end
        -- Check that the commands are present after setup
        for command, action in ipairs(userCommands) do
            eq(action, commandsPostSetup[command].definition)
        end
    end)
end)
