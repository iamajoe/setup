local null_ls = require("null-ls")
local h = require("null-ls.helpers")
local u = require("null-ls.utils")

local lSsources = {
	null_ls.builtins.formatting.prettier,
  null_ls.builtins.diagnostics.eslint.with({
    cwd = h.cache.by_bufnr(function(params)
      return u.root_pattern(
      ".eslintrc",
      ".eslintrc.js",
      ".eslintrc.cjs",
      ".eslintrc.yaml",
      ".eslintrc.yml",
      ".eslintrc.json"
      )(params.bufname)
    end),
  }),
  null_ls.builtins.formatting.eslint,

	-- null_ls.builtins.formatting.stylua,

	null_ls.builtins.diagnostics.actionlint,
	null_ls.builtins.diagnostics.ansiblelint,

	null_ls.builtins.diagnostics.golangci_lint,
	null_ls.builtins.formatting.gofmt,
	null_ls.builtins.formatting.goimports,

	null_ls.builtins.diagnostics.jsonlint,
	null_ls.builtins.formatting.json_tool,
	null_ls.builtins.diagnostics.tsc,
  null_ls.builtins.formatting.sql_formatter,

}
local augroup = vim.api.nvim_create_augroup("LspFormatting", {})

null_ls.setup({
	sources = lSsources,

  on_attach = function(client, bufnr)
    if client.supports_method("textDocument/formatting") then
      vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
      vim.api.nvim_create_autocmd("BufWritePre", {
        group = augroup,
        buffer = bufnr,
        callback = function()
          vim.lsp.buf.format({ 
            bufnr = bufnr,
            filter = function(client)
              return client.name ~= "volar"
            end,
          })
        end,
      })
    end
  end,
})
