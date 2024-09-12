return {
  'stevearc/conform.nvim',
  config = function()
    require("conform").setup({
      formatters_by_ft = {
        go = { "gofmt" },
        lua = { "stylua" }
      }
    })
  end,
  opts = {},
}
