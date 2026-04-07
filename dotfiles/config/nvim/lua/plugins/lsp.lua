return {
  {
    "mason-org/mason.nvim",
    config = function()
      require("mason").setup()
    end,
  },
  {
    "mason-org/mason-lspconfig.nvim",
    dependencies = {
      "mason-org/mason.nvim",
      "neovim/nvim-lspconfig",
      "hrsh7th/cmp-nvim-lsp",
    },
    config = function()
      local capabilities = require("cmp_nvim_lsp").default_capabilities()

      require("mason-lspconfig").setup({
        ensure_installed = {
          "lua_ls",
          "pyright",
          "bashls",
          "jsonls",
          "yamlls",
          "ts_ls",
          "html",
          "cssls",
        },
      })

      local servers = {
        lua_ls = {},
        pyright = {},
        bashls = {},
        jsonls = {},
        yamlls = {},
        ts_ls = {},
        html = {},
        cssls = {},
      }

      for server, config in pairs(servers) do
        config.capabilities = capabilities
        vim.lsp.config(server, config)
        vim.lsp.enable(server)
      end
    end,
  },
}