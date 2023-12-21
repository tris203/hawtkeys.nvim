local plenary_dir = os.getenv("PLENARY_DIR") or "/tmp/plenary.nvim"
local treesitter_dir = os.getenv("TREESITTER_DIR") or "/tmp/nvim-treesitter"
local whichkey_dir = os.getenv("WHICHKEY_DIR") or "/tmp/which-key.nvim"
if  vim.fn.isdirectory(plenary_dir) == 0  then
  vim.fn.system({"git", "clone", "https://github.com/nvim-lua/plenary.nvim", plenary_dir})
end
if  vim.fn.isdirectory(treesitter_dir) == 0  then
  vim.fn.system({"git", "clone", "https://github.com/nvim-treesitter/nvim-treesitter", treesitter_dir})
end
if  vim.fn.isdirectory(whichkey_dir) == 0  then
  vim.fn.system({"git", "clone", "https://github.com/folke/which-key.nvim", whichkey_dir})
end
vim.opt.rtp:append(".")
vim.opt.rtp:append(plenary_dir)
vim.opt.rtp:append(treesitter_dir)
vim.opt.rtp:append(whichkey_dir)

vim.cmd("runtime plugin/plenary.vim")
vim.cmd("runtime plugin/treesitter.vim")
require("nvim-treesitter.configs").setup {
  ensure_installed = "lua",
  highlight = {
    enable = true,
  },
}
vim.cmd("runtime plugin/which-key.vim")
require("which-key").setup {}
require("plenary.busted")
