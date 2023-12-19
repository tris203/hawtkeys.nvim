local ts = require("hawtkeys.ts")

local maps = ts.find_maps_in_file("lua/hawtkeys/tests/set_maps.lua")
print(vim.inspect(maps))
