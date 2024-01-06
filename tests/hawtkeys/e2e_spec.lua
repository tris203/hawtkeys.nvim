---@diagnostic disable-next-line: undefined-field
local eq = assert.are.same
local ts = require("hawtkeys.ts")
local path = require("plenary.path")

local sep = (function()
    if jit then
        local os = string.lower(jit.os)
        if os ~= "windows" then
            return "/"
        else
            return "\\"
        end
    else
        return package.config:sub(1, 1)
    end
end)()

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
        local notMatch = 0
        local keymaps = ts.get_all_keymaps()
        for _, v in ipairs(keymaps) do
            if
                vim.deep_equal(v, {
                    from_file = "Vim Defaults",
                    lhs = "Y",
                    mode = "n",
                    rhs = "y$",
                })
            then
                eq(v, {
                    from_file = "Vim Defaults",
                    lhs = "Y",
                    mode = "n",
                    rhs = "y$",
                })
            else
                notMatch = notMatch + 1
            end
        end
        eq(vim.tbl_count(keymaps), notMatch + 1)
    end)

    it("can detect a keymap from a file", function()
        local config_file =
            path:new(vim.fn.stdpath("config") .. sep .. "e2e_config.lua")
        eq(true, config_file:is_file())
        local notMatch = 0
        local keymaps = ts.get_all_keymaps()

        for _, v in ipairs(keymaps) do
            if
                vim.deep_equal(v, {
                    from_file = config_file:absolute(),
                    lhs = "<leader>example",
                    mode = "n",
                    rhs = "<cmd>echo 'Example'<cr>",
                })
            then
                eq(v, {
                    from_file = config_file:absolute(),
                    lhs = "<leader>example",
                    mode = "n",
                    rhs = "<cmd>echo 'Example'<cr>",
                })
            else
                notMatch = notMatch + 1
            end
        end
        print(vim.inspect(keymaps))
        print(config_file:absolute())
        eq(vim.tbl_count(keymaps), notMatch + 1)
    end)

    it("should find a file in stdpath('config')", function()
        eq(true, true)
    end)
end)
