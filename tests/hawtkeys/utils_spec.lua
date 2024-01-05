local hawtkeys = require("hawtkeys")
local ts = require("hawtkeys.ts")
local utils = require("hawtkeys.utils")
---@diagnostic disable-next-line: undefined-field
local eq = assert.are.same

describe("utils functionality raw", function()
    it("can find duplicate lhs in table", function()
        local keymaps = {
            { lhs = "a", rhs = "1" },
            { lhs = "a", rhs = "2" },
            { lhs = "b", rhs = "3" },
        }
        local duplicates = utils.find_duplicates(keymaps)
        eq(2, #duplicates.a)
        eq("a", duplicates.a[1].lhs)
        eq("a", duplicates.a[2].lhs)
    end)

    it("can find multiple duplicate lhs in table", function()
        local keymaps = {
            { lhs = "a", rhs = "1" },
            { lhs = "a", rhs = "2" },
            { lhs = "b", rhs = "3" },
            { lhs = "b", rhs = "4" },
        }
        local duplicates = utils.find_duplicates(keymaps)
        eq(2, #duplicates.a)
        eq("a", duplicates.a[1].lhs)
        eq("a", duplicates.a[2].lhs)
        eq(2, #duplicates.b)
        eq("b", duplicates.b[1].lhs)
        eq("b", duplicates.b[2].lhs)
    end)

    it("sanitising <#> strings in a lhs", function()
        eq("<leader>a", utils.sanitise_modifier_keys("<leader>a"))
        eq("<leader>a", utils.sanitise_modifier_keys("<Leader>a"))
        eq("<leader>a", utils.sanitise_modifier_keys("<LEADER>a"))
        eq("<leader>A", utils.sanitise_modifier_keys("<LEADER>A"))
        eq("<leader>A", utils.sanitise_modifier_keys("<leader>A"))
        eq("<leader>A", utils.sanitise_modifier_keys("<Leader>A"))
        eq("<c-a>", utils.sanitise_modifier_keys("<c-a>"))
        eq("<c-a>", utils.sanitise_modifier_keys("<C-a>"))
        eq("<c-a>", utils.sanitise_modifier_keys("<C-A>"))
        eq("<c-a>", utils.sanitise_modifier_keys("<C-A>"))
        eq("gd", utils.sanitise_modifier_keys("gd"))
        eq("gD", utils.sanitise_modifier_keys("gD"))
    end)
end)

describe("Duplicates with Treesitter Read Data", function()
    before_each(function()
        require("plenary.reload").reload_module("hawtkeys")
        ts.reset_scanned_files()
        hawtkeys.setup({})
    end)

    it("should detect duplicates", function()
        local keymap = ts.find_maps_in_file(
            "tests/hawtkeys/example_configs/duplicates.lua"
        )

        eq("n", keymap[1].mode)
        eq("<leader>t", keymap[1].lhs)

        eq("n", keymap[2].mode)
        eq("<leader>t", keymap[2].lhs)

        eq("x", keymap[3].mode)
        eq("<leader>f", keymap[3].lhs)

        eq("x", keymap[4].mode)
        eq("<leader>f", keymap[4].lhs)

        local dupes = utils.find_duplicates(keymap)

        eq("n", dupes["<leader>t"][1].mode)
        eq("n", dupes["<leader>t"][2].mode)

        eq("x", dupes["<leader>f"][1].mode)
        eq("x", dupes["<leader>f"][2].mode)
    end)

    it(
        "should detect duplicates with differing casing in the modifiers",
        function()
            local keymap = ts.find_maps_in_file(
                "tests/hawtkeys/example_configs/duplicates_with_casing.lua"
            )

            eq("n", keymap[1].mode)
            eq("<leader>t", keymap[1].lhs)

            eq("n", keymap[2].mode)
            eq("<Leader>t", keymap[2].lhs)

            eq("n", keymap[3].mode)
            eq("<C-a>", keymap[3].lhs)

            eq("n", keymap[4].mode)
            eq("<c-a>", keymap[4].lhs)

            local dupes = utils.find_duplicates(keymap)

            eq("n", dupes["<leader>t"][1].mode)
            eq("n", dupes["<leader>t"][2].mode)

            eq("n", dupes["<C-a>"][1].mode)
            eq("n", dupes["<c-a>"][1].mode)
        end
    )

    it("should detected duplicates in non-modifier based keymaps", function()
        local keymap = ts.find_maps_in_file(
            "tests/hawtkeys/example_configs/duplicates_no_modififers.lua"
        )

        eq("n", keymap[1].mode)
        eq("gd", keymap[1].lhs)

        eq("n", keymap[2].mode)
        eq("gd", keymap[2].lhs)

        local dupes = utils.find_duplicates(keymap)

        eq("n", dupes["gd"][1].mode)
        eq("n", dupes["gd"][2].mode)
    end)

    it("can detect the filename of a duplicate", function()
        local filename = "tests/hawtkeys/example_configs/duplicates.lua"
        local keymaps = ts.find_maps_in_file(filename)
        local dupes = utils.find_duplicates(keymaps)

        eq(filename, dupes["<leader>t"][1].from_file)
    end)

    it("can detect duplicates in seperate files", function()
        local file1 = "tests/hawtkeys/example_configs/duplicates.lua"
        local file2 = "tests/hawtkeys/example_configs/duplicates2.lua"
        local keymaps1 = ts.find_maps_in_file(file1)
        local keymaps2 = ts.find_maps_in_file(file2)

        local keymaps = vim.tbl_extend("force", keymaps1, keymaps2)

        local dupes = utils.find_duplicates(keymaps)

        eq("x", dupes["<leader>f"][1].mode)
        eq(file2, dupes["<leader>f"][1].from_file)
        eq("x", dupes["<leader>f"][2].mode)
        eq(file1, dupes["<leader>f"][2].from_file)
    end)

    it(
        "should detect duplicates with partial mode matches for multi-mode maps",
        function()
            local keymap = ts.find_maps_in_file(
                "tests/hawtkeys/example_configs/multi_mode.lua"
            )
            eq({ "n", "x" }, keymap[1].mode)
            eq("<leader>2", keymap[1].lhs)
            eq(':echo "hello"<CR>', keymap[1].rhs)

            eq({ "x", "v" }, keymap[2].mode)
            eq("<leader>2", keymap[2].lhs)
            eq(':echo "hello2"<CR>', keymap[2].rhs)

            eq("v", keymap[3].mode)
            eq("<leader>2", keymap[3].lhs)
            eq(':echo "hello3"<CR>', keymap[3].rhs)

            local dupes = utils.find_duplicates(keymap)

            eq({ "n", "x" }, dupes["<leader>2"][1].mode)
            eq({ "x", "v" }, dupes["<leader>2"][2].mode)
            eq("v", dupes["<leader>2"][3].mode)
        end
    )
end)
