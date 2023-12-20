local hawtkeys = require("hawtkeys")
local ts = require("hawtkeys.ts")
---@diagnostic disable-next-line: undefined-field
local eq = assert.are.same

describe("test", function()
    it("should return true", function()
        eq(true, true)
    end)
end)

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
    end
)
