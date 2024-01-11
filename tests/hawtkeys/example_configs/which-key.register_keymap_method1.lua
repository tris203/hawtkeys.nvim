local wk = require("which-key")

wk.register({
    w = {
        name = "file", -- optional group name
        o = { ':lua print("hello")<CR>', "Find File" }, -- create a binding with label
    },
}, { prefix = "<leader>" })
