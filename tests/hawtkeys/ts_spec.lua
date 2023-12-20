local ts = require("hawtkeys.ts")
---@diagnostic disable-next-line: undefined-field
local eq = assert.are.same

describe("test", function()
    it("should return true", function()
        eq(true, true)
    end)
end)

describe("ts can extract vim.api.nvim_set_keymap", function()
    it("should find the keymap", function()
        local keymap = ts.find_maps_in_file(
            "tests/hawtkeys/example_configs/vim.api.nvim_set_keymap.lua"
        )
        eq("n", keymap[1].mode)
        eq("<leader>1", keymap[1].lhs)
        eq(':echo "hello"<CR>', keymap[1].rhs)
    end)
end)

describe("ts can extract a vim.keymap.set keymap", function()
    it("should find the keymap", function()
        local keymap = ts.find_maps_in_file(
            "tests/hawtkeys/example_configs/vim.keymap.set_keymap.lua"
        )
        eq("n", keymap[1].mode)
        eq("<leader>2", keymap[1].lhs)
        eq(':echo "hello"<CR>', keymap[1].rhs)
    end)
end)

describe("ts can extract a which-key.register keymap", function()
    it("should find the keymap", function()
        local keymap = ts.find_maps_in_file(
            "tests/hawtkeys/example_configs/which-key.register_keymap.lua"
        )
        eq("n", keymap[1].mode)
        eq("<leader>3", keymap[1].lhs)
        eq(':lua print("hello")<CR>', keymap[1].rhs)
    end)
end)
