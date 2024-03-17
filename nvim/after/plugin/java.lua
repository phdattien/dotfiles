--local capabilities = vim.lsp.protocol.make_client_capabilities()

--capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)



--local workspace_dir = vim.fn.fnamemodify(vim.fn.getcwd(), ':p:h:t')

---- See `:help vim.lsp.start_client` for an overview of the supported `config` options.
--local config = {
--  -- The command that starts the language server
--  -- See: https://github.com/eclipse/eclipse.jdt.ls#running-from-the-command-line
--  cmd = {

--    -- 💀
--    'java', -- or '/path/to/java17_or_newer/bin/java'
--            -- depends on if `java` is in your $PATH env variable and if it points to the right version.

--    '-Declipse.application=org.eclipse.jdt.ls.core.id1',
--    '-Dosgi.bundles.defaultStartLevel=4',
--    '-Declipse.product=org.eclipse.jdt.ls.core.product',
--    '-Dlog.protocol=true',
--    '-Dlog.level=ALL',
--    '-Xms1g',
--    '-jar', '~/.local/share/nvim/mason/packages/jdtls/plugins/org.eclipse.equinox.launcher_1.6.400.v20210924-0641.jar',
--    '-configuration', '~/.local/share/nvim/mason/packages/jdtls/config_linux/',
--    '-data', vim.fn.expand('~/.cache/jdtls_workspace') .. workspace_dir,
--  },

--  -- 💀
--  -- This is the default if not provided, you can remove it. Or adjust as needed.
--  -- One dedicated LSP server & client will be started per unique root_dir
--  root_dir = require('jdtls.setup').find_root({'.git', 'mvnw', 'gradlew', 'PJV'}),
--  -- root_dir = vim.fs.dirname(vim.fs.find({'.gradlew', '.git', 'mvnw'}, { upward = true })[1]),
--  capabilities = capabilities
--}
---- This starts a new client & server,
---- or attaches to an existing client & server depending on the `root_dir`.
--require('jdtls').start_or_attach(config)

---- This requires java-debug and vscode-java-test bundles, see install


----======================================================================================
---- local config = {
----     -- cmd = {'/path/to/jdt-language-server/bin/jdtls'},
----     cmd = {'~/.local/share/nvim/mason/packages/jdtls/plugins/org.eclipse.equinox.launcher_1.6.400.v20210924-0641.jar'},
----     root_dir = vim.fs.dirname(vim.fs.find({'.gradlew', '.git', 'mvnw'}, { upward = true })[1]),
---- }
---- require('jdtls').start_or_attach(config)


