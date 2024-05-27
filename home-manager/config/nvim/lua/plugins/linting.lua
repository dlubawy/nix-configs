return {
	{
		"mfussenegger/nvim-lint",
		event = { "BufReadPost", "BufWritePost", "BufNewFile" },
		init = function()
			local sqlfluff = require("lint").linters.sqlfluff
			local dbt_root = vim.fs.find("dbt_project.yml", { upward = true, stop = vim.fs.normalize("~"), limit = 1 })
			if #dbt_root ~= 0 then
				sqlfluff.args = {
					"lint",
					"--format=json",
					"--templater=jinja",
					"--dialect=bigquery",
				}
			end
		end,
		config = function()
			require("lint").linters_by_ft = {
				sql = { "sqlfluff" },
			}
			vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
				callback = function()
					require("lint").try_lint()
				end,
			})
		end,
	},
}
