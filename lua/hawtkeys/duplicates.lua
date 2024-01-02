local M = {}
local utils = require("hawtkeys.utils")
local tsSearch = require("hawtkeys.ts")

---@class HawtkeysDuplicatesData
---@field key string
---@field file1 string
---@field file2 string
---
---TODO: Make this return a HawtkeysKeyMapData instead of strings

---@return HawtkeysDuplicatesData[]
function M.show_duplicates()
    local allKeys = tsSearch.get_all_keymaps()
    local duplicates = utils.find_duplicates(allKeys)
    local resultTable = {}
    for index, data in pairs(duplicates) do
        ---@type HawtkeysDuplicatesData
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
