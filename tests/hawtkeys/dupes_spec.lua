local hawtkeys = require("hawtkeys")
local util = require("hawtkeys.utils")
local ts = require("hawtkeys.ts")
---@diagnostic disable-next-line: undefined-field
local eq = assert.are.same

describe("HawtkeysDupes", function()
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

        local dupes = util.find_duplicates(keymap)

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

            local dupes = util.find_duplicates(keymap)

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

        local dupes = util.find_duplicates(keymap)

        eq("n", dupes["gd"][1].mode)
        eq("n", dupes["gd"][2].mode)
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

            local dupes = util.find_duplicates(keymap)

            eq({ "n", "x" }, dupes["<leader>2"][1].mode)
            eq({ "x", "v" }, dupes["<leader>2"][2].mode)
            eq("v", dupes["<leader>2"][3].mode)
        end
    )
end)
