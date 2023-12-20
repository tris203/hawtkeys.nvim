local M = {}
local tsSearch = require("hawtkeys.ts")

---@return table
function M.show_all()
    return tsSearch.get_all_keymaps()
end

return M
