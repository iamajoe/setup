local null_ls = require("null-ls")

local lSsources = {
	null_ls.builtins.formatting.prettier,
  null_ls.builtins.diagnostics.eslint,
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

null_ls.setup({
	sources = lSsources,
})
