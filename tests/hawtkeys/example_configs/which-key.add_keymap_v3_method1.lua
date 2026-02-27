local wk = require("which-key")

wk.add({
    { "<leader>f", group = "file" },
    {
        "<leader>ff",
        "<cmd>Telescope find_files<cr>",
        desc = "Find File",
        mode = "n",
    },
    {
        "<leader>fb",
        function()
            print("hello")
        end,
        desc = "Foobar",
    },
    { "<leader>fn", desc = "New File" },
    { "<leader>f1", hidden = true },
    { "<leader>w", proxy = "<c-w>", group = "windows" },
})
