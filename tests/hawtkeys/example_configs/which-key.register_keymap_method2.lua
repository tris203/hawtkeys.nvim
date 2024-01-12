local wk = require("which-key")

wk.register({
    ["<leader>"] = {
        w = {
            name = "test",
            t = { ':lua print("hello")<CR>', "test" },
        },
    },
})
