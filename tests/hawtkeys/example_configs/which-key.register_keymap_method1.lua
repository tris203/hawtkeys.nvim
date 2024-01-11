local wk = require("which-key")

wk.register({
    w = {
        name = "file", -- optional group name
        o = { ":lua print('hello')<CR>", "Find File" }, -- create a binding with label
        n = {
            function()
                print("bar")
            end,
            "Foobar",
        }, -- you can also pass functions!
    },
}, { prefix = "<leader>" })
