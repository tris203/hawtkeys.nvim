local M = {}
local Hawtkeys = require("hawtkeys.score")
local ShowAll = require("hawtkeys.show_all")
local showDuplicates = require("hawtkeys.duplicates")

local ResultWin
local ResultBuf
local SearchWin

local function create_win(enter, opts)
    opts = opts or {}
    local wo = opts.win_options or {}
    opts.win_options = nil

    local buf = vim.api.nvim_create_buf(false, true)

    local win = vim.api.nvim_open_win(
        buf,
        enter,
        vim.tbl_deep_extend("keep", opts, {
            relative = "editor",
            anchor = "NW",
            border = "single",
            noautocmd = true,
            col = (vim.o.columns / 2) - (opts.width / 2),
            row = (vim.o.lines / 2) - (opts.height / 2),
            footer_pos = opts.footer and "center",
            title_pos = opts.title and "center",
        })
    )

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

M.search = function(text)
    local returnText = Hawtkeys.ScoreTable(text)
    vim.api.nvim_buf_set_lines(ResultBuf, 0, -1, false, returnText)

    --loop lines and hilight if already mapped:
    for i, line in ipairs(returnText) do
        if string.match(line, "^Already mapped:.*") then
            vim.api.nvim_buf_add_highlight(
                ResultBuf,
                -1,
                "ErrorMsg",
                i - 1,
                0,
                -1
            )
            vim.api.nvim_buf_add_highlight(ResultBuf, -1, "ErrorMsg", i, 0, -1)
            vim.api.nvim_buf_add_highlight(
                ResultBuf,
                -1,
                "ErrorMsg",
                i - 2,
                0,
                -1
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
        zindex = 101,
        footer = "Suggested Keybindings",
        win_options = {
            number = true,
            relativenumber = false,
        },
    })
    local searchBuf
    SearchWin, searchBuf = create_win(true, {
        width = width,
        height = 1,
        row = (vim.o.lines / 2) - (height / 2) - 2,
        style = "minimal",
        title = "Enter Command Description",
        win_options = {
            number = false,
            relativenumber = false,
            statuscolumn = "> ",
        },
    })

    local map_opts = { noremap = true, silent = true, buffer = searchBuf }
    vim.keymap.set({ "n", "i" }, "<esc>", M.hide, map_opts)
    --disallow new lines in searchBuf
    vim.keymap.set("i", "<cr>", "<nop>", map_opts)

    -- subscribe to changed text in searchBuf
    vim.api.nvim_buf_attach(searchBuf, false, {
        on_lines = vim.schedule_wrap(function()
            M.search(vim.api.nvim_buf_get_lines(searchBuf, 0, 1, false)[1])
        end),
    })

    vim.api.nvim_command("startinsert")
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
    vim.api.nvim_buf_set_lines(ResultBuf, 0, -1, false, ShowAll.show_all())
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
    vim.api.nvim_buf_set_lines(
        ResultBuf,
        0,
        -1,
        false,
        showDuplicates.show_duplicates()
    )
end

M.hide = function()
    if ResultWin and vim.api.nvim_win_is_valid(ResultWin) then
        vim.api.nvim_win_close(ResultWin, true)
    end
    if SearchWin and vim.api.nvim_win_is_valid(SearchWin) then
        vim.api.nvim_win_close(SearchWin, true)
    end
    SearchWin = nil
    ResultWin = nil
    vim.api.nvim_command("stopinsert")
end

return M
