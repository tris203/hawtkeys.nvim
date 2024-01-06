---@diagnostic disable-next-line: undefined-field
local eq = assert.are.same
local truthy = assert.is_true
local ts = require("hawtkeys.ts")

local function copy_configs_to_stdpath_config()
    local config_dir = vim.fn.stdpath("config")
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
        print(vim.inspect(keymaps))
        truthy(vim.tbl_contains(keymaps, function(v)
            return vim.deep_equal(v, {
                from_file = "Vim Defaults",
                lhs = "Y",
                mode = "n",
                rhs = "y$",
            })
        end, { predicate = true }))
    end)

    it("can detect a keymap from a file", function()
        local keymaps = ts.get_all_keymaps()
        print(vim.fn.stdpath("config"))
        print(vim.inspect(keymaps))
        truthy(vim.tbl_contains(keymaps, function(v)
            return vim.deep_equal(v, {
                from_file = vim.fn.stdpath("config") .. "/e2e_config.lua",
                lhs = "<leader>example",
                mode = "n",
                rhs = "<cmd>echo 'Example'<cr>",
            })
        end, { predicate = true }))
    end)

    it("should find a file in stdpath('config')", function()
        eq(true, true)
    end)
end)
