return {
	{
		"williamboman/mason.nvim",
		lazy = false,
		dependencies = {
			"williamboman/mason-lspconfig.nvim",
			"neovim/nvim-lspconfig",
		},
		config = function()
			require("mason").setup()
			require("mason-lspconfig").setup({
				ensure_installed = {
					"autotools_ls", -- Make
					"bashls", -- Bash
					"clangd", -- C/C++
					"cssls", -- CSS
					"dockerls", -- Docker
					"gopls", -- Go
					"html", -- HTML
					"ltex", -- LaTex
					"lua_ls", -- Lua
					-- "prosemd_lsp", -- Markdown
					"ruff_lsp", -- Python
					"rust_analyzer", -- Rust
					"sqlls", -- SQL
					"terraformls", -- Terraform
					"tsserver", -- JavaScript
				},
			})
			require("mason-lspconfig").setup_handlers({
				-- The first entry (without a key) will be the default handler
				-- and will be called for each installed server that doesn't have
				-- a dedicated handler.
				function(server_name) -- default handler (optional)
					require("lspconfig")[server_name].setup({})
				end,
				["lua_ls"] = function()
					require("lspconfig").lua_ls.setup({
						settings = {
							Lua = {
								runtime = {
									-- Tell the language server which version of Lua you're using (most likely LuaJIT in the case of Neovim)
									version = "LuaJIT",
								},
								diagnostics = {
									-- Get the language server to recognize the `vim` global
									globals = { "vim" },
								},
								workspace = {
									-- Make the server aware of Neovim runtime files
									library = vim.api.nvim_get_runtime_file("", true),
								},
								-- Do not send telemetry data containing a randomized but unique identifier
								telemetry = {
									enable = false,
								},
							},
						},
					})
				end,
			})

			local lsp_path = vim.env.NIL_PATH or "target/debug/nil"
			require("lspconfig").nil_ls.setup({
				autostart = true,
				cmd = { lsp_path },
				settings = {
					["nil"] = {
						testSetting = 42,
						formatting = {
							command = { "nixpkgs-fmt" },
						},
					},
				},
			})
		end,
	},
}
