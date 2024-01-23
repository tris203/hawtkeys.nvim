local wk = require("which-key")

local description = "Hello World"

local function say_hello()
    print(description)
end

wk.register({
    ["81"] = { say_hello, description },
}, { prefix = "<leader>" })
