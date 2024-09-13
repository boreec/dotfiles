return {
  "nvim-treesitter/nvim-treesitter",
  build = ":TSUpdate",
  config = function()
    require("nvim-treesitter.configs").setup({
      ensure_installed = {
        "go",
        "graphql",
        "lua",
        "markdown",
        "markdown_inline",
        "proto",
        "python",
        "rust",
        "sql",
        "typescript",
        "vim",
      },
      highlight = {
        enable = true,
        --disable = {"go"}
      }
    })
  end
}
