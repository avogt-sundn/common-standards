-- Project-local Neovim configuration for common-standards.
--
-- SETUP REQUIRED in your init.lua (once, globally):
--   vim.o.exrc = true   -- enable per-project .nvim.lua files
--
-- Plugins assumed to be installed:
--   stevearc/conform.nvim   -- formatter dispatch
--   neovim/nvim-lspconfig   -- LSP client (for jdtls Java support)
--
-- EditorConfig (.editorconfig at repo root) is handled automatically
-- by Neovim 0.9+ built-in support — no extra setup needed.

-- ---------------------------------------------------------------------------
-- Formatting via conform.nvim
-- ---------------------------------------------------------------------------
local ok, conform = pcall(require, 'conform')
if ok then
  conform.setup({
    formatters_by_ft = {
      -- Frontend: Prettier reads .prettierrc from the repo root automatically
      typescript   = { 'prettier' },
      html         = { 'prettier' },
      css          = { 'prettier' },
      scss         = { 'prettier' },
      json         = { 'prettier' },
      jsonc        = { 'prettier' },
      -- Java: delegate to the Eclipse formatter via jdtls (see LSP section below)
      -- conform will fall back to the LSP formatter when no standalone tool is listed
      java         = { lsp_format = 'fallback' },
    },

    -- Format on save
    format_on_save = {
      timeout_ms = 2000,
      lsp_fallback = true,
    },
  })
end

-- ---------------------------------------------------------------------------
-- Java LSP (jdtls) — Eclipse formatter profile
-- ---------------------------------------------------------------------------
-- If you use nvim-jdtls or nvim-lspconfig with jdtls, point it at the
-- project's Eclipse formatter profile so Java formatting matches Maven.
--
-- Example for nvim-lspconfig:
--
--   require('lspconfig').jdtls.setup({
--     settings = {
--       java = {
--         format = {
--           enabled = true,
--           settings = {
--             url = vim.fn.fnamemodify('.java-config/Common-Standards-Eclipse-Code-Profile.xml', ':p'),
--             profile = 'Common Standards Eclipse Code Profile for Java',
--           },
--         },
--       },
--     },
--   })
--
-- Example for nvim-jdtls (call in an ftplugin/java.lua):
--
--   local root = vim.fn.getcwd()
--   require('jdtls').start_or_attach({
--     settings = {
--       java = {
--         format = {
--           enabled = true,
--           settings = {
--             url = root .. '/.java-config/Common-Standards-Eclipse-Code-Profile.xml',
--             profile = 'Common Standards Eclipse Code Profile for Java',
--           },
--         },
--       },
--     },
--   })
