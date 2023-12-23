---@diagnostic disable-next-line: undefined-field
local eq = assert.are.same

local MiniTest = require("mini.test")

---TODO: add search functionality tests (willothy)

describe("ui", function()
    local child = MiniTest.new_child_neovim()
    local SearchBuf, SearchWin, ResultBuf, ResultWin, Namespace, prompt_extmark

    before_each(function()
        child.restart({ "-u", "tests/minimal_init.lua" })
        child.lua([[require("hawtkeys").setup({})]])
    end)

    describe("search", function()
        before_each(function()
            child.lua([[require("hawtkeys.ui").show()]])
            SearchBuf, SearchWin, ResultBuf, ResultWin, Namespace, prompt_extmark =
                unpack(child.lua([[
                local ui = require("hawtkeys.ui")
                return {
                    ui.SearchBuf,
                    ui.SearchWin,
                    ui.ResultBuf,
                    ui.ResultWin,
                    ui.Namespace,
                    ui.prompt_extmark
                }
            ]]))
        end)

        it("should show the search UI", function()
            assert(child.api.nvim_buf_is_valid(SearchBuf))
            assert(child.api.nvim_win_is_valid(SearchWin))

            assert(child.api.nvim_buf_is_valid(ResultBuf))
            assert(child.api.nvim_win_is_valid(ResultWin))

            eq(SearchBuf, child.api.nvim_get_current_buf())
            eq(SearchWin, child.api.nvim_get_current_win())

            local win_config = child.api.nvim_win_get_config(SearchWin)
            eq("editor", win_config.relative)
        end)

        it("starts in insert mode", function()
            assert(child.api.nvim_buf_is_valid(SearchBuf))
            assert(child.api.nvim_win_is_valid(SearchWin))

            eq(child.api.nvim_get_current_win(), SearchWin)
            eq("i", child.api.nvim_get_mode().mode)
        end)

        it("should show the hint extmark", function()
            assert(SearchBuf)
            assert(prompt_extmark)
            assert(Namespace)
            local extmark_info = child.api.nvim_buf_get_extmark_by_id(
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
            child.lua([[require("hawtkeys.ui").show_all()]])
            ResultBuf, ResultWin, Namespace = unpack(child.lua([[
                local ui = require("hawtkeys.ui")
                return {
                    ui.ResultBuf,
                    ui.ResultWin,
                    ui.Namespace,
                }
            ]]))
        end)

        it("should show the all UI", function()
            assert(child.api.nvim_buf_is_valid(ResultBuf))
            assert(child.api.nvim_win_is_valid(ResultWin))

            eq(child.api.nvim_get_current_buf(), ResultBuf)
            eq(child.api.nvim_get_current_win(), ResultWin)

            local win_config = child.api.nvim_win_get_config(ResultWin)
            eq(win_config.relative, "editor")
        end)
    end)

    describe("dupes", function()
        before_each(function()
            child.lua([[require("hawtkeys.ui").show_dupes()]])
            ResultBuf, ResultWin, Namespace = unpack(child.lua([[
                local ui = require("hawtkeys.ui")
                return {
                    ui.ResultBuf,
                    ui.ResultWin,
                    ui.Namespace,
                }
            ]]))
        end)

        it("should show the duplicates UI", function()
            assert(child.api.nvim_buf_is_valid(ResultBuf))
            assert(child.api.nvim_win_is_valid(ResultWin))

            eq(child.api.nvim_get_current_buf(), ResultBuf)
            eq(child.api.nvim_get_current_win(), ResultWin)

            local win_config = child.api.nvim_win_get_config(ResultWin)
            eq(win_config.relative, "editor")
        end)
    end)
end)
