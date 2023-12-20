local hawtkeys = require("hawtkeys")

hawtkeys.setup({
    customMaps = {
        ["shortIndex.nvim_set_keymap"] = {
            modeIndex = 1,
            lhsIndex = 2,
            rhsIndex = 3,
            method = "dot_index_expression",
        },
    },
})
local ts = require("hawtkeys.ts")

local maps = ts.find_maps_in_file("lua/hawtkeys/tests/set_maps.lua")
print(vim.inspect(maps))
ts.reset_scanned_files()
