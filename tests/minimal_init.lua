local M = {}

local function tempdir(plugin)
    if jit.os == "Windows" then
        return "D:\\tmp\\" .. plugin
    end
    return vim.loop.os_tmpdir() .. "/" .. plugin
end

function M.loadLazy()
    local lazy_dir = os.getenv("LAZY_DIR") or tempdir("lazy.nvim")
    if vim.fn.isdirectory(lazy_dir) == 0 then
        vim.fn.system({
            "git",
            "clone",
            "--filter=blob:none",
            "https://github.com/folke/lazy.nvim.git",
            "--branch=stable", -- latest stable release
            lazy_dir,
        })
    end
    vim.opt.rtp:append(lazy_dir)
    print("Installed Lazy to " .. lazy_dir)
end

function M.loadWhichKey()
    local whichkey_dir = os.getenv("WHICHKEY_DIR") or tempdir("which-key.nvim")
    if vim.fn.isdirectory(whichkey_dir) == 0 then
        vim.fn.system({
            "git",
            "clone",
            "--branch=v1.5.0", -- hawtkeys uses which-key.mappings (removed in v3)
            "https://github.com/folke/which-key.nvim",
            whichkey_dir,
        })
    end
    vim.opt.rtp:append(whichkey_dir)
    vim.cmd("runtime plugin/which-key.vim")
    print("Installed WhichKey to " .. whichkey_dir)
    require("which-key").setup({})
end

local plenary_dir = os.getenv("PLENARY_DIR") or tempdir("plenary.nvim")
local treesitter_dir = os.getenv("TREESITTER_DIR") or tempdir("nvim-treesitter")
if vim.fn.isdirectory(plenary_dir) == 0 then
    vim.fn.system({
        "git",
        "clone",
        "https://github.com/nvim-lua/plenary.nvim",
        plenary_dir,
    })
end
if vim.fn.isdirectory(treesitter_dir) == 0 then
    vim.fn.system({
        "git",
        "clone",
        "--branch=master",
        "https://github.com/nvim-treesitter/nvim-treesitter",
        treesitter_dir,
    })
end
vim.opt.rtp:append(".")
vim.opt.rtp:append(plenary_dir)
vim.opt.rtp:append(treesitter_dir)
require("plenary.busted")

vim.cmd("runtime plugin/plenary.vim")
vim.cmd("runtime plugin/treesitter.vim")
require("nvim-treesitter.configs").setup({
    ensure_installed = "lua",
    sync_install = true,
    highlight = {
        enable = true,
    },
})

return M
