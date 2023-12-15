local M = {}
local Path = require('plenary.path')
local scan = require('plenary.scandir')
local utils = require('hawtkeys.utils')
local config = require('hawtkeys')
local ts = require("nvim-treesitter.compat")
local ts_query = require("nvim-treesitter.query")

local return_keymaps = {}
---@param dir string
---@return table
local function find_files(dir)
    print('Scanning dir' .. dir)
    local dirScan = dir or vim.fn.stdpath("config")
    local files = scan.scan_dir(dirScan, { hidden = true })
    return files
end

---@param file_path string
---@return table
local function find_maps_in_file(file_path)
    print("Scanning files " .. file_path)
    --if not a lua file, return empty table
    if not string.match(file_path, "%.lua$") then
        return {}
    end
    local file_content = Path:new(file_path):read()
    local parser       = vim.treesitter.get_string_parser(file_content, 'lua', {}) -- Get the Lua parser
    local tree         = parser:parse()[1]:root()
    local ts_keymaps   = {}
    -- TODO: This currently doesnt always work, as the options for helper functions are different,
    -- need to use TS to resolve it back to a native keymap function
    local query        = ts.parse_query("lua", [[
                                                            (function_call
                                                            name: (dot_index_expression) @exp (#any-of? @exp "vim.api.nvim_set_keymap" "vim.keymap.set")
                                                            (arguments) @args
                                                            )
]])
    for match in ts_query.iter_prepared_matches(query, tree, file_content, 0, -1) do
        for type, node in pairs(match) do
            if type == "args" then
                table.insert(ts_keymaps, {
                    mode = vim.treesitter.get_node_text(node.node:child(1), file_content):gsub("^%s*(['\"])(.*)%1%s*$",
                        "%2"):gsub("[\n\r]", ""),
                    lhs = vim.treesitter.get_node_text(node.node:child(3), file_content):gsub("^%s*(['\"])(.*)%1%s*$",
                        "%2"):gsub("[\n\r]", ""),
                    rhs = vim.treesitter.get_node_text(node.node:child(5), file_content):gsub("^%s*(['\"])(.*)%1%s*$",
                        "%2"):gsub("[\n\r]", ""),
                    from_file = file_path,
                })
            end
        end
    end

    return ts_keymaps
end

---@return table
local function get_keymaps_from_vim()
    local vim_keymaps = {}

    local vim_keymaps_raw = vim.api.nvim_get_keymap('n')
    print("Collecting vim keymaps")
    for _, vim_keymap in ipairs(vim_keymaps_raw) do
        table.insert(vim_keymaps, {
            mode = vim_keymap.mode,
            -- TODO: leader subsitiution as vim keymaps contain raw leader
            lhs = vim_keymap.lhs:gsub(config.leader, "<leader>"),
            rhs = vim_keymap.rhs,
            from_file = 'Vim Defaults'
        })
    end
    return vim_keymaps
end

---@return string[]
local function getRTP()
    return vim.api.nvim_list_runtime_paths()
end

---@return table
function M.get_all_keymaps()
    if next(return_keymaps) ~= nil then
        return return_keymaps
    end
    local keymaps = {}
    local paths = getRTP()
    for _, path in ipairs(paths) do
        if string.match(path, "%.config") then
            local files = find_files(path)
            for _, file in ipairs(files) do
                local file_keymaps = find_maps_in_file(file)
                for _, keymap in ipairs(file_keymaps) do
                    table.insert(keymaps, keymap)
                end
            end
        end
    end
    local vim_keymaps = get_keymaps_from_vim()
    return_keymaps = utils.mergeTables(keymaps, vim_keymaps)
    return return_keymaps
end

return M
