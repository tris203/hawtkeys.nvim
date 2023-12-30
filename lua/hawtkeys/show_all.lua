local M = {}
local tsSearch = require("hawtkeys.ts")

---@return HawtkeysKeyMapData
function M.show_all()
    return tsSearch.get_all_keymaps()
end

return M
