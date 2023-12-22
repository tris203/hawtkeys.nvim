local hawtkeys = require("hawtkeys")
local ts = require("hawtkeys.ts")
---@diagnostic disable-next-line: undefined-field
local eq = assert.are.same
---@diagnostic disable-next-line: undefined-field
local falsy = assert.falsy

describe("Treesitter can extract keymaps", function()
    before_each(function()
        require("plenary.reload").reload_module("hawtkeys")
        hawtkeys.setup({})
    end)
    it("extract vim.api.nvim_set_keymap()", function()
        local keymap = ts.find_maps_in_file(
            "tests/hawtkeys/example_configs/vim.api.nvim_set_keymap.lua"
        )
        eq("n", keymap[1].mode)
        eq("<leader>1", keymap[1].lhs)
        eq(':echo "hello"<CR>', keymap[1].rhs)
    end)

    it("extract vim.keymap.set()", function()
        local keymap = ts.find_maps_in_file(
            "tests/hawtkeys/example_configs/vim.keymap.set_keymap.lua"
        )
        eq("n", keymap[1].mode)
        eq("<leader>2", keymap[1].lhs)
        eq(':echo "hello"<CR>', keymap[1].rhs)
    end)

    it("extract whichkey.register() keymap", function()
        local keymap = ts.find_maps_in_file(
            "tests/hawtkeys/example_configs/which-key.register_keymap.lua"
        )
        eq("n", keymap[1].mode)
        eq("<leader>3", keymap[1].lhs)
        eq(':lua print("hello")<CR>', keymap[1].rhs)
    end)

    it("Extract short dot index aliasesd keymap", function()
        hawtkeys.setup({
            customMaps = {
                ["shortIndex.nvim_set_keymap"] = {
                    modeIndex = 1,
                    lhsIndex = 2,
                    rhsIndex = 3,
                    method = "dot_index_expression",
                },
            },
        })
        local keymap = ts.find_maps_in_file(
            "tests/hawtkeys/example_configs/aliased_vim.api.nvim_set_keymap.lua"
        )
        eq("n", keymap[1].mode)
        eq("<leader>4", keymap[1].lhs)
        eq(':echo "hello"<CR>', keymap[1].rhs)
    end)

    it("Extract function call aliased keymap with a fixed mode", function()
        hawtkeys.setup({
            customMaps = {
                ["normalMap"] = {
                    modeIndex = "n",
                    lhsIndex = 1,
                    rhsIndex = 2,
                    method = "function_call",
                },
            },
        })
        local keymap = ts.find_maps_in_file(
            "tests/hawtkeys/example_configs/function_vim.api.nvim_set_keymap.lua"
        )
        -- TODO: currently index 2, as the first index is the function itself
        -- This needs to be fixed
        eq("n", keymap[2].mode)
        eq("<leader>5", keymap[2].lhs)
        eq(':echo "hello"<CR>', keymap[2].rhs)
    end)

    it("Keymaps containing blacklisted characters are ignored", function()
        local numberOfExamples = 2
        local beforeCount = #vim.api.nvim_get_keymap("n")
        require("tests.hawtkeys.example_configs.blacklistCharacter_keymap")
        local afterCount = #vim.api.nvim_get_keymap("n")
        eq(numberOfExamples, afterCount - beforeCount)
        local keymap = ts.get_keymaps_from_vim()
        local blacklist = hawtkeys.config.lhsBlacklist
        for _, map in pairs(keymap) do
            for _, blacklistedItem in pairs(blacklist) do
                falsy(string.find(map.lhs, blacklistedItem))
            end
        end
        require("tests.hawtkeys.example_configs.blacklistCharacter_keymap").reset()
        local finalCount = #vim.api.nvim_get_keymap("n")
        eq(beforeCount, finalCount)
    end)
end)

describe("Lazy Managed Plugins", function()
    before_each(function()
        require("plenary.reload").reload_module("hawtkeys")
        hawtkeys.setup({
        customMaps = {
            ['lazy']  = {
            method = 'lazy',
            },
        },
        })
        require("tests.minimal_init").loadLazy()
        vim.g.lazy_did_setup = false
        vim.go.loadplugins = true
        for modname in pairs(package.loaded) do
            if modname:find("lazy") == 1 then
                package.loaded[modname] = nil
            end
        end
        local lazy = require("lazy")
        lazy.setup({
            "ellisonleao/nvim-plugin-template",
            keys = {
                {
                    "<leader>1",
                    ":lua print(1)<CR>",
                    desc = "Test Lazy Print 1",
                },
            },
        })
    end)
    it("extract keys set in a Lazy init", function()
        local lazyKeymaps = ts.get_keymaps_from_lazy()
        eq("n", lazyKeymaps[1].mode)
        eq("<leader>1", lazyKeymaps[1].lhs)
        eq(':lua print(1)<CR>', lazyKeymaps[1].rhs)
        eq("Lazy Init:ellisonleao/nvim-plugin-template", lazyKeymaps[1].from_file)
    end)
end)
