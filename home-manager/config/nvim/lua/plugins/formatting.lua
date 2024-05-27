return {
	{
		"stevearc/conform.nvim",
		dependencies = {
			"mason.nvim",
		},
		event = { "BufReadPost", "BufWritePost", "BufNewFile" },
		cmd = { "ConformInfo" },
		config = function()
			require("conform").setup({
				formatters_by_ft = {
					["*"] = { "trim_whitespace" },
					docker = { "trim_newlines" },
					go = { "gofmt", "trim_newlines" },
					html = { "prettier", "trim_newlines" },
					javascript = { "prettier", "eslint", "trim_newlines" },
					lua = { "stylua", "trim_newlines" },
					make = { "trim_newlines" },
					nix = { "nixfmt", "trim_newlines" },
					python = { "isort", "black", "trim_newlines" },
					rust = { "rustfmt" },
					sql = function()
						local dbt_root =
							vim.fs.find("dbt_project.yml", { upward = true, stop = vim.fs.normalize("~"), limit = 1 })
						if #dbt_root ~= 0 then
							return { "dbt_sqlfluff", "trim_newlines" }
						end
						return { "sqlfluff", "trim_newlines" }
					end,
					yaml = { "prettier", "trim_newlines" },
					terraform = { "terraform_fmt", "trim_newlines" },
					hcl = { "terragrunt_hclfmt", "trim_newlines" },
				},
				format_after_save = {
					lsp_fallback = true,
					timeout_ms = 500,
				},
				formatters = {
					dbt_sqlfluff = {
						command = "sqlfluff",
						args = { "fix", "--templater", "jinja", "--dialect", "bigquery", "-" },
					},
				},
			})
		end,
	},
}
