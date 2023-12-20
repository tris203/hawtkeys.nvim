local M = {}
local Path = require("plenary.path")
local scan = require("plenary.scandir")
local utils = require("hawtkeys.utils")
local config = require("hawtkeys")
local ts = require("nvim-treesitter.compat")
local tsQuery = require("nvim-treesitter.query")

---@alias VimModes 'n' | 'x' | 'v' | 'i'

---@alias WhichKeyMethods 'which_key'
---
---@alias TreeSitterMethods 'dot_index_expression' | 'function_call' | 'expression_list'
---
---@alias SetMethods WhichKeyMethods | TreeSitterMethods

---@class TSKeyMapArgs
---@field modeIndex number | VimModes
---@field lhsIndex number
---@field rhsIndex number
---@field optsIndex number|nil
---@field method TreeSitterMethods
---
---@class WhichKeyMapargs
---@field method WhichKeyMethods

---@type table<string, boolean>
local scannedFiles = {}

---@param params TSKeyMapArgs[]
---@param method SetMethods
---@return string
local function build_args(params, method)
    local args = ""
    for name, opts in pairs(params) do
        if opts.method == method then
            args = args .. ' "' .. name .. '"'
        end
    end
    return args
end

---@param mapDefs TSKeyMapArgs[]
---@return string
local function build_dot_index_expression_query(mapDefs)
    local query = [[
    (function_call
    (dot_index_expression) @exp (#any-of? @exp %s)
        (arguments) @args)
    ]]

    return string.format(query, build_args(mapDefs, "dot_index_expression"))
end

---@param mapDefs TSKeyMapArgs[]
---@return string
local function build_which_key_query(mapDefs)
    local query = [[
    (function_call
        name: (dot_index_expression) @exp (#any-of? @exp %s)
        (arguments) @args)
    ]]
    return string.format(query, build_args(mapDefs, "which_key"))
end

---@param mapDefs TSKeyMapArgs[]
---@return string
local function build_function_call_query(mapDefs)
    local query = [[
    (function_call
        name: (identifier) @exp (#any-of? @exp %s)
        (arguments) @args)
    ]]
    return string.format(query, build_args(mapDefs, "function_call"))
end

---@param node TSNode
---@param indexData TSKeyMapArgs | WhichKeyMapargs
---@param targetData string
---@param fileContent string
---@return string
local function return_field_data(node, indexData, targetData, fileContent)
    ---@param i number
    ---@return number
    local function index_offset(i)
        return (2 * i) - 1
    end
    local success, result = pcall(function()
        if type(indexData[targetData]) == "number" then
            local index = index_offset(indexData[targetData])
            ---@diagnostic disable-next-line: param-type-mismatch
            return vim.treesitter.get_node_text(node:child(index), fileContent)
        else
            return tostring(indexData[targetData])
        end
    end)
    if success then
        result = result:gsub("[\n\r]", "")
        --remove surrounding quotes
        result = result:gsub('^"(.*)"$', "%1")
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

---@param filePath string
---@return table
local function find_maps_in_file(filePath)
    if scannedFiles[filePath] then
        print("Already scanned")
        return {}
    end
    scannedFiles[filePath] = true
    --if not a lua file, return empty table
    if not string.match(filePath, "%.lua$") then
        return {}
    end
    local fileContent = Path:new(filePath):read()
    local parser = vim.treesitter.get_string_parser(fileContent, "lua", {}) -- Get the Lua parser
    local tree = parser:parse()[1]:root()
    local tsKemaps = {}
    -- TODO: This currently doesnt always work, as the options for helper functions are different,
    -- need to use TS to resolve it back to a native keymap
    local dotIndexExpressionQuery = ts.parse_query(
        "lua",
        build_dot_index_expression_query(config.keyMapSet)
    )
    for match in
        tsQuery.iter_prepared_matches(
            dotIndexExpressionQuery,
            tree,
            fileContent,
            0,
            -1
        )
    do
        for type, node in pairs(match) do
            if type == "args" then
                local parent = vim.treesitter.get_node_text(
                    node.node:parent():child(0),
                    fileContent
                )
                local mapDef = config.keyMapSet[parent]
                ---@type string
                local mode = return_field_data(
                    node.node,
                    mapDef,
                    "modeIndex",
                    fileContent
                )

                ---@type string
                local lhs = return_field_data(
                    node.node,
                    mapDef,
                    "lhsIndex",
                    fileContent
                )

                ---@type string
                local rhs = return_field_data(
                    node.node,
                    mapDef,
                    "rhsIndex",
                    fileContent
                )
                local bufLocal = false
                local optsArg = node.node:child(mapDef.optsIndex)
                -- the opts table arg of `vim.keymap.set` is optional, only
                -- do this check if it's present.
                if optsArg then
                    -- check for `buffer = <any>`, since we shouldn't show
                    -- buf-local mappings
                    bufLocal = vim.treesitter
                        .get_node_text(optsArg, fileContent)
                        :gsub("[\n\r]", "")
                        :match("^.*(buffer%s*=.+)%s*[,}].*$") ~= nil
                end

                if not bufLocal then
                    local map = {
                        mode = mode,
                        lhs = lhs,
                        rhs = rhs,
                        from_file = filePath,
                    }

                    if map.mode:match("^%s*{.*},?.*$") then
                        local modes = {}
                        for i, child in
                            vim.iter(node.node:child(1):iter_children())
                                :enumerate()
                        do
                            if i % 2 == 0 then
                                local ty = vim.treesitter
                                    .get_node_text(child, fileContent)
                                    :gsub("['\"]", "")
                                    :gsub("[\n\r]", "")
                                table.insert(modes, ty)
                            end
                        end
                        map.mode = table.concat(modes, ", ")
                    end
                    table.insert(tsKemaps, map)
                end
            end
        end
    end

    local functionCallQuery =
        ts.parse_query("lua", build_function_call_query(config.keyMapSet))

    for match in
        tsQuery.iter_prepared_matches(
            functionCallQuery,
            tree,
            fileContent,
            0,
            -1
        )
    do
        for expCap, node in pairs(match) do
            if expCap == "args" then
                local parent = vim.treesitter.get_node_text(
                    node.node:parent():child(0),
                    fileContent
                )
                local mapDef = config.keyMapSet[parent]
                ---@type string
                local mode = return_field_data(
                    node.node,
                    mapDef,
                    "modeIndex",
                    fileContent
                )

                ---@type string
                local lhs = return_field_data(
                    node.node,
                    mapDef,
                    "lhsIndex",
                    fileContent
                )

                ---@type string
                local rhs = return_field_data(
                    node.node,
                    mapDef,
                    "rhsIndex",
                    fileContent
                )
                local bufLocal = false
                local optsArg = node.node:child(mapDef.optsIndex)
                -- the opts table arg of `vim.keymap.set` is optional, only
                -- do this check if it's present.
                if optsArg then
                    -- check for `buffer = <any>`, since we shouldn't show
                    -- buf-local mappings
                    bufLocal = vim.treesitter
                        .get_node_text(optsArg, fileContent)
                        :gsub("[\n\r]", "")
                        :match("^.*(buffer%s*=.+)%s*[,}].*$") ~= nil
                end

                if not bufLocal then
                    local map = {
                        mode = mode,
                        lhs = lhs,
                        rhs = rhs,
                        from_file = filePath,
                    }

                    if map.mode:match("^%s*{.*},?.*$") then
                        local modes = {}
                        for i, child in
                            vim.iter(node.node:child(1):iter_children())
                                :enumerate()
                        do
                            if i % 2 == 0 then
                                local ty = vim.treesitter
                                    .get_node_text(child, fileContent)
                                    :gsub("['\"]", "")
                                    :gsub("[\n\r]", "")
                                vim.print("type: " .. vim.inspect(ty))
                                table.insert(modes, ty)
                            end
                        end
                        map.mode = table.concat(modes, ", ")
                    end
                    table.insert(tsKemaps, map)
                end
            end
        end
    end

    local whichKeyQuery =
        ts.parse_query("lua", build_which_key_query(config.keyMapSet))

    for match in
        tsQuery.iter_prepared_matches(whichKeyQuery, tree, fileContent, 0, -1)
    do
        for expCap, node in pairs(match) do
            if expCap == "args" then
                local wkLoaded, which_key = pcall(function()
                    return require("which-key.mappings")
                end)
                if not wkLoaded then
                    vim.print(
                        "Which Key Mappings require which-key to be installed"
                    )
                    break
                end
                local strObj =
                    vim.treesitter.get_node_text(node.node, fileContent)
                local ok, tableObj = pcall(function()
                    return loadstring("return " .. strObj)()
                end)
                if not ok then
                    vim.print("Error parsing which-key table")
                    break
                end
                local wkMapping = which_key.parse(tableObj)

                for _, mapping in ipairs(wkMapping) do
                    local map = {
                        mode = mapping.mode,
                        lhs = mapping.prefix,
                        rhs = mapping.cmd,
                        from_file = filePath,
                    }
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

    local vimKeymapsRaw = vim.api.nvim_get_keymap("")
    print("Collecting vim keymaps")
    for _, vimKeymap in ipairs(vimKeymapsRaw) do
        table.insert(vimKeymaps, {
            mode = vimKeymap.mode,
            -- TODO: leader subsitiution as vim keymaps contain raw leader
            lhs = vimKeymap.lhs:gsub(config.leader, "<leader>"),
            rhs = vimKeymap.rhs,
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

M.reset_scanned_files = function()
    scannedFiles = {}
end

M.find_maps_in_file = find_maps_in_file

return M
