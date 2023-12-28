local M = {}
local Path = require("plenary.path")
local scan = require("plenary.scandir")
local utils = require("hawtkeys.utils")
local hawtkeys = require("hawtkeys")
local ts = require("nvim-treesitter.compat")
local tsQuery = require("nvim-treesitter.query")

---@alias VimModes 'n' | 'x' | 'v' | 'i'

---@class HawtkeysKeyMapData
---@field lhs string
---@field rhs string
---@field mode VimModes
---@field from_file string

---@alias WhichKeyMethods 'which_key'

---@alias LazyMethods 'lazy'

---@alias TreeSitterMethods 'dot_index_expression' | 'function_call'

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

---@class LazyKeyMapArgs
---@field method LazyMethods

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

---@param mapDefs WhichKeyMapargs[]
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
---@param indexData TSKeyMapArgs
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
---@return string[]
local function find_files(dir)
    -- print("Scanning dir" .. dir)
    local dirScan = dir or vim.fn.stdpath("config")
    local files = scan.scan_dir(dirScan, { hidden = true })
    return files
end

---@param filePath string
---@return HawtkeysKeyMapData[]
local function find_maps_in_file(filePath)
    if scannedFiles[filePath] then
        -- already scanned
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
    local tsKeymaps = {}
    -- TODO: This currently doesnt always work, as the options for helper functions are different,
    -- need to use TS to resolve it back to a native keymap
    local dotIndexExpressionQuery = ts.parse_query(
        "lua",
        build_dot_index_expression_query(hawtkeys.config.keyMapSet)
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
                --@type TSKeyMapArgs
                local mapDef = hawtkeys.config.keyMapSet[parent] --[[@as TSKeyMapArgs]]
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
                    ---@type HawtkeysKeyMapData
                    local map = {
                        mode = mode,
                        lhs = lhs,
                        rhs = rhs,
                        from_file = filePath,
                    }

                    if map.mode:match("^%s*{.*},?.*$") then
                        local modes = {}
                        local i = 1
                        for child in node.node:child(1):iter_children() do
                            if i % 2 == 0 then
                                local ty = vim.treesitter
                                    .get_node_text(child, fileContent)
                                    :gsub("['\"]", "")
                                    :gsub("[\n\r]", "")
                                table.insert(modes, ty)
                            end
                            i = i + 1
                        end
                        map.mode = modes
                    end
                    table.insert(tsKeymaps, map)
                end
            end
        end
    end

    local functionCallQuery = ts.parse_query(
        "lua",
        build_function_call_query(hawtkeys.config.keyMapSet)
    )

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
                local mapDef = hawtkeys.config.keyMapSet[parent] --[[@as TSKeyMapArgs]]
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
                    ---@type HawtkeysKeyMapData
                    local map = {
                        mode = mode,
                        lhs = lhs,
                        rhs = rhs,
                        from_file = filePath,
                    }

                    if map.mode:match("^%s*{.*},?.*$") then
                        local modes = {}
                        local i = 1
                        for child in node.node:child(1):iter_children() do
                            if i % 2 == 0 then
                                local ty = vim.treesitter
                                    .get_node_text(child, fileContent)
                                    :gsub("['\"]", "")
                                    :gsub("[\n\r]", "")
                                -- vim.print("type: " .. vim.inspect(ty))
                                table.insert(modes, ty)
                            end
                            i = i + 1
                        end
                        map.mode = modes
                    end
                    table.insert(tsKeymaps, map)
                end
            end
        end
    end

    local whichKeyQuery =
        ts.parse_query("lua", build_which_key_query(hawtkeys.config.keyMapSet))

    for match in
        tsQuery.iter_prepared_matches(whichKeyQuery, tree, fileContent, 0, -1)
    do
        for expCap, node in pairs(match) do
            if expCap == "args" then
                local wkLoaded, which_key = pcall(function()
                    return require("which-key.mappings")
                end)
                if not wkLoaded then
                    vim.notify_once(
                        "Which Key Mappings require which-key to be installed",
                        vim.log.levels.WARN
                    )
                    break
                end
                local strObj =
                    vim.treesitter.get_node_text(node.node, fileContent)
                local ok, tableObj = pcall(function()
                    return loadstring("return " .. strObj)()
                end)
                if not ok then
                    vim.notify_once(
                        "Error parsing which-key table",
                        vim.log.levels.ERROR
                    )
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
                    table.insert(tsKeymaps, map)
                end
            end
        end
    end

    return tsKeymaps
end

---@return HawtkeysKeyMapData[]
local function get_keymaps_from_lazy()
    local lazyKeyMaps = {}
    for _, args in pairs(hawtkeys.config.keyMapSet) do
        if args.method == "lazy" then
            local ok, lazy = pcall(function()
                return require("lazy").plugins()
            end)
            if not ok then
                vim.notify_once(
                    "Lazy Loading requires Lazy",
                    vim.log.levels.INFO
                )
                break
            end
            for _, v in ipairs(lazy) do
                if v and v._ and v._.handlers and v._.handlers.keys then
                    for _, key in pairs(v._.handlers.keys) do
                        if type(key.rhs) == "table" then
                            key.rhs = tostring(key.rhs)
                        elseif type(key.rhs) == "function" then
                            local debugInfo =
                                debug.getinfo(key.rhs --[[@as fun()]], "S")
                            key.rhs = utils.reduceHome(debugInfo.short_src)
                                .. ":"
                                .. debugInfo.linedefined
                        end
                        local map = {
                            lhs = key.lhs,
                            rhs = tostring(key.rhs),
                            mode = key.mode,
                            from_file = "Lazy Init:" .. tostring(v[1]),
                        }
                        table.insert(lazyKeyMaps, map)
                    end
                end
            end
        end
    end
    return lazyKeyMaps
end

---@return HawtkeysKeyMapData[]
local function get_keymaps_from_vim()
    local vimKeymaps = {}

    local vimKeymapsRaw = vim.api.nvim_get_keymap("")
    for _, vimKeymap in ipairs(vimKeymapsRaw) do
        local count = vim.tbl_count(hawtkeys.config.lhsBlacklist)
        for _, blacklist in ipairs(hawtkeys.config.lhsBlacklist) do
            if not vimKeymap.lhs:lower():match(blacklist) then
                count = count - 1
                if count == 0 then
                    local rhs = vimKeymap.rhs
                    if rhs == nil or rhs == "" then
                        rhs = vimKeymap.desc
                    end
                    table.insert(vimKeymaps, {
                        mode = vimKeymap.mode,
                        -- TODO: leader subsitiution as vim keymaps contain raw leader
                        lhs = vimKeymap.lhs:gsub(
                            hawtkeys.config.leader,
                            "<leader>"
                        ),
                        rhs = rhs,
                        from_file = "Vim Defaults",
                    })
                end
            end
        end
    end
    return vimKeymaps
end

---@return string[]
local function get_runtime_path()
    return vim.api.nvim_list_runtime_paths()
end

---@return HawtkeysKeyMapData[]
function M.get_all_keymaps()
    local returnKeymaps
    --[[ if next(returnKeymaps) ~= nil then
        return returnKeymaps
    end ]]
    ---@type HawtkeysKeyMapData[]
    local keymaps = {}

    if M._testing then
        local files =
            find_files(vim.loop.cwd() .. "/tests/hawtkeys/example_configs")
        for _, file in ipairs(files) do
            local file_keymaps = find_maps_in_file(file)
            for _, keymap in ipairs(file_keymaps) do
                table.insert(keymaps, keymap)
            end
        end
    else
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
    end

    if
        hawtkeys.config.keyMapSet.lazy
        and hawtkeys.config.keyMapSet.lazy.method == "lazy"
    then
        local lazyKeyMaps = get_keymaps_from_lazy()
        for _, keymap in ipairs(lazyKeyMaps) do
            table.insert(keymaps, keymap)
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
M.get_keymaps_from_vim = get_keymaps_from_vim
M.get_keymaps_from_lazy = get_keymaps_from_lazy

return M
