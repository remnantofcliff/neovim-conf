return {
	{
		"L3MON4D3/LuaSnip",
		version = "v2.*",
		build = "make install_jsregexp",
		dependencies = { "rafamadriz/friendly-snippets" },
		config = function()
			require("luasnip.loaders.from_vscode").lazy_load()
		end,
	},
	{
		"Wansmer/treesj",
		keys = { "<leader>m", "<leader>j", "<leader>s" },
		dependencies = { "nvim-treesitter/nvim-treesitter" },
		config = function()
			require("treesj").setup({--[[ your config ]]
			})
		end,
		event = { "VeryLazy" },
	},
	{
		"olimorris/onedarkpro.nvim",
		config = function(plugin, opts)
			require("onedarkpro").setup(opts)
			vim.cmd("colorscheme onedark_dark")
		end,
		event = "VeryLazy",
		opts = {
			colors = {
				red = "#F03030",
				yellow = "#FFFF00",
			},
			highlights = {
				-- help treesitter-highlight-groups
				Comment = { italic = true },
			},
		},
	},
	{
		"folke/which-key.nvim",
		event = "VeryLazy",
		opts = {},
	},
	{
		"hrsh7th/cmp-buffer",
	},
	{
		"hrsh7th/cmp-cmdline",
	},
	{
		"hrsh7th/cmp-nvim-lsp",
		dependences = {
			"neovim/nvim-lspconfig",
		},
		config = function()
			local capabilities = require("cmp_nvim_lsp").default_capabilities()
			local lsp_config = require("lspconfig")

            lsp_config.bashls.setup({capabilities = capabilities})
            lsp_config.clangd.setup({
                capabilities = capabilities,
                cmd = {"clangd"},
            })

			lsp_config.lua_ls.setup({
				capabilities = capabilities,
				on_init = function(client)
					local path = client.workspace_folders[1].name
					if
						not vim.loop.fs_stat(path .. "/.luarc.json")
						and not vim.loop.fs_stat(path .. "/.luarc.jsonc")
					then
						client.config.settings = vim.tbl_deep_extend("force", client.config.settings, {
							Lua = {
								runtime = {
									version = "LuaJIT",
								},
								workspace = {
									checkThirdParty = false,
									library = {
										vim.env.VIMRUNTIME,
									},
								},
							},
						})

						client.notify("workspace/didChangeConfiguration", { settings = client.config.settings })
					end

					return true
				end,
			})
		end,
	},
	{
		"hrsh7th/cmp-path",
	},
	{
		"hrsh7th/nvim-cmp",
		event = { "CmdlineEnter", "InsertEnter" },
		dependencies = {
			"L3MON4D3/LuaSnip",
			"hrsh7th/cmp-buffer",
			"hrsh7th/cmp-cmdline",
			"hrsh7th/cmp-nvim-lsp",
			"hrsh7th/cmp-path",
			"saadparwaiz1/cmp_luasnip",
		},
		config = function()
			local cmp = require("cmp")
			cmp.setup({
				snippet = {
					expand = function(args)
						require("luasnip").lsp_expand(args.body)
					end,
				},
				window = {
					completion = cmp.config.window.bordered(),
					documentation = cmp.config.window.bordered(),
				},
				mapping = cmp.mapping.preset.insert({
					["<C-u>"] = cmp.mapping.scroll_docs(-4),
					["<C-d>"] = cmp.mapping.scroll_docs(4),
					["<C-Space>"] = cmp.mapping.complete(),
					["<C-p>"] = cmp.mapping.select_prev_item(),
					["<C-n>"] = cmp.mapping.select_next_item(),
					["<C-e>"] = cmp.mapping.abort(),
					["<CR>"] = cmp.mapping.confirm({ select = false }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
					["<Tab>"] = cmp.mapping(function(fallback)
						local col = vim.fn.col(".") - 1

						if cmp.visible() then
							cmp.select_next_item()
						elseif col == 0 or vim.fn.getline("."):sub(col, col):match("%s") then
							fallback()
						else
							cmp.complete()
						end
					end, { "i", "s" }),

					["<S-Tab>"] = cmp.mapping(function(fallback)
						if cmp.visible() then
							cmp.select_prev_item()
						else
							fallback()
						end
					end, { "i", "s" }),
				}),
				sources = cmp.config.sources({
					{ name = "nvim_lsp" },
					{ name = "luasnip" },
					{ name = "buffer" },
					{ name = "path" },
				}),
			})

			cmp.setup.cmdline({ "/", "?" }, {
				mapping = cmp.mapping.preset.cmdline(),
				sources = {
					{ name = "buffer" },
				},
			})

			-- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
			cmp.setup.cmdline(":", {
				mapping = cmp.mapping.preset.cmdline(),
				sources = cmp.config.sources({
					{ name = "path" },
					{ name = "cmdline" },
				}),
			})
		end,
	},
	{
		"mhartington/formatter.nvim",
		event = "VeryLazy",
		config = function()
			local util = require("formatter.util")

			require("formatter").setup({
				logging = true,
				log_level = vim.log.levels.DEBUG,
				filetype = {
					lua = {
						require("formatter.filetypes.lua").stylua,

						function()
							return {
								exe = "stylua",
								args = {
									"--search-parent-directories",
									"--stdin-filepath",
									util.escape_path(util.get_current_buffer_file_path()),
									"--",
									"-",
								},
								stdin = true,
							}
						end,
					},
				},
			})
		end,
		lazy = false,
	},
	{
		"neovim/nvim-lspconfig",
	},
	{
		"numToStr/Comment.nvim",
		opts = {},
		event = "VeryLazy",
	},
    {
        "numToStr/FTerm.nvim",
        event = "VeryLazy",
    },
	{
		"nvim-lua/plenary.nvim",
	},
	{
		"nvim-telescope/telescope.nvim",
		tag = "0.1.4",
		dependencies = { "nvim-lua/plenary.nvim" },
	},
	{ "nvim-tree/nvim-web-devicons" },
	{
		"nvim-treesitter/nvim-treesitter",
		build = "TSUpdate",
		event = "VeryLazy",
		config = function()
			local configs = require("nvim-treesitter.configs")

			configs.setup({
				ensure_installed = {
					"c",
					"cmake",
					"bash",
					"lua",
					"make",
				},
				sync_install = false,
				highlight = {
					enable = true,
					--additional_vim_regex_highlighting = false,
				},
				indent = { enable = true },
			})
		end,
	},
	{ "rafamadriz/friendly-snippets" },
    {
        'rmagatti/auto-session',
        config = function(plugin, opts)
            require("auto-session").setup(opts)
        end,
        lazy = false,
        -- event = "VeryLazy",
        opts = {
            log_level = "error",
            auto_session_suppress_dirs = { "~/", "~/Projects", "~/Downloads", "/"},
        },
    },
	{ "saadparwaiz1/cmp_luasnip" },
	{
		"windwp/nvim-autopairs",
		event = "InsertEnter",
		opts = {}, -- this is equalent to setup({}) function
	},
}
