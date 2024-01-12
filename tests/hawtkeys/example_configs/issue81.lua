local wk = require("which-key")

local T = {}

T.say_hello = function()
    print("hello")
end

T.name = "say hello issue81"

wk.register({
    ["81"] = { T.say_hello, T.name },
}, { prefix = "<leader>" })
