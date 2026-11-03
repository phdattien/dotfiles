-- File icons need a Nerd Font in the terminal; without one they render as broken glyphs.
local no_icons = { disable_devicons = true }
require('telescope').setup({
    pickers = {
        find_files = no_icons,
        git_files = no_icons,
        grep_string = no_icons,
    },
})

local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>pf', builtin.find_files, {})   
vim.keymap.set('n', '<C-p>', builtin.git_files, {})   
vim.keymap.set('n', '<leader>ps', function()    
    builtin.grep_string({ search = vim.fn.input("Grep > ") })
end)
vim.keymap.set('n', '<leader>ph', builtin.help_tags, {})   

