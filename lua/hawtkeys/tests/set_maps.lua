vim.api.nvim_set_keymap(
    "n",
    "<leader>1",
    ':lua print("1 pressed")<CR>',
    { noremap = true, silent = true }
)
vim.keymap.set(
    "n",
    "<leader>2",
    ':lua print("2 pressed")<CR>',
    { noremap = true, silent = true }
)

local normalMap = function(lhs, rhs)
    vim.api.nvim_set_keymap("n", lhs, rhs, { noremap = true, silent = true })
end
normalMap("<leader>3", ':lua print("3 pressed")<CR>')

local shortIndex = vim.api

shortIndex.nvim_set_keymap(
    "n",
    "<leader>4",
    ':lua print("4 pressed")<CR>',
    { noremap = true, silent = true }
)

local shortFunc = vim.api.nvim_set_keymap

shortFunc(
    "n",
    "<leader>5",
    ':lua print("5 pressed")<CR>',
    { noremap = true, silent = true }
)

local whichkey = require("which-key")

whichkey.register({
    ["<leader>"] = {
        ["6"] = { ':lua print("6 pressed")<CR>', "Print 6" },
        ["7"] = { ':lua print("7 pressed")<CR>', "Print 7" },
    },
})

return {
    "plugin/example",
    keys = {
        { "<leader>8", ":lua print('8 pressed" },
    },
}
