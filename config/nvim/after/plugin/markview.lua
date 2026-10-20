require("markview").setup({
    preview = {
        icon_provider = "internal",
        enable = false,
    },
})

vim.keymap.set("n", "<leader>md", "<cmd>Markview toggle<CR>")
