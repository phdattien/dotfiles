-- Neovim 0.12 dropped the `all = false` option for query predicates/directives:
-- handlers always get lists of nodes. The pinned nvim-treesitter (archived
-- master branch) still expects single nodes, which crashes e.g. markdown
-- injections ("attempt to call method 'range'"). Re-register its handlers
-- with each capture unwrapped to its last node.
if vim.fn.has("nvim-0.12") == 1 then
  local query = vim.treesitter.query
  local add_predicate, add_directive = query.add_predicate, query.add_directive
  local function unwrap(handler)
    return function(match, ...)
      local m = {}
      for id, nodes in pairs(match) do
        m[id] = type(nodes) == "table" and nodes[#nodes] or nodes
      end
      return handler(m, ...)
    end
  end
  query.add_predicate = function(name, handler, opts) return add_predicate(name, unwrap(handler), opts) end
  query.add_directive = function(name, handler, opts) return add_directive(name, unwrap(handler), opts) end
  package.loaded["nvim-treesitter.query_predicates"] = nil
  local ok, err = pcall(require, "nvim-treesitter.query_predicates")
  query.add_predicate, query.add_directive = add_predicate, add_directive
  if not ok then vim.notify(err, vim.log.levels.WARN) end
end

require'nvim-treesitter.configs'.setup {
  -- A list of parser names, or "all" (the four listed parsers should always be installed)
  ensure_installed = { "c", "cpp", "python", "typescript" },

  -- Install parsers synchronously (only applied to `ensure_installed`)
  sync_install = false,

  -- Automatically install missing parsers when entering buffer
  -- Recommendation: set to false if you don't have `tree-sitter` CLI installed locally
  auto_install = true,

  highlight = {
    -- `false` will disable the whole extension
    enable = true,

    -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
    -- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
    -- Using this option may slow down your editor, and you may see some duplicate highlights.
    -- Instead of true it can also be a list of languages
    additional_vim_regex_highlighting = false,
  },
}

