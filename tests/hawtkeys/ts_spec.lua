local hawtkeys = require("hawtkeys")
local ts = require("hawtkeys.ts")
---@diagnostic disable-next-line: undefined-field
local eq = assert.are.same
---@diagnostic disable-next-line: undefined-field
local falsy = assert.falsy

describe("Uninstalled plugins", function()
    before_each(function()
        require("plenary.reload").reload_module("hawtkeys")
        ts.reset_scanned_files()
        hawtkeys.setup({
            customMaps = {
                ["lazy"] = {
                    method = "lazy",
                },
                ["whichkey.register"] = {
                    method = "which_key",
                },
            },
        })
        vim.cmd("messages clear")
    end)
    it("which key doesnt cause error", function()
        local ok, _ = pcall(function()
            return require("which-key")
        end)
        local keymapWhichKey = ts.find_maps_in_file(
            "tests/hawtkeys/example_configs/which-key.register_keymap.lua"
        )
        local messages = vim.api.nvim_exec2("messages", { output = true })
        eq(false, ok)
        eq(0, #keymapWhichKey)
        eq({
            ["output"] = "Which Key Mappings require which-key to be installed",
        }, messages)
    end)

    it("Lazy doesnt cause error", function()
        local ok, _ = pcall(function()
            return require("lazy")
        end)
        local keymapLazy = ts.get_keymaps_from_lazy()
        local messages = vim.api.nvim_exec2("messages", { output = true })
        eq(false, ok)
        eq(0, #keymapLazy)
        eq({ ["output"] = "Lazy Loading requires Lazy" }, messages)
    end)
end)

describe("Treesitter can extract keymaps", function()
    before_each(function()
        require("plenary.reload").reload_module("hawtkeys")
        ts.reset_scanned_files()
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

    it("extract multi-mode keymaps", function()
        local keymap = ts.find_maps_in_file(
            "tests/hawtkeys/example_configs/multi_mode.lua"
        )
        eq({ "n", "x" }, keymap[1].mode)
        eq("<leader>2", keymap[1].lhs)
        eq(':echo "hello"<CR>', keymap[1].rhs)

        eq({ "x", "v" }, keymap[2].mode)
        eq("<leader>2", keymap[2].lhs)
        eq(':echo "hello2"<CR>', keymap[2].rhs)
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

describe("Which Key Managed Maps", function()
    before_each(function()
        require("plenary.reload").reload_module("hawtkeys")
        require("tests.minimal_init").loadWhichKey()
        ts.reset_scanned_files()
        hawtkeys.setup({
            customMaps = {
                ["whichkey.register"] = {
                    method = "which_key",
                },
            },
        })
    end)

    it("extract whichkey.register() keymap", function()
        local keymap = ts.find_maps_in_file(
            "tests/hawtkeys/example_configs/which-key.register_keymap.lua"
        )
        eq("n", keymap[1].mode)
        eq("<leader>3", keymap[1].lhs)
        eq(':lua print("hello")<CR>', keymap[1].rhs)
    end)
end)

describe("Lazy Managed Plugins", function()
    before_each(function()
        require("plenary.reload").reload_module("hawtkeys")
        ts.reset_scanned_files()
        hawtkeys.setup({
            customMaps = {
                ["lazy"] = {
                    method = "lazy",
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
    end)
    it("extract keys set in a Lazy init", function()
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
        local lazyKeymaps = ts.get_keymaps_from_lazy()
        eq("n", lazyKeymaps[1].mode)
        eq("<leader>1", lazyKeymaps[1].lhs)
        eq(":lua print(1)<CR>", lazyKeymaps[1].rhs)
        eq(
            "Lazy Init:ellisonleao/nvim-plugin-template",
            lazyKeymaps[1].from_file
        )
    end)
    it(
        "extract keys where the lazy key setting is a function and returns as string",
        function()
            local lazy = require("lazy")
            lazy.setup({
                "ellisonleao/nvim-plugin-template",
                keys = {
                    {
                        "<leader>1",
                        function()
                            print(1)
                        end,
                        desc = "Test Lazy Print 1",
                    },
                },
            })
            local lazyKeymaps = ts.get_keymaps_from_lazy()
            eq("n", lazyKeymaps[1].mode)
            eq("<leader>1", lazyKeymaps[1].lhs)
            eq("string", type(lazyKeymaps[1].rhs))
            eq(
                "Lazy Init:ellisonleao/nvim-plugin-template",
                lazyKeymaps[1].from_file
            )
        end
    )
end)
