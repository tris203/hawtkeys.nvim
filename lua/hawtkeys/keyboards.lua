local M = {}
-- TODO: Make this dynamic, loading from the keyboards directory
M.qwerty = require("hawtkeys.keyboards.qwerty").layout
M.colemak = require("hawtkeys.keyboards.colemak").layout
M.colemakdh = require("hawtkeys.keyboards.colemak-dh").layout

return M
