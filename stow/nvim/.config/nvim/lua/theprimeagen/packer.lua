-- Plugin list. Every plugin is pinned to the exact commit that is known to work
-- with Neovim 0.10.4 and 0.12.6 (newer lsp-zero/mason/treesitter releases may break this config).
-- To update: remove the `commit` field(s), run :PackerSync, then re-pin.

-- packer.nvim (unmaintained) calls vim.tbl_islist, which Neovim 0.13 removed.
vim.tbl_islist = vim.tbl_islist or vim.islist

vim.cmd [[packadd packer.nvim]]

return require('packer').startup(function(use)
    -- Packer can manage itself
    use { 'wbthomason/packer.nvim', commit = 'ea0cc3c59f67c440c5ff0bbe4fb9420f4350b9a3' }

    use {
        'nvim-telescope/telescope.nvim', commit = 'd90956833d7c27e73c621a61f20b29fdb7122709',
        requires = { { 'nvim-lua/plenary.nvim', commit = '74b06c6c75e4eeb3108ec01852001636d85a932b' } }
    }

    use({
        'rose-pine/neovim',
        as = 'rose-pine',
        commit = '8b1fd252255a7f2c41b4192a787ab62660b29f72',
        config = function()
            require("rose-pine").setup()
            vim.cmd('colorscheme rose-pine')
        end
    })

    use { "catppuccin/nvim", as = "catppuccin", commit = 'edefef779ab08ce1a4a404713e3012b0d202bd35' }

    use({ "nvim-treesitter/nvim-treesitter", commit = 'cf12346a3414fa1b06af75c79faebe7f76df080a', run = ":TSUpdate" })
    use { "theprimeagen/harpoon", commit = '1bc17e3e42ea3c46b33c0bbad6a880792692a1b3' }
    use { "theprimeagen/refactoring.nvim", commit = '6784b54587e6d8a6b9ea199318512170ffb9e418' }
    use { "mbbill/undotree", commit = '6fa6b57cda8459e1e4b2ca34df702f55242f4e4d' }
    use { "tpope/vim-fugitive", commit = '3b753cf8c6a4dcde6edee8827d464ba9b8c4a6f0' }
    use { "tpope/vim-commentary", commit = '64a654ef4a20db1727938338310209b6a63f60c9' }

    use {
        'VonHeikemen/lsp-zero.nvim',
        branch = 'v1.x',
        commit = 'e993dff0f7de1b46743365d8d88050c45473288b',
        requires = {
            -- LSP Support
            { 'neovim/nvim-lspconfig', commit = '0f9e596d896c4260cd7f6a59e90b04713eb948db' },
            { 'williamboman/mason.nvim', commit = '2a6940af80375532e5e9e7c1f2fc6319a1b7a69d' },
            { 'williamboman/mason-lspconfig.nvim', commit = 'b3298993d55fa194279b5eb9dbfb3a43da65cadf' },

            -- Autocompletion
            { 'hrsh7th/nvim-cmp', commit = '2ffe79f1f021def8dd1fcd81deb16f1bb0d989f3' },
            { 'hrsh7th/cmp-buffer', commit = 'b74fab3656eea9de20a9b8116afa3cfc4ec09657' },
            { 'hrsh7th/cmp-path', commit = 'c642487086dbd9a93160e1679a1327be111cbc25' },
            { 'saadparwaiz1/cmp_luasnip', commit = '98d9cb5c2c38532bd9bdb481067b20fea8f32e90' },
            { 'hrsh7th/cmp-nvim-lsp', commit = 'cbc7b02bb99fae35cb42f514762b89b5126651ef' },
            { 'hrsh7th/cmp-nvim-lua', commit = 'e3a22cb071eb9d6508a156306b102c45cd2d573d' },

            -- Snippets
            { 'L3MON4D3/LuaSnip', commit = '0abc8f390b278c3b4aabc4c004ac8a088b65cf24' },
            { 'rafamadriz/friendly-snippets', commit = 'b4d01b0fdf3c9a549961c2f9ffe8dc09be166219' },
        }
    }
    use {
        "supermaven-inc/supermaven-nvim",
        commit = '07d20fce48a5629686aefb0a7cd4b25e33947d50',
        config = function()
            require("supermaven-nvim").setup({})
        end,
    }

    use {
        "coder/claudecode.nvim",
        commit = 'c0deb41a0c6ac74c620be0a683aa9834e535c84a',
        config = function()
            -- Claude runs in a tmux pane; the plugin only provides the IDE bridge
            require("claudecode").setup({ terminal = { provider = "none" } })
        end,
    }

    use {
        "OXY2DEV/markview.nvim",
        commit = '190bb227c9d3eb4451b81fa16ea3d2efde2d67c5',
        requires = { { "nvim-tree/nvim-web-devicons", commit = 'ec309a0eaff6ea967e58c275996155ab5c16938d' } },
    }
end)
