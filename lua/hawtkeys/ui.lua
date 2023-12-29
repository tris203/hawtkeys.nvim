local M = {}

local Hawtkeys = require("hawtkeys.score")
local ShowAll = require("hawtkeys.show_all")
local showDuplicates = require("hawtkeys.duplicates")
local utils = require("hawtkeys.utils")

local Namespace = vim.api.nvim_create_namespace("hawtkeys")

local ResultWin
local ResultBuf
local SearchWin
local SearchBuf

local prompt_extmark

local function create_win(enter, opts)
    opts = opts or {}
    local wo = opts.win_options or {}
    opts.win_options = nil

    local buf = vim.api.nvim_create_buf(false, true)
    vim.bo[buf].bufhidden = "wipe"

    local config = vim.tbl_deep_extend("keep", opts, {
        relative = "editor",
        anchor = "NW",
        border = "single",
        noautocmd = true,
        col = (vim.o.columns / 2) - (opts.width / 2),
        row = (vim.o.lines / 2) - (opts.height / 2),
        footer_pos = opts.footer and "center",
        title_pos = opts.title and "center",
    })

    if vim.fn.has("nvim-0.10") == 0 then
        config.footer = nil
        config.footer_pos = nil
    end

    local win = vim.api.nvim_open_win(buf, enter, config)

    vim.api.nvim_create_autocmd("BufLeave", {
        buffer = buf,
        callback = M.hide,
    })

    for opt, val in pairs(wo) do
        vim.api.nvim_set_option_value(opt, val, {
            win = win,
        })
    end

    return win, buf
end

local search_threshold = {
    GREAT = 6,
    GOOD = 3,
    OK = 1,
    BAD = 0,
}

M.search = function(text)
    text = text or ""
    local results = Hawtkeys.ScoreTable(text)

    -- track line count separately because we insert 1-3 lines
    -- per iteration
    local line_count = 0
    for i = 1, #results do
        local data = results[i]
        local lines = {}
        local line = string.format(
            "Key: %s <leader>%s - Hawt Score: %d",
            text,
            data.combo,
            data.score
        )
        table.insert(lines, line)

        line_count = line_count + 1
        local already_mapped = false
        if
            data.already_mapped ~= nil
            and data.already_mapped.rhs ~= nil
            and data.already_mapped.from_file ~= nil
        then
            already_mapped = true
            line_count = line_count + 2
            table.insert(
                lines,
                "Already mapped: " .. tostring(data.already_mapped.rhs)
            )
            table.insert(lines, "In File " .. data.already_mapped.from_file)
        end
        vim.api.nvim_buf_set_lines(
            ResultBuf,
            i == 1 and 0 or -1,
            -1,
            true,
            lines
        )

        if already_mapped then
            local hl = "ErrorMsg"
            vim.api.nvim_buf_add_highlight(
                ResultBuf,
                -1,
                hl,
                line_count - 3,
                0,
                -1
            )
            vim.api.nvim_buf_add_highlight(
                ResultBuf,
                -1,
                hl,
                line_count - 2,
                0,
                -1
            )
            vim.api.nvim_buf_add_highlight(
                ResultBuf,
                -1,
                hl,
                line_count - 1,
                0,
                -1
            )
        else
            local newStr = text:lower()
            local marked = {} -- Keep track of characters already marked
            for idx = 1, #data.combo do
                local char = data.combo:sub(idx, idx)
                local pos = marked[char] or 1 -- Start searching from the last marked position or from the beginning
                pos = newStr:find(char, pos, true) or 0
                if marked[char] and marked[char] == pos then
                    pos = newStr:find(char, pos + 1, true) or 0
                end
                if pos then
                    newStr = newStr:sub(1, pos - 1)
                        .. char
                        .. newStr:sub(pos + 1)
                    local hl_col = pos + 5
                    vim.api.nvim_buf_add_highlight(
                        ResultBuf,
                        -1,
                        "Function",
                        line_count - (already_mapped and 3 or 1),
                        hl_col - 1,
                        hl_col
                    )
                    marked[char] = pos -- Mark this character's position
                end
            end

            local score_offset = #line - #tostring(data.score)
            local score_hl
            if data.score >= search_threshold.GREAT then
                score_hl = "HawtkeysMatchGreat"
            elseif data.score >= search_threshold.GOOD then
                score_hl = "HawtkeysMatchGood"
            elseif data.score >= search_threshold.OK then
                score_hl = "HawtkeysMatchOk"
            else
                score_hl = "HawtkeysMatchBad"
            end
            vim.api.nvim_buf_add_highlight(
                ResultBuf,
                -1,
                score_hl,
                line_count - (already_mapped and 3 or 1),
                score_offset,
                #line
            )
        end
    end
end

M.show = function()
    M.hide()
    local width = 100
    local height = 30
    ResultWin, ResultBuf = create_win(false, {
        width = width,
        height = height,
        -- vertical topleft and topright to look like
        -- these are one window
        border = { "│", "─", "│", "│", "┘", "─", "└", "│" },
        footer = "Suggested Keybindings",
        win_options = {
            number = true,
            relativenumber = false,
            winhl = "Normal:NormalFloatNC",
        },
    })
    SearchWin, SearchBuf = create_win(true, {
        width = width,
        height = 1,
        row = (vim.o.lines / 2) - (height / 2) - 2,
        style = "minimal",
        title = "Enter Command Description",
        border = { "┌", "─", "┐", "│", "┤", "─", "├", "│" },
        win_options = {
            number = false,
            relativenumber = false,
            statuscolumn = "> ",
        },
    })

    local map_opts = { noremap = true, silent = true, buffer = SearchBuf }
    vim.keymap.set({ "n", "i" }, "<esc>", M.hide, map_opts)
    --disallow new lines in searchBuf
    vim.keymap.set("i", "<cr>", "<nop>", map_opts)

    local function update_search_hint(text)
        if text == "" then
            prompt_extmark =
                vim.api.nvim_buf_set_extmark(SearchBuf, Namespace, 0, 0, {
                    id = prompt_extmark,
                    virt_text = { { "Type to search", "Comment" } },
                    virt_text_pos = "overlay",
                })
        else
            prompt_extmark =
                vim.api.nvim_buf_set_extmark(SearchBuf, Namespace, 0, 0, {
                    id = prompt_extmark,
                    virt_text = { { "", "Comment" } },
                    virt_text_pos = "overlay",
                })
        end
    end

    -- subscribe to changed text in searchBuf
    vim.api.nvim_buf_attach(SearchBuf, false, {
        on_lines = vim.schedule_wrap(function()
            local text = vim.api.nvim_buf_get_lines(SearchBuf, 0, 1, false)[1]

            update_search_hint(text)

            if vim.trim(text) == "" or #text < 3 then
                vim.api.nvim_buf_set_lines(ResultBuf, 0, -1, true, {})
                return
            end

            M.search(text)
        end),
    })

    update_search_hint("")
    vim.api.nvim_feedkeys("i", "n", false)
end

M.show_all = function()
    M.hide()
    local width = 100
    local height = 30
    ResultWin, ResultBuf = create_win(true, {
        width = width,
        height = height,
        footer = "Current Keybindings",
    })
    local all = ShowAll.show_all()
    local pattern = "%s (%s) - %s"
    for i, data in ipairs(all) do
        local filename = utils.reduceHome(data.from_file)
        local line = pattern:format(data.lhs, data.mode, filename)

        local offset_mode = #data.lhs + 2
        local offset_file = offset_mode + #data.mode + 2

        local l2 = data.rhs
        if l2 == nil or l2 == "" then
            l2 = "<unknown>"
        end

        -- mapping rhs as extmark so the cursor skips over it
        vim.api.nvim_buf_set_extmark(ResultBuf, Namespace, i - 1, 0, {
            virt_lines = { { { l2, "Function" } } },
        })

        -- mapping rhs as extmark so the cursor skips over it
        vim.api.nvim_buf_set_extmark(ResultBuf, Namespace, i - 1, 0, {
            virt_lines = { { { l2, "Function" } } },
        })

        vim.api.nvim_buf_set_lines(
            ResultBuf,
            i == 1 and 0 or -1,
            -1,
            false,
            { line }
        )
        -- highlight the filename
        vim.api.nvim_buf_add_highlight(
            ResultBuf,
            -1,
            "Comment",
            i - 1,
            offset_file,
            -1
        )
        -- mapping rhs as extmark so the cursor skips over it
        vim.api.nvim_buf_set_extmark(ResultBuf, Namespace, i - 1, 0, {
            virt_lines = { { { l2, "Function" } } },
        })
    end
end

M.show_dupes = function()
    M.hide()
    local width = 100
    local height = 30
    ResultWin, ResultBuf = create_win(true, {
        width = width,
        height = height,
        footer = "Duplicate Keybindings",
    })
    local dupes = showDuplicates.show_duplicates()
    local pattern = "%s : %s"
    for i, data in ipairs(dupes) do
        local filename1 = data.file1:gsub(vim.env.HOME, "~")
        local filename2 = data.file2:gsub(vim.env.HOME, "~")
        local line = pattern:format(filename1, filename2)

        local l2 = data.key
        vim.api.nvim_buf_set_lines(
            ResultBuf,
            i == 1 and 0 or -1,
            -1,
            false,
            { line }
        )
        -- highlight the filename
        vim.api.nvim_buf_add_highlight(ResultBuf, -1, "Comment", i - 1, 0, -1)
        -- mapping rhs as extmark so the cursor skips over it
        vim.api.nvim_buf_set_extmark(ResultBuf, Namespace, i - 1, 0, {
            virt_lines = { { { l2, "Function" } } },
        })
    end
end

M.hide = function()
    if ResultWin and vim.api.nvim_win_is_valid(ResultWin) then
        vim.api.nvim_win_close(ResultWin, true)
    end
    if SearchWin and vim.api.nvim_win_is_valid(SearchWin) then
        vim.api.nvim_win_close(SearchWin, true)
    end
    Hawtkeys.ResetAlreadyUsedKeys()
    SearchWin = nil
    ResultWin = nil
    vim.api.nvim_command("stopinsert")
end

-- This is for testing purposes, since we need to
-- access these variables from outside the module
-- but we don't want to expose them to the user
local state = {
    ResultWin = function()
        return ResultWin
    end,
    ResultBuf = function()
        return ResultBuf
    end,
    SearchWin = function()
        return SearchWin
    end,
    SearchBuf = function()
        return SearchBuf
    end,
    Namespace = function()
        return Namespace
    end,
    prompt_extmark = function()
        return prompt_extmark
    end,
}

setmetatable(M, {
    __index = function(_, k)
        if state[k] then
            return state[k]()
        end
    end,
})

return M
