local M = {}
local utils = require("hawtkeys.utils")
local tsSearch = require("hawtkeys.ts")

---@return table
function M.show_duplicates()
    local allKeys = tsSearch.get_all_keymaps()
    local duplicates = utils.findDuplicates(allKeys)
    local resultTable = {}
    for _, data in ipairs(duplicates) do
        table.insert(resultTable, tostring(data[1]) .. " duplicates found in ")
        table.insert(
            resultTable,
            tostring(data[2][1].from_file)
                .. ":"
                .. tostring(data[2][1].from_file)
        )
    end
    return resultTable
end

return M
