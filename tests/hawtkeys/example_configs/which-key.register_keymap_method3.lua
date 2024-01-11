local wk = require("which-key")

wk.register({
    ["<leader>w"] = {
        name = "test",
        ["3"] = { ':lua print("hello")<CR>', "hello" },
    },
})
