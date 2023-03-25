-- This file can be loaded by calling `lua require('plugins')` from your init.vim

-- Only required if you have packer configured as `opt`
vim.cmd [[packadd packer.nvim]]

return require('packer').startup(function(use)
  -- Packer can manage itself
  use 'wbthomason/packer.nvim'
  use {
	  'nvim-telescope/telescope.nvim', tag = '0.1.1',
	  requires = { 
      {'nvim-lua/plenary.nvim'},
      { "nvim-telescope/telescope-live-grep-args.nvim" },
    },
    config = function()
      require("telescope").load_extension("live_grep_args")
    end
  }

  use({ "folke/trouble.nvim" })

  use 'Mofiqul/dracula.nvim'
  use({ 'nvim-treesitter/nvim-treesitter', { run = ':TSUpdate'} })
  use {'windwp/nvim-ts-autotag', after = 'nvim-treesitter'}
  use({ 'nvim-lua/plenary.nvim' })
  use({ 'ThePrimeagen/harpoon' })
  use({ 'mbbill/undotree' })
  use({ 'tpope/vim-fugitive' })
  use "lukas-reineke/indent-blankline.nvim"

  use {
      'numToStr/Comment.nvim',
      config = function()
          require('Comment').setup()
      end
  }

  use {
	  'VonHeikemen/lsp-zero.nvim',
	  branch = 'v1.x',
	  requires = {
		  -- LSP Support
		  {'neovim/nvim-lspconfig'},             -- Required
		  {'williamboman/mason.nvim'},           -- Optional
		  {'williamboman/mason-lspconfig.nvim'}, -- Optional

		  -- Autocompletion
		  {'hrsh7th/nvim-cmp'},
		  {'hrsh7th/cmp-buffer'},
		  {'hrsh7th/cmp-path'},
		  {'saadparwaiz1/cmp_luasnip'},
		  {'hrsh7th/cmp-nvim-lsp'},
		  {'hrsh7th/cmp-nvim-lua'},

      -- Snippets
		  {'L3MON4D3/LuaSnip'},
		  {'rafamadriz/friendly-snippets'},
	  }
  }

  use 'jose-elias-alvarez/null-ls.nvim'

  use {
      "folke/which-key.nvim",
      config = function()
          vim.o.timeout = true
          vim.o.timeoutlen = 300
          require("which-key").setup {
              ignore_missing = true,
              show_help = false
          }
      end
  }

  -- use({
  --     "kylechui/nvim-surround",
  --     tag = "*", -- Use for stability; omit to use `main` branch for the latest features
  --     config = function()
  --         require("nvim-surround").setup({
  --             -- Configuration here, or leave empty to use defaults
  --         })
  --     end
  -- })

  use {
	"windwp/nvim-autopairs",
    config = function() require("nvim-autopairs").setup {} end
  }

end)

