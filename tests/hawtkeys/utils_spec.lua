local utils = require("hawtkeys.utils")
---@diagnostic disable-next-line: undefined-field
local eq = assert.are.same

describe("utils functionality", function()
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
