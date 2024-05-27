return {
	{
		"dstein64/vim-startuptime",
		cmd = "StartupTime",
		config = function()
			vim.g.startuptime_tries = 10
		end,
	},
	{
		"folke/persistence.nvim",
		event = "BufReadPre",
		keys = function()
			return {
				{ "<leader>qs", [[<cmd>lua require("persistence").load()<CR>]], desc = "Restore Session" },
				{
					"<leader>ql",
					[[<cmd>lua require("persistence").load({last=true})<CR>]],
					desc = "Restore Last Session",
				},
				{ "<leader>qq", [[<cmd>lua require("persistence").stop()<CR>]], desc = "Stop Persistence" },
			}
		end,
		config = function()
			require("persistence").setup()
		end,
	},
	{ "nvim-lua/plenary.nvim", lazy = true },
}
