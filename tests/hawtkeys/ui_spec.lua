---@diagnostic disable-next-line: undefined-field
local eq = assert.are.same

---TODO: add search functionality tests (willothy)

describe("ui", function()
    local SearchBuf, SearchWin, ResultBuf, ResultWin, Namespace, prompt_extmark

    before_each(function()
        require("plenary.reload").reload_module("hawtkeys")
        vim.cmd([[bufdo! bwipeout]])
        require("hawtkeys").setup({})
    end)

    describe("search", function()
        before_each(function()
            require("plenary.reload").reload_module("hawtkeys")
            vim.cmd([[bufdo! bwipeout]])
            require("hawtkeys").setup({})
            vim.cmd([[lua require("hawtkeys.ui").show()]])
            local ui = require("hawtkeys.ui")
            SearchBuf, SearchWin, ResultBuf, ResultWin, Namespace, prompt_extmark =
                ui.SearchBuf,
                ui.SearchWin,
                ui.ResultBuf,
                ui.ResultWin,
                ui.Namespace,
                ui.prompt_extmark
        end)

        it("should show the search UI", function()
            assert(vim.api.nvim_buf_is_valid(SearchBuf))
            assert(vim.api.nvim_win_is_valid(SearchWin))

            assert(vim.api.nvim_buf_is_valid(ResultBuf))
            assert(vim.api.nvim_win_is_valid(ResultWin))

            eq(SearchBuf, vim.api.nvim_get_current_buf())
            eq(SearchWin, vim.api.nvim_get_current_win())

            local win_config = vim.api.nvim_win_get_config(SearchWin)
            eq("editor", win_config.relative)
        end)
        --TODO: This doesnt work since removing the dependency on mini.test
        --[[ it("starts in insert mode", function()
            assert(vim.api.nvim_buf_is_valid(SearchBuf))
            assert(vim.api.nvim_win_is_valid(SearchWin))

            eq(vim.api.nvim_get_current_win(), SearchWin)
            eq("i", vim.api.nvim_get_mode().mode)
        end)
]]
        it("should show the hint extmark", function()
            assert(SearchBuf)
            assert(prompt_extmark)
            assert(Namespace)
            local extmark_info = vim.api.nvim_buf_get_extmark_by_id(
                SearchBuf,
                Namespace,
                prompt_extmark,
                { details = true, hl_name = true }
            )
            eq(extmark_info[3].virt_text_pos, "overlay")
            eq(extmark_info[3].virt_text, { { "Type to search", "Comment" } })
        end)
    end)

    describe("all", function()
        before_each(function()
            require("plenary.reload").reload_module("hawtkeys")
            vim.cmd([[bufdo! bwipeout]])
            require("hawtkeys").setup({})
            vim.cmd([[lua require("hawtkeys.ui").show_all()]])
            local ui = require("hawtkeys.ui")
            ResultBuf, ResultWin, Namespace =
                ui.ResultBuf, ui.ResultWin, ui.Namespace
        end)

        it("should show the all UI", function()
            print(vim.inspect(ResultBuf))
            assert(vim.api.nvim_buf_is_valid(ResultBuf))
            assert(vim.api.nvim_win_is_valid(ResultWin))

            eq(vim.api.nvim_get_current_buf(), ResultBuf)
            eq(vim.api.nvim_get_current_win(), ResultWin)

            local win_config = vim.api.nvim_win_get_config(ResultWin)
            eq(win_config.relative, "editor")
        end)
    end)

    describe("dupes", function()
        before_each(function()
            vim.cmd([[lua require("hawtkeys.ui").show_dupes()]])
            local ui = require("hawtkeys.ui")
            ResultBuf, ResultWin, Namespace =
                ui.ResultBuf, ui.ResultWin, ui.Namespace
        end)

        it("should show the duplicates UI", function()
            assert(vim.api.nvim_buf_is_valid(ResultBuf))
            assert(vim.api.nvim_win_is_valid(ResultWin))

            eq(vim.api.nvim_get_current_buf(), ResultBuf)
            eq(vim.api.nvim_get_current_win(), ResultWin)

            local win_config = vim.api.nvim_win_get_config(ResultWin)
            eq(win_config.relative, "editor")
        end)
    end)
end)
