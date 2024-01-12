local wk = require("which-key")

wk.register({
    ["<leader>wf"] = { ':lua print("hello")<CR>', "hello" },
})
