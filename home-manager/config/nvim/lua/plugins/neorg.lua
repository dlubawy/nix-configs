return {
	{
		"madskjeldgaard/neorg-figlet-module",
		keys = {
			{
				"<leader>cf",
				"<cmd>Neorg keybind norg external.integrations.figlet.figletize<cr>",
				ft = "norg",
				desc = "Figletize",
			},
		},
	},
	{
		"nvim-neorg/neorg",
		build = ":Neorg sync-parsers",
        version = "7.0.0",
		lazy = false,
		dependencies = { "nvim-lua/plenary.nvim", "pysan3/neorg-templates", "pritchett/neorg-capture" },
		keys = {
			{ "<leader>nn", "<cmd>Neorg<CR>", desc = "Neorg" },
			{ "<leader>nj", "<cmd>Neorg journal<CR>", desc = "Neorg Journal" },
			{ "<leader>ni", "<cmd>Neorg index<CR>", desc = "Neorg Index" },
			{ "<leader>nc", "<cmd>Neorg capture<CR>", desc = "Neorg Capture" },
		},
		config = function()
			require("neorg").setup({
				load = {
					["core.defaults"] = {},
					["core.concealer"] = {},
					["core.dirman"] = {
						config = {
							default_workspace = "desktop",
							workspaces = {
								desktop = "~/Desktop",
								notes = "~/Documents/00-09 System/02 Notes",
							},
						},
					},
					["core.completion"] = {
						config = {
							engine = "nvim-cmp",
						},
					},
					["core.export"] = {},
					["core.presenter"] = {
						config = {
							zen_mode = "zen-mode",
						},
					},
					["core.summary"] = {},
					["external.integrations.figlet"] = {
						config = {
							font = "slant",
							wrapInCodeTags = true,
						},
					},
					["external.templates"] = {},
					["external.capture"] = {
						config = {
							templates = {
								{
									description = "Todo",
									name = "todo",
									file = "todo",
								},
								{
									description = "Note",
									name = "note",
									file = function()
										vim.api.nvim_buf_get_name({ buffer = 0 })
									end,
								},
							},
						},
					},
				},
			})
		end,
	},
	{
		"folke/zen-mode.nvim",
		opts = {
			plugins = {
				tmux = { enabled = true }, -- disables the tmux statusline
				alacritty = {
					enabled = true,
					font = "14", -- font size
				},
			},
		},
	},
	{
		"3rd/image.nvim",
		build = "luarocks --local --lua-version=5.1 install magick",
		lazy = false,
		config = function()
			-- Example for configuring Neovim to load user-installed installed Lua rocks:
			package.path = package.path .. ";" .. vim.fn.expand("$HOME") .. "/.luarocks/share/lua/5.1/?/init.lua;"
			package.path = package.path .. ";" .. vim.fn.expand("$HOME") .. "/.luarocks/share/lua/5.1/?.lua;"
			local backend = "ueberzug"
			if vim.fn.has("macunix") then
				backend = "kitty"
			end
			require("image").setup({
				backend = backend,
				integrations = {
					markdown = {
						enabled = true,
						clear_in_insert_mode = true,
						download_remote_images = true,
						only_render_image_at_cursor = false,
						filetypes = { "markdown", "vimwiki" }, -- markdown extensions (ie. quarto) can go here
					},
					neorg = {
						enabled = true,
						clear_in_insert_mode = true,
						download_remote_images = true,
						only_render_image_at_cursor = false,
						filetypes = { "norg" },
					},
				},
				max_width = nil,
				max_height = nil,
				max_width_window_percentage = nil,
				max_height_window_percentage = 50,
				window_overlap_clear_enabled = false, -- toggles images when windows are overlapped
				window_overlap_clear_ft_ignore = { "cmp_menu", "cmp_docs", "" },
				editor_only_render_when_focused = false, -- auto show/hide images when the editor gains/looses focus
				tmux_show_only_in_active_window = false, -- auto show/hide images in the correct Tmux window (needs visual-activity off)
				hijack_file_patterns = { "*.png", "*.jpg", "*.jpeg", "*.gif", "*.webp" }, -- render image files as images when opened
			})
		end,
	},
}
