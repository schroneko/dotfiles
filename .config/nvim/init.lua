-- 既存の .vimrc を読み込む
vim.cmd('source ~/.vimrc')

-- lazy.nvim のブートストラップ
local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    'git',
    'clone',
    '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=stable',
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- プラグイン設定
require('lazy').setup({
  {
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    config = function()
      vim.api.nvim_create_autocmd('FileType', {
        callback = function()
          pcall(vim.treesitter.start)
        end,
      })
    end,
  },
})

-- Tree-sitter が有効な場合は termguicolors を有効化
vim.opt.termguicolors = true

-- 背景を透明にする（Ghostty の半透明背景を活かす）
vim.api.nvim_create_autocmd('ColorScheme', {
  pattern = '*',
  callback = function()
    vim.api.nvim_set_hl(0, 'Normal', { bg = 'NONE', ctermbg = 'NONE' })
    vim.api.nvim_set_hl(0, 'NormalFloat', { bg = 'NONE', ctermbg = 'NONE' })
    vim.api.nvim_set_hl(0, 'SignColumn', { bg = 'NONE', ctermbg = 'NONE' })
    vim.api.nvim_set_hl(0, 'EndOfBuffer', { bg = 'NONE', ctermbg = 'NONE' })
    vim.api.nvim_set_hl(0, 'LineNr', { fg = '#888888', bg = 'NONE' })
    vim.api.nvim_set_hl(0, 'CursorLineNr', { fg = '#ffffff', bg = 'NONE', bold = true })
  end,
})

-- 初回読み込み時にも適用
vim.api.nvim_set_hl(0, 'Normal', { bg = 'NONE', ctermbg = 'NONE' })
vim.api.nvim_set_hl(0, 'NormalFloat', { bg = 'NONE', ctermbg = 'NONE' })
vim.api.nvim_set_hl(0, 'SignColumn', { bg = 'NONE', ctermbg = 'NONE' })
vim.api.nvim_set_hl(0, 'EndOfBuffer', { bg = 'NONE', ctermbg = 'NONE' })
vim.api.nvim_set_hl(0, 'LineNr', { fg = '#888888', bg = 'NONE' })
vim.api.nvim_set_hl(0, 'CursorLineNr', { fg = '#ffffff', bg = 'NONE', bold = true })
