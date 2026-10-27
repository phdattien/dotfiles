require("markview").setup({
    preview = {
        icon_provider = "devicons",
        enable = false,
    },
})

vim.keymap.set("n", "<leader>md", "<cmd>Markview toggle<CR>")
