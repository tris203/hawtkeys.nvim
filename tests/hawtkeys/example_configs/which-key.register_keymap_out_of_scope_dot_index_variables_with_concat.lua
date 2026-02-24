local wk = require("which-key")

local details = require("doesntexist.details")

wk.register({
    ["81dotcon"] = {
        details.say_hello,
        details.something.description .. " and This",
    },
}, { prefix = "<leader>" })
