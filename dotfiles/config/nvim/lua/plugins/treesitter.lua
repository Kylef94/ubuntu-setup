return {
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    lazy = false,
    config = function()
      require("nvim-treesitter").setup({
        install_dir = vim.fn.stdpath("data") .. "/site",
      })

      require("nvim-treesitter").install({
        "bash",
        "c",
        "cpp",
        "css",
        "dockerfile",
        "gitignore",
        "html",
        "java",
        "javascript",
        "json",
        "lua",
        "markdown",
        "python",
        "query",
        "regex",
        "sql",
        "toml",
        "tsx",
        "typescript",
        "vim",
        "vimdoc",
        "yaml",
      })

      vim.api.nvim_create_autocmd("FileType", {
        pattern = {
          "bash",
          "c",
          "cpp",
          "css",
          "html",
          "java",
          "javascript",
          "json",
          "lua",
          "markdown",
          "python",
          "sql",
          "toml",
          "tsx",
          "typescript",
          "vim",
          "yaml",
        },
        callback = function(args)
          pcall(vim.treesitter.start, args.buf)
        end,
      })
    end,
  },
}return {
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    lazy = false,
    config = function()
      require("nvim-treesitter").setup({
        install_dir = vim.fn.stdpath("data") .. "/site",
      })

      require("nvim-treesitter").install({
        "bash",
        "c",
        "cpp",
        "css",
        "dockerfile",
        "gitignore",
        "html",
        "java",
        "javascript",
        "json",
        "lua",
        "markdown",
        "python",
        "query",
        "regex",
        "sql",
        "toml",
        "tsx",
        "typescript",
        "vim",
        "vimdoc",
        "yaml",
      })

      vim.api.nvim_create_autocmd("FileType", {
        pattern = {
          "bash",
          "c",
          "cpp",
          "css",
          "html",
          "java",
          "javascript",
          "json",
          "lua",
          "markdown",
          "python",
          "sql",
          "toml",
          "tsx",
          "typescript",
          "vim",
          "yaml",
        },
        callback = function(args)
          pcall(vim.treesitter.start, args.buf)
        end,
      })
    end,
  },
}