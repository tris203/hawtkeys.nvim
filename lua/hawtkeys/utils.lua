local M = {}

--- @param table table
--- @param value string
---@return boolean
function M.table_contains(table, value)
    if table == nil then
        return false
    end
    for _, v in ipairs(table) do
        if v == value then
            return true
        end
    end
    return false
end

---@param a table
---@param b table
---@return boolean
function M.score_sort(a, b)
    return a.score > b.score
end

---@param scores_table table
---@return table
function M.top5(scores_table)
    local top_list = {}
    for i = 1, 5 do
        table.insert(top_list, scores_table[i])
    end
    return top_list
end

---@param t1 HawtkeysKeyMapData[]
---@param t2 HawtkeysKeyMapData[]
---@return HawtkeysKeyMapData[]
function M.merge_tables(t1, t2)
    local t3 = {}

    --[[ for _, v in pairs(t1) do
        table.insert(t3, v)
    end

    for _, v in pairs(t2) do
        table.insert(t3, v)
    end
]]

    for _, v in pairs(t1) do
        table.insert(t3, v)
    end

    for _, v in pairs(t2) do
        local found = false
        for _, v2 in pairs(t3) do
            if
                v2.lhs:lower() == v.lhs:lower()
                and v.from_file == "Vim Defaults"
            then
                found = true
            end
        end
        if not found then
            table.insert(t3, v)
        end
    end
    return t3
end

---Returns true if a and b contain any of the same values
---@param a string | string[]
---@param b string | string[]
---@return boolean
local function match_modes(a, b)
    if type(a) == "string" then
        a = { a }
    end
    if type(b) == "string" then
        b = { b }
    end
    -- note: there will only ever be a few modes in each table. this is fine.
    for _, v in ipairs(a) do
        for _, v2 in ipairs(b) do
            if v == v2 then
                return true
            end
        end
    end
    return false
end

---@param keymaps HawtkeysKeyMapData[]
---@return { [string]: HawtkeysKeyMapData[] }
function M.find_duplicates(keymaps)
    local duplicates = {}
    local seen = {}
    for _, v in pairs(keymaps) do
        for _, v2 in pairs(keymaps) do
            if
                v.lhs == v2.lhs
                and v.rhs ~= v2.rhs
                and match_modes(v.mode or "n", v2.mode or "n")
            then
                if not seen[v.lhs] then
                    seen[v.lhs] = {}
                end
                if duplicates[v.lhs] == nil then
                    duplicates[v.lhs] = { v, v2 }
                    seen[v.lhs][v] = true
                    seen[v.lhs][v2] = true
                elseif seen[v.lhs] == nil or seen[v.lhs][v2] == nil then
                    table.insert(duplicates[v.lhs], v2)
                    seen[v.lhs][v2] = true
                end
            end
        end
    end

    return duplicates
end

---@param path string
---@return string
function M.reduceHome(path)
    local reduced = path:gsub(vim.env.HOME, "~")
    return reduced
end

return M
