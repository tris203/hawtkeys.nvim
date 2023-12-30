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
end)
