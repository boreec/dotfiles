return {
  {
    "williamboman/mason.nvim",
    config = function()
      require("mason").setup()
    end
  },
  {
    "williamboman/mason-lspconfig.nvim",
    config = function()
      require("mason-lspconfig").setup({
        ensure_installed = {
          "lua_ls",
          "gopls"
        }
      })
    end
  },
  {
    "neovim/nvim-lspconfig",
    config = function()
      local capabilities = require("cmp_nvim_lsp").default_capabilities()
      local lspconfig = require("lspconfig")
      lspconfig.lua_ls.setup({
        capabilities = capabilities
      })
      lspconfig.gopls.setup({
        capabilities = capabilities
      })

      vim.keymap.set('n', '<leader>k', vim.lsp.buf.hover, {})
      vim.keymap.set('n', '<leader>r', vim.lsp.buf.rename, {})
      vim.keymap.set('n', 'gd', vim.lsp.buf.definition, {})
      vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, {})
      vim.keymap.set('n', '<leader>s', vim.lsp.buf.document_symbol, {})
      vim.keymap.set('n', '<leader>a', vim.lsp.buf.code_action, {})
      vim.keymap.set('n', '<leader>f', vim.lsp.buf.format, {})
    end
  }
}
