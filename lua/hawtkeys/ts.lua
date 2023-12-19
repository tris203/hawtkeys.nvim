local M = {}
local Path = require("plenary.path")
local scan = require("plenary.scandir")
local utils = require("hawtkeys.utils")
local config = require("hawtkeys")
local ts = require("nvim-treesitter.compat")
local tsQuery = require("nvim-treesitter.query")


---@alias vimModes 'n' | 'x' | 'v' | 'i'

---@alias setMethods 'dot_index_expression' | 'index_expression' | 'function_call'

---@class keyMapArgs
---@field modeIndex number | vimModes
---@field lhsIndex number
---@field rhsIndex number
---@field optsIndex number|nil
---@field method setMethods


---@type { [string] : keyMapArgs }
local keyMapSet = {
    ["vim.keymap.set"] = { modeIndex = 1, lhsIndex = 2, rhsIndex = 3, optsIndex = 4, method = "dot_index_expression" },          --method 1
    ["vim.api.nvim_set_keymap"] = { modeIndex = 1, lhsIndex = 2, rhsIndex = 3, optsIndex = 4, method = 'dot_index_expression' }, --method 2
    ["normalMap"] = { modeIndex = 'n', lhsIndex = 1, rhsIndex = 2, method = 'function_call' },                                   --method 3
    ["kmap.nvim_set_keymap"] = { modeIndex = 1, lhsIndex = 2, rhsIndex = 3, method = 'dot_index_expression' },                   --method 4
    ["nmap"] = { modeIndex = 'n', lhsIndex = 1, rhsIndex = 2, method = 'function_call' }                                           -- method 5
}

---@type table<string, boolean>
local scannedFiles = {}

---@param mapDefs keyMapArgs[]
---@return string
local function build_dot_index_expression_query(mapDefs)
    local query = "(function_call"
    query = query .. "\nname: (dot_index_expression) @exp (#any-of? @exp "
    for name, opts in pairs(mapDefs) do
        if opts.method == "dot_index_expression" then
            query = query .. ' "' .. name .. '"'
        end
    end
    query = query .. ")"
    query = query .. "\n(arguments) @args)"
    return query
end

---@param mapDefs keyMapArgs[]
---@return string
local function build_function_call_query(mapDefs)
    local query = "(function_call"
    query = query .. "\nname: (identifier) @exp (#any-of? @exp "
    for name, opts in pairs(mapDefs) do
        if opts.method == "function_call" then
            query = query .. ' "' .. name .. '"'
        end
    end
    query = query .. ")"
    query = query .. "\n(arguments) @args)"
    return query
end

---@param node TSNode
---@param indexData keyMapArgs
---@param targetData string
---@param file_content string
---@return string
local function return_field_data(node, indexData, targetData, file_content)
    ---@param i number
    ---@return number
    local function index_offset(i)
        return (2 * i) - 1
    end
    local success, result = pcall(function()
        if type(indexData[targetData]) == "number" then
            local index = index_offset(indexData[targetData])
            ---@diagnostic disable-next-line: param-type-mismatch
            return vim.treesitter.get_node_text(node:child(index), file_content)
        else
            return tostring(indexData[targetData])
        end
    end)
    if success then
        result = result:gsub("[\n\r]", "")
        --remove surrounding quotes
        result = result:gsub("^\"(.*)\"$", "%1")
        --remove single quotes
        result = result:gsub("^'(.*)'$", "%1")
        return result
    else
        return "error"
    end
end

---@param dir string
---@return table
local function find_files(dir)
    print("Scanning dir" .. dir)
    local dirScan = dir or vim.fn.stdpath("config")
    local files = scan.scan_dir(dirScan, { hidden = true })
    return files
end


---@param file_path string
---@return table
local function find_maps_in_file(file_path)
    if scannedFiles[file_path] then
        print("Already scanned")
        return {}
    end
    scannedFiles[file_path] = true
    --if not a lua file, return empty table
    if not string.match(file_path, "%.lua$") then
        return {}
    end
    local file_content = Path:new(file_path):read()
    local parser = vim.treesitter.get_string_parser(file_content, "lua", {}) -- Get the Lua parser
    local tree = parser:parse()[1]:root()
    local tsKemaps = {}
    -- TODO: This currently doesnt always work, as the options for helper functions are different,
    -- need to use TS to resolve it back to a native keymap
    local dot_index_expression_query = ts.parse_query(
        "lua",
        build_dot_index_expression_query(keyMapSet)
    )
    for match in tsQuery.iter_prepared_matches(dot_index_expression_query, tree, file_content, 0, -1) do
        for type, node in pairs(match) do
            if type == "args" then
                local parent = vim.treesitter.get_node_text(node.node:parent():child(0), file_content)
                local mapDef = keyMapSet[parent]
                ---@type string
                local mode = return_field_data(node.node, mapDef, "modeIndex", file_content)

                ---@type string
                local lhs = return_field_data(node.node, mapDef, "lhsIndex", file_content)

                ---@type string
                local rhs = return_field_data(node.node, mapDef, "rhsIndex", file_content)
                local buf_local = false
                local opts_arg = node.node:child(mapDef.optsIndex)
                -- the opts table arg of `vim.keymap.set` is optional, only
                -- do this check if it's present.
                if opts_arg then
                    -- check for `buffer = <any>`, since we shouldn't show
                    -- buf-local mappings
                    buf_local = vim.treesitter
                        .get_node_text(opts_arg, file_content)
                        :gsub("[\n\r]", "")
                        :match("^.*(buffer%s*=.+)%s*[,}].*$") ~= nil
                end

                if not buf_local then
                    local map =  {
                        mode = mode,
                        lhs = lhs,
                        rhs = rhs,
                        from_file = file_path,
                    }

                    if map.mode:match("^%s*{.*},?.*$") then
                        local mode = {}
                        for i, child in
                            vim.iter(node.node:child(1):iter_children())
                                :enumerate()
                        do
                            if i % 2 == 0 then
                                local ty = vim.treesitter
                                    .get_node_text(child, file_content)
                                    :gsub("['\"]", "")
                                    :gsub("[\n\r]", "")
                                vim.print("type: " .. vim.inspect(ty))
                                table.insert(mode, ty)
                            end
                        end
                        map.mode = table.concat(mode, ", ")
                    end
                    table.insert(tsKemaps, map)
                end
            end
        end
    end

    local function_call_query = ts.parse_query(
        "lua",
        build_function_call_query(keyMapSet)
    )

    for match in tsQuery.iter_prepared_matches(function_call_query, tree, file_content, 0, -1) do
        for expCap, node in pairs(match) do
            if expCap == "args" then
                local parent = vim.treesitter.get_node_text(node.node:parent():child(0), file_content)
                local mapDef = keyMapSet[parent]
                ---@type string
                local mode = return_field_data(node.node, mapDef, "modeIndex", file_content)

                ---@type string
                local lhs = return_field_data(node.node, mapDef, "lhsIndex", file_content)

                ---@type string
                local rhs = return_field_data(node.node, mapDef, "rhsIndex", file_content)
                local buf_local = false
                local opts_arg = node.node:child(mapDef.optsIndex)
                -- the opts table arg of `vim.keymap.set` is optional, only
                -- do this check if it's present.
                if opts_arg then
                    -- check for `buffer = <any>`, since we shouldn't show
                    -- buf-local mappings
                    buf_local = vim.treesitter
                        .get_node_text(opts_arg, file_content)
                        :gsub("[\n\r]", "")
                        :match("^.*(buffer%s*=.+)%s*[,}].*$") ~= nil
                end

                if not buf_local then
                    local map = {
                        mode = mode,
                        lhs = lhs,
                        rhs = rhs,
                        from_file = file_path,
                    }

                    if map.mode:match("^%s*{.*},?.*$") then
                        local mode = {}
                        for i, child in
                            vim.iter(node.node:child(1):iter_children())
                                :enumerate()
                        do
                            if i % 2 == 0 then
                                local ty = vim.treesitter
                                    .get_node_text(child, file_content)
                                    :gsub("['\"]", "")
                                    :gsub("[\n\r]", "")
                                vim.print("type: " .. vim.inspect(ty))
                                table.insert(mode, ty)
                            end
                        end
                        map.mode = table.concat(mode, ", ")
                    end
                    table.insert(tsKemaps, map)
                end
            end
        end
    end

    return tsKemaps
end

---@return table
local function get_keymaps_from_vim()
    local vimKeymaps = {}

    local vim_keymaps_raw = vim.api.nvim_get_keymap("")
    print("Collecting vim keymaps")
    for _, vim_keymap in ipairs(vim_keymaps_raw) do
        table.insert(vimKeymaps, {
            mode = vim_keymap.mode,
            -- TODO: leader subsitiution as vim keymaps contain raw leader
            lhs = vim_keymap.lhs:gsub(config.leader, "<leader>"),
            rhs = vim_keymap.rhs,
            from_file = "Vim Defaults",
        })
    end
    return vimKeymaps
end

---@return string[]
local function get_runtime_path()
    return vim.api.nvim_list_runtime_paths()
end

---@return table
function M.get_all_keymaps()
    local returnKeymaps
    --[[ if next(returnKeymaps) ~= nil then
        return returnKeymaps
    end ]]
    local keymaps = {}
    local paths = get_runtime_path()
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
    local vimKeymaps = get_keymaps_from_vim()
    returnKeymaps = utils.merge_tables(keymaps, vimKeymaps)
    scannedFiles = {}
    return returnKeymaps
end

M.find_maps_in_file = find_maps_in_file

return M
