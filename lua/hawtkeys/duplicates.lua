local M = {}
local utils = require("hawtkeys.utils")
local tsSearch = require("hawtkeys.ts")

---@class HawtkeysDuplicatesData
---@field key string
---@field file1 HawtkeysKeyMapData
---@field file2 HawtkeysKeyMapData

---@return HawtkeysDuplicatesData[]
function M.show_duplicates()
    local allKeys = tsSearch.get_all_keymaps()
    local duplicates = utils.find_duplicates(allKeys)
    local resultTable = {}
    for index, data in pairs(duplicates) do
        local object = {
            key = index,
            file1 = data[1].from_file,
            file2 = data[2].from_file,
        }
        table.insert(resultTable, object)
    end
    return resultTable
end

return M
