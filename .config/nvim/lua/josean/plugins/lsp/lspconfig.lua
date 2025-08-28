return {
  "neovim/nvim-lspconfig",
  event = { "BufReadPre", "BufNewFile" },
  dependencies = {
    "williamboman/mason.nvim",
    "williamboman/mason-lspconfig.nvim",
    "hrsh7th/cmp-nvim-lsp",
    { "antosha417/nvim-lsp-file-operations", config = true },
    { "folke/neodev.nvim", opts = {} },
  },
  config = function()
    local lspconfig = require("lspconfig")
    local capabilities = require("cmp_nvim_lsp").default_capabilities()

    for type, icon in pairs({ Error = " ", Warn = " ", Hint = "󰠠 ", Info = " " }) do
      local hl = "DiagnosticSign" .. type
      vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
    end

    vim.api.nvim_create_autocmd("LspAttach", {
      group = vim.api.nvim_create_augroup("UserLspConfig", {}),
      callback = function(ev)
        local o = { buffer = ev.buf, silent = true }
        local k = vim.keymap
        k.set("n", "gd", "<cmd>Telescope lsp_definitions<CR>", o)
        k.set("n", "gD", vim.lsp.buf.declaration, o)
        k.set("n", "gR", "<cmd>Telescope lsp_references<CR>", o)
        k.set("n", "gi", "<cmd>Telescope lsp_implementations<CR>", o)
        k.set("n", "gt", "<cmd>Telescope lsp_type_definitions<CR>", o)
        k.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, o)
        k.set("n", "<leader>rn", vim.lsp.buf.rename, o)
        k.set("n", "<leader>D", "<cmd>Telescope diagnostics bufnr=0<CR>", o)
        k.set("n", "<leader>d", vim.diagnostic.open_float, o)
        k.set("n", "[d", vim.diagnostic.goto_prev, o)
        k.set("n", "]d", vim.diagnostic.goto_next, o)
        k.set("n", "K", vim.lsp.buf.hover, o)
        k.set("n", "<leader>rs", ":LspRestart<CR>", o)
      end,
    })

    vim.api.nvim_create_autocmd("BufWritePre", {
      pattern = { "*.tsx", "*.ts", "*.jsx", "*.js" },
      command = "silent! EslintFixAll",
      group = vim.api.nvim_create_augroup("MyAutocmdsJavaScripFormatting", {}),
    })

    local mason_lspconfig = require("mason-lspconfig")
    mason_lspconfig.setup_handlers({
      function(server)
        lspconfig[server].setup({ capabilities = capabilities })
      end,

      ["svelte"] = function()
        lspconfig.svelte.setup({
          capabilities = capabilities,
          on_attach = function(client)
            vim.api.nvim_create_autocmd("BufWritePost", {
              pattern = { "*.js", "*.ts" },
              callback = function(ctx)
                client.notify("$/onDidChangeTsOrJsFile", { uri = vim.uri_from_fname(ctx.match) })
              end,
            })
          end,
        })
      end,

      ["graphql"] = function()
        lspconfig.graphql.setup({
          capabilities = capabilities,
          filetypes = { "graphql", "gql", "svelte", "typescriptreact", "javascriptreact" },
        })
      end,

      ["emmet_ls"] = function()
        lspconfig.emmet_ls.setup({
          capabilities = capabilities,
          filetypes = { "html", "typescriptreact", "javascriptreact", "css", "sass", "scss", "less", "svelte" },
        })
      end,

      ["lua_ls"] = function()
        lspconfig.lua_ls.setup({
          capabilities = capabilities,
          settings = {
            Lua = {
              diagnostics = { globals = { "vim" } },
              completion = { callSnippet = "Replace" },
              workspace = { checkThirdParty = false },
            },
          },
        })
      end,
    })
  end,
}
