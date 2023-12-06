M = {}
local tsSearch = require("hawtkeys.ts")

function M.show_all()
    local allKeys = tsSearch.get_all_keymaps()
    local resultTable = {}
    for _, data in ipairs(allKeys)
    do
        table.insert(resultTable, tostring(data.lhs) .. " " .. tostring(data.rhs) .. " (" .. tostring(data.mode) .. ") - " .. tostring(data.from_file))
    end
    return resultTable
end

return M
