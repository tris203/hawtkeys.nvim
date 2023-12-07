M = {}

--- @param table table
--- @param value string
---@return boolean
function M.tableContains(table, value)
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
function M.Score_sort(a, b)
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

---@param t1 table
---@param t2 table
---@return table
function M.mergeTables(t1, t2)
    local t3 = {}

    for _, v in pairs(t1) do
        table.insert(t3, v)
    end

    for _, v in pairs(t2) do
        table.insert(t3, v)
    end

    --[[ for _, subtable in pairs(t2) do
        for _, v in pairs(t1) do
            if v.lhs == subtable.lhs then
                print("skipping insert")
                goto continue
            end
            table.insert(t3, subtable)
            ::continue::
        end
    end ]]
    -- TODO: Merge better, so that t1 is prioritised

    return t3
end

return M
