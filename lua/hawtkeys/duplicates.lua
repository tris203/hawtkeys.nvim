local M = {}
local utils = require("hawtkeys.utils")
local tsSearch = require("hawtkeys.ts")

---@class HawtkeysDuplicatesData
---@field key string
---@field map1 HawtkeysKeyMapData
---@field map2 HawtkeysKeyMapData

---@return HawtkeysDuplicatesData[]
function M.show_duplicates()
    local allKeys = tsSearch.get_all_keymaps()
    local duplicates = utils.find_duplicates(allKeys)
    local resultTable = {}
    for index, data in pairs(duplicates) do
        ---@type HawtkeysDuplicatesData
        local object = {
            key = index,
            map1 = data[1],
            map2 = data[2],
        }
        table.insert(resultTable, object)
    end
    return resultTable
end

return M
