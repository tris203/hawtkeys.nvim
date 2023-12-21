local M = {}
local utils = require("hawtkeys.utils")
local tsSearch = require("hawtkeys.ts")

---@return table
function M.show_duplicates()
    local allKeys = tsSearch.get_all_keymaps()
    local duplicates = utils.find_duplicates(allKeys)
    local resultTable = {}
    for index, data in ipairs(duplicates) do
        table.insert(resultTable, tostring(index) .. " duplicates found in ")
        table.insert(
            resultTable,
            tostring(data[1][1].from_file)
                .. ":"
                .. tostring(data[2][1].from_file)
        )
    end
    return resultTable
end

return M
