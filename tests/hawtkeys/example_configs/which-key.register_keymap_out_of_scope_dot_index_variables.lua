local wk = require("which-key")

local details = require("doesntexist.details")

wk.register({
    ["81dot"] = { details.say_hello, details.something.description },
}, { prefix = "<leader>" })
