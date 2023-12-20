local whichkey = require("which-key")

whichkey.register({
    ["<leader>"] = {
        name = "test",
        ["3"] = { ':lua print("hello")<CR>', "hello" },
    },
})
