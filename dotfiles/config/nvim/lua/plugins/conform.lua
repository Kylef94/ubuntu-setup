return {
  {
    "stevearc/conform.nvim",
    opts = {
      format_on_save = {
        timeout_ms = 1000,
        lsp_fallback = true,
      },
      formatters_by_ft = {
        lua = { "stylua" },
        python = { "ruff_format" },
        javascript = { "prettierd", "prettier" },
        typescript = { "prettierd", "prettier" },
        javascriptreact = { "prettierd", "prettier" },
        typescriptreact = { "prettierd", "prettier" },
        json = { "prettierd", "prettier" },
        yaml = { "prettierd", "prettier" },
        markdown = { "prettierd", "prettier" },
        html = { "prettierd", "prettier" },
        css = { "prettierd", "prettier" },
      },
    },
  },
}