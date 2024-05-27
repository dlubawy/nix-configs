return {
	{
		"nvim-neo-tree/neo-tree.nvim",
		branch = "v3.x",
		keys = {
			{ "<C-N>", "<cmd>Neotree dir=%:p:h toggle<CR>" },
		},
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-tree/nvim-web-devicons",
			"MunifTanjim/nui.nvim",
			"3rd/image.nvim",
			"s1n7ax/nvim-window-picker",
		},
		config = function()
			require("neo-tree").setup({
				close_if_last_window = true,
				filesystem = {
					follow_current_file = {
						enabled = true,
					},
				},
			})
		end,
	},
	{
		"nvim-pack/nvim-spectre",
		build = false,
		cmd = "Spectre",
		opts = { open_cmd = "noswapfile vnew" },
		keys = {
			{
				"<leader>sr",
				function()
					require("spectre").open()
				end,
				desc = "Replace in files (Spectre)",
			},
		},
	},
	{
		"nvim-telescope/telescope.nvim",
		lazy = false,
		dependencies = {
			"nvim-lua/plenary.nvim",
			{
				"nvim-telescope/telescope-fzf-native.nvim",
				build = "make",
				enabled = vim.fn.executable("make") == 1,
				config = function()
					require("telescope").load_extension("fzf")
				end,
			},
		},
		keys = function()
			local builtin = require("telescope.builtin")
			return {
				{
					"<leader>,",
					"<cmd>Telescope buffers sort_mru=true sort_lastused=true<cr>",
					desc = "Switch Buffer",
				},
				{ "<leader>/", builtin.live_grep, desc = "Grep (root dir)" },
				{ "<leader>:", "<cmd>Telescope command_history<cr>", desc = "Command History" },
				-- find
				{ "<leader>fb", "<cmd>Telescope buffers sort_mru=true sort_lastused=true<cr>", desc = "Buffers" },
				{
					"<leader>fc",
					[[<cmd>lua require("telescope.builtin").find_files({cwd=vim.fn.stdpath("config")})<CR>]],
					desc = "Find Config File",
				},
				{ "<leader>ff", builtin.find_files, desc = "Find Files (root dir)" },
				{
					"<leader>fF",
					[[<cmd>lua require("telescope.builtin").find_files({ cwd = false })<CR>]],
					desc = "Find Files (cwd)",
				},
				{ "<leader>fg", "<cmd>Telescope git_files<cr>", desc = "Find Files (git-files)" },
				{ "<leader>fr", "<cmd>Telescope oldfiles<cr>", desc = "Recent" },
				{
					"<leader>fR",
					[[<cmd>lua require("telescope.builtin").oldfiles({ cwd = vim.loop.cwd() })<CR>]],
					desc = "Recent (cwd)",
				},
				-- git
				{ "<leader>gc", "<cmd>Telescope git_commits<CR>", desc = "commits" },
				{ "<leader>gs", "<cmd>Telescope git_status<CR>", desc = "status" },
				-- search
				{ '<leader>s"', "<cmd>Telescope registers<cr>", desc = "Registers" },
				{ "<leader>sa", "<cmd>Telescope autocommands<cr>", desc = "Auto Commands" },
				{ "<leader>sb", "<cmd>Telescope current_buffer_fuzzy_find<cr>", desc = "Buffer" },
				{ "<leader>sc", "<cmd>Telescope command_history<cr>", desc = "Command History" },
				{ "<leader>sC", "<cmd>Telescope commands<cr>", desc = "Commands" },
				{ "<leader>sd", "<cmd>Telescope diagnostics bufnr=0<cr>", desc = "Document diagnostics" },
				{ "<leader>sD", "<cmd>Telescope diagnostics<cr>", desc = "Workspace diagnostics" },
				{ "<leader>sg", builtin.live_grep, desc = "Grep (root dir)" },
				{
					"<leader>sG",
					[[<cmd>lua require("telescope.builtin").live_grep({ cwd = false })<CR>]],
					desc = "Grep (cwd)",
				},
				{ "<leader>sh", "<cmd>Telescope help_tags<cr>", desc = "Help Pages" },
				{ "<leader>sH", "<cmd>Telescope highlights<cr>", desc = "Search Highlight Groups" },
				{ "<leader>sk", "<cmd>Telescope keymaps<cr>", desc = "Key Maps" },
				{ "<leader>sM", "<cmd>Telescope man_pages<cr>", desc = "Man Pages" },
				{ "<leader>sm", "<cmd>Telescope marks<cr>", desc = "Jump to Mark" },
				{ "<leader>so", "<cmd>Telescope vim_options<cr>", desc = "Options" },
				{ "<leader>sR", "<cmd>Telescope resume<cr>", desc = "Resume" },
				{
					"<leader>sw",
					[[<cmd>lua require("telescope.builtin").grep_string({ word_match = "-w" })<CR>]],
					desc = "Word (root dir)",
				},
				{
					"<leader>sW",
					[[<cmd>lua require("telescope.builtin").grep_string({ cwd = false, word_match = "-w" })<CR>]],
					desc = "Word (cwd)",
				},
				{ "<leader>sw", builtin.grep_string, mode = "v", desc = "Selection (root dir)" },
				{
					"<leader>sW",
					[[<cmd>lua require("telescope.builtin").grep_string({ cwd = false })<CR>]],
					mode = "v",
					desc = "Selection (cwd)",
				},
				{
					"<leader>uC",
					[[<cmd>lua require("telescope.builtin").colorscheme({ enable_preview = true })<CR>]],
					desc = "Colorscheme with preview",
				},
			}
		end,
		config = function()
			require("telescope").setup({
				extensions = {
					fzf = {
						fuzzy = true, -- false will only do exact matching
						override_generic_sorter = true, -- override the generic sorter
						override_file_sorter = true, -- override the file sorter
						case_mode = "smart_case", -- or "ignore_case" or "respect_case"
						-- the default case_mode is "smart_case"
					},
				},
			})
		end,
	},
	{
		"folke/which-key.nvim",
		event = "VeryLazy",
		init = function()
			vim.o.timeout = true
			vim.o.timeoutlen = 300

			WhichKeyNorg = function()
				local wkl = require("which-key")
				local buf = vim.api.nvim_get_current_buf()
				wkl.register({
					t = {
						name = "+todo",
					},
					i = {
						name = "+insert",
					},
					l = {
						name = "+list",
					},
					m = {
						name = "+mode",
					},
					n = {
						name = "+note",
					},
				}, { prefix = "<localleader", buffer = buf })
			end

			WhichKeySQL = function()
				local wkl = require("which-key")
				local buf = vim.api.nvim_get_current_buf()
				local scratch = function()
					vim.cmd([[
                        vnew
                        set filetype=sql
                        setlocal buftype=nofile
                        setlocal bufhidden=hide
                        setlocal noswapfile
                    ]])
				end
				local buffer_to_string = function()
					local content = vim.api.nvim_buf_get_lines(0, 0, -1, false)
					return table.concat(content, " ")
				end
				local dbt_preview = function(json)
					local cmd = "vsplit term://dbt show "
					if json ~= nil then
						cmd = cmd .. "--output json "
					end
					if vim.bo.buftype == "nofile" then
						cmd = string.format([[%s--inline \"%s\"]], cmd, buffer_to_string():gsub('"', "'"))
					else
						cmd = cmd .. "-s %:t:r"
					end
					vim.cmd(cmd)
				end
				local dbt_json_preview = function()
					dbt_preview(true)
				end
				wkl.register({
					c = { "<cmd>vsplit term://dbt compile -s %:t:r<CR>", "Compile SQL" },
					r = { "<cmd>vsplit term://dbt run -s %:t:r<CR>", "Run SQL" },
					b = { "<cmd>vsplit term://dbt build -s %:t:r<CR>", "Build SQL" },
					p = { dbt_preview, "Preview SQL Run" },
					j = { dbt_json_preview, "JSON Preview SQL Run" },
					s = { scratch, "Scratchpad" },
				}, { prefix = "<localleader>", buffer = buf })
			end
		end,
		opts = {
			plugins = { spelling = true },
			defaults = {
				mode = { "n", "v" },
				["g"] = { name = "+goto" },
				["gs"] = { name = "+surround" },
				["]"] = { name = "+next" },
				["["] = { name = "+prev" },
				["<leader>"] = {
					["<tab>"] = { name = "+tabs" },
					b = { name = "+buffer" },
					c = {
						name = "+code",
						d = { "<cmd>cd %:p:h<CR><cmd>pwd<CR>", "Change Directory" },
						l = { "<cmd>LspInfo<CR>", "Lsp Info" },
						a = { vim.lsp.buf.code_action, "Code Action" },
					},
					f = {
						name = "+file/find",
						n = { "<cmd>enew<cr>", "New File" },
					},
					g = { name = "+git" },
					gh = { name = "+hunks" },
					gt = { name = "+toggle" },
					q = {
						name = "+quit/session",
						a = { "<cmd>qa<CR>", "Quit" },
					},
					s = {
						name = "+search",
						n = { name = "+noice" },
					},
					u = { name = "+ui" },
					w = { name = "+windows" },
					x = { name = "+diagnostics/quickfix" },
					n = { name = "+neorg" },
				},
			},
		},
		config = function(_, opts)
			local wk = require("which-key")
			wk.setup(opts)
			wk.register(opts.defaults)
		end,
	},
	{
		"lewis6991/gitsigns.nvim",
		event = { "BufReadPost", "BufWritePost", "BufNewFile" },
		init = function()
			vim.api.nvim_create_autocmd("ColorScheme", {
				pattern = "catppuccin-frappe",
				callback = function()
					vim.cmd([[
                        hi GitSignsChangeInline guifg=#a5adce
                        hi GitSignsAddInline guifg=#a5adce
                        hi GitSignsDeleteInline guifg=#a5adce
                        hi GitSignsCurrentLineBlame guifg=#a5adce
                    ]])
				end,
			})
		end,
		keys = function()
			local gs = require("gitsigns")
			return {
				{ "<leader>ghs", gs.stage_hunk, desc = "Stage Hunk" },
				{ "<leader>ghr", gs.reset_hunk, desc = "Reset Hunk" },
				{ "<leader>gS", gs.stage_buffer, desc = "Stage Buffer" },
				{ "<leader>ghu", gs.undo_stage_hunk, desc = "Undo Stage Hunk" },
				{ "<leader>gR", gs.reset_buffer, desc = "Reset Buffer" },
				{ "<leader>ghp", gs.preview_hunk, desc = "Preview Hunk" },
				{
					"<leader>gb",
					function()
						gs.blame_line({ full = true })
					end,
					desc = "Blame Line",
				},
				{ "<leader>gtb", gs.toggle_current_line_blame, desc = "Toggle Line Blame" },
				{ "<leader>gd", gs.diffthis, desc = "Diff This" },
				{
					"<leader>gD",
					function()
						gs.diffthis("~")
					end,
					desc = "Diff ~",
				},
				{ "<leader>gtd", gs.toggle_deleted, desc = "Toggle Deleted" },
			}
		end,
		config = function()
			require("gitsigns").setup()
		end,
	},
	{
		"RRethy/vim-illuminate",
		event = { "BufReadPost", "BufWritePost", "BufNewFile" },
		keys = {
			{ "]]", desc = "Next Reference" },
			{ "[[", desc = "Prev Reference" },
		},
		opts = {
			delay = 200,
			large_file_cutoff = 2000,
			large_file_overrides = {
				providers = { "lsp" },
			},
		},
		config = function(_, opts)
			require("illuminate").configure(opts)

			local function map(key, dir, buffer)
				vim.keymap.set("n", key, function()
					require("illuminate")["goto_" .. dir .. "_reference"](false)
				end, { desc = dir:sub(1, 1):upper() .. dir:sub(2) .. " Reference", buffer = buffer })
			end

			map("]]", "next")
			map("[[", "prev")

			vim.api.nvim_create_autocmd("FileType", {
				callback = function()
					local buffer = vim.api.nvim_get_current_buf()
					map("]]", "next", buffer)
					map("[[", "prev", buffer)
				end,
			})
		end,
	},
	{
		"folke/trouble.nvim",
		keys = function()
			local trouble = require("trouble")
			return {
				{
					"<leader>xx",
					function()
						trouble.toggle()
					end,
					desc = "Trouble",
				},
				{
					"<leader>xw",
					function()
						trouble.toggle("workspace_diagnostics")
					end,
					desc = "Workspace Diagnostics",
				},
				{
					"<leader>xd",
					function()
						trouble.toggle("document_diagnostics")
					end,
					desc = "Document Diagnostics",
				},
				{
					"<leader>xq",
					function()
						trouble.toggle("quickfix")
					end,
					desc = "Quickfix",
				},
				{
					"<leader>xl",
					function()
						trouble.toggle("loclist")
					end,
					desc = "Location List",
				},
				{
					"gR",
					function()
						trouble.toggle("lsp_reference")
					end,
					desc = "LSP Reference",
				},
			}
		end,
		dependencies = { "nvim-tree/nvim-web-devicons" },
	},
	{
		"folke/todo-comments.nvim",
		dependencies = { "nvim-lua/plenary.nvim" },
		opts = {},
		keys = {
			{
				"]t",
				function()
					require("todo-comments").jump_next()
				end,
				desc = "Next todo comment",
			},
			{
				"[t",
				function()
					require("todo-comments").jump_prev()
				end,
				desc = "Previous todo comment",
			},
			{ "<leader>xt", "<cmd>TodoTrouble<cr>", desc = "Todo (Trouble)" },
			{ "<leader>xT", "<cmd>TodoTrouble keywords=TODO,FIX,FIXME<cr>", desc = "Todo/Fix/Fixme (Trouble)" },
			{ "<leader>st", "<cmd>TodoTelescope<cr>", desc = "Todo" },
			{ "<leader>sT", "<cmd>TodoTelescope keywords=TODO,FIX,FIXME<cr>", desc = "Todo/Fix/Fixme" },
		},
	},
	{
		"cameron-wags/rainbow_csv.nvim",
		config = true,
		ft = {
			"csv",
			"tsv",
			"csv_semicolon",
			"csv_whitespace",
			"csv_pipe",
			"rfc_csv",
			"rfc_semicolon",
		},
		cmd = {
			"RainbowDelim",
			"RainbowDelimSimple",
			"RainbowDelimQuoted",
			"RainbowMultiDelim",
		},
	},
	{
		"tpope/vim-fugitive",
	},
	{
		"iamcco/markdown-preview.nvim",
		lazy = true,
		cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
		ft = { "markdown" },
		build = function()
			vim.fn["mkdp#util#install"]()
		end,
		config = function()
			vim.keymap.set("n", "<localleader>p", "<cmd>MarkdownPreviewToggle<CR>")
		end,
	},
	{
		"simnalamburt/vim-mundo",
		lazy = false,
		keys = {
			{ "<leader>m", "<cmd>MundoToggle<CR>", desc = "Mundo Toggle" },
		},
		config = function()
			vim.opt.undofile = true
		end,
	},
}
