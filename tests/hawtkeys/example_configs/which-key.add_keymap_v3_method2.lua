local wk = require("which-key")

wk.add({
    { "<leader>ga", ":lua print('git add')<CR>", desc = "Git Add" },
    { "<leader>gc", ":lua print('git commit')<CR>", desc = "Git Commit" },
    {
        mode = { "n", "v" },
        { "<leader>q", "<cmd>q<cr>", desc = "Quit" },
        { "<leader>w", "<cmd>w<cr>", desc = "Write" },
    },
})
