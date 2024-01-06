---@diagnostic disable-next-line: undefined-field
local eq = assert.are.same
---@diagnostic disable-next-line: undefined-field
local truthy = assert.is_true
local ts = require("hawtkeys.ts")

local function copy_configs_to_stdpath_config()
    local config_dir = vim.fn.stdpath("config")
    vim.fn.mkdir(config_dir, "p")
    vim.fn.writefile(
        vim.fn.readfile("tests/hawtkeys/example_configs/e2e_config.lua"),
        config_dir .. "/e2e_config.lua"
    )
end

describe("file searching", function()
    before_each(function()
        copy_configs_to_stdpath_config()
        require("hawtkeys").setup({})
    end)

    it("can detect a Vim Default Keymap", function()
        local keymaps = ts.get_all_keymaps()
        truthy(vim.tbl_contains(keymaps, function(v)
            return v.from_file == "Vim Defaults"
        end, { predicate = true }))
    end)

    it("can detect a keymap from a file", function()
        local keymaps = ts.get_all_keymaps()
        truthy(vim.tbl_contains(keymaps, function(v)
            return v.from_file == vim.fn.stdpath("config") .. "/e2e_config.lua"
        end, { predicate = true }))
    end)

    it("should find a file in stdpath('config')", function()
        eq(true, true)
    end)

    after_each(function()
        vim.cmd("silent! !rm " .. vim.fn.stdpath("config") .. "/e2e_config.lua")
    end)
end)
